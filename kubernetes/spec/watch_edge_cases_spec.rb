# frozen_string_literal: true

require "spec_helper"
require "kubernetes/watch"

RSpec.describe Kubernetes::Watch do
  FakeResponse = Struct.new(:success_value, :timed_out_value, :code, :return_message, keyword_init: true) do
    def success?
      success_value
    end

    def timed_out?
      timed_out_value
    end
  end

  class FakeWatchRequest
    def initialize(chunks:, response:)
      @chunks = chunks
      @response = response
    end

    def on_body(&block)
      @on_body = block
    end

    def on_complete(&block)
      @on_complete = block
    end

    def run
      @chunks.each { |chunk| @on_body.call(chunk) if @on_body }
      @on_complete.call(@response) if @on_complete
      @response
    end
  end

  let(:client) { instance_double(Kubernetes::ApiClient) }
  let(:watch) { described_class.new(client) }

  it "reconnects after a transport failure using the latest resourceVersion" do
    request_one = FakeWatchRequest.new(
      chunks: ["{\"type\":\"ADDED\",\"object\":{\"metadata\":{\"resourceVersion\":\"10\"}}}\n"],
      response: FakeResponse.new(success_value: false, timed_out_value: false, code: 0, return_message: "Connection reset by peer")
    )
    request_two = FakeWatchRequest.new(
      chunks: ["{\"type\":\"MODIFIED\",\"object\":{\"metadata\":{\"resourceVersion\":\"11\"}}}\n"],
      response: FakeResponse.new(success_value: true, timed_out_value: false, code: 200, return_message: nil)
    )

    expect(client).to receive(:build_request)
      .with("GET", "/api/v1/pods?watch=true", auth_names: ["BearerToken"])
      .ordered
      .and_return(request_one)
    expect(watch).to receive(:sleep).with(1.0).ordered
    expect(client).to receive(:build_request)
      .with("GET", "/api/v1/pods?watch=true&resourceVersion=10", auth_names: ["BearerToken"])
      .ordered
      .and_return(request_two)

    seen_versions = []
    response = watch.connect("/api/v1/pods") do |event|
      seen_versions << event.dig("object", "metadata", "resourceVersion")
    end

    expect(response.code).to eq(200)
    expect(seen_versions).to eq(%w[10 11])
  end

  it "reconnects when the watch stream emits a 410 reset event" do
    request_one = FakeWatchRequest.new(
      chunks: [
        "{\"type\":\"ADDED\",\"object\":{\"metadata\":{\"resourceVersion\":\"25\"}}}\n" \
        "{\"type\":\"ERROR\",\"object\":{\"kind\":\"Status\",\"code\":410,\"message\":\"too old resource version\"}}\n"
      ],
      response: FakeResponse.new(success_value: true, timed_out_value: false, code: 200, return_message: nil)
    )
    request_two = FakeWatchRequest.new(
      chunks: ["{\"type\":\"ADDED\",\"object\":{\"metadata\":{\"resourceVersion\":\"26\"}}}\n"],
      response: FakeResponse.new(success_value: true, timed_out_value: false, code: 200, return_message: nil)
    )

    expect(client).to receive(:build_request)
      .with("GET", "/api/v1/pods?watch=true", auth_names: ["BearerToken"])
      .ordered
      .and_return(request_one)
    expect(client).to receive(:build_request)
      .with("GET", "/api/v1/pods?watch=true", auth_names: ["BearerToken"])
      .ordered
      .and_return(request_two)
    expect(watch).not_to receive(:sleep)

    seen_versions = []
    response = watch.connect("/api/v1/pods") do |event|
      seen_versions << event.dig("object", "metadata", "resourceVersion")
    end

    expect(response.code).to eq(200)
    expect(seen_versions).to eq(%w[25 26])
  end

  it "skips blank lines and flushes a final event without a trailing newline" do
    request = FakeWatchRequest.new(
      chunks: ["\n{\"type\":\"ADDED\",\"object\":{\"metadata\":{\"resourceVersion\":\"1\"}}}\n", "{\"type\":\"MODIFIED\",\"object\":{\"metadata\":{\"resourceVersion\":\"2\"}}}"],
      response: FakeResponse.new(success_value: true, timed_out_value: false, code: 200, return_message: nil)
    )

    allow(client).to receive(:build_request).and_return(request)

    seen_versions = []
    expect do
      watch.connect("/api/v1/pods") do |event|
        seen_versions << event.dig("object", "metadata", "resourceVersion")
      end
    end.not_to output.to_stderr

    expect(seen_versions).to eq(%w[1 2])
  end

  it "assembles a watch event that arrives across multiple chunks" do
    request = FakeWatchRequest.new(
      chunks: [
        "{\"type\":\"ADDED\",\"object\":{\"metadata\":{\"resourceVersion\":\"7\"}",
        "}}\n"
      ],
      response: FakeResponse.new(success_value: true, timed_out_value: false, code: 200, return_message: nil)
    )

    allow(client).to receive(:build_request).and_return(request)

    result = []
    watch.connect("/api/v1/pods") { |event| result << event }

    expect(result.length).to eq(1)
    expect(result.first.dig("object", "metadata", "resourceVersion")).to eq("7")
  end

  it "raises ApiError after exhausting reconnect attempts on repeated timeouts" do
    allow(client).to receive(:build_request).and_return(
      FakeWatchRequest.new(chunks: [], response: FakeResponse.new(success_value: false, timed_out_value: true, code: 0, return_message: "timeout")),
      FakeWatchRequest.new(chunks: [], response: FakeResponse.new(success_value: false, timed_out_value: true, code: 0, return_message: "timeout")),
      FakeWatchRequest.new(chunks: [], response: FakeResponse.new(success_value: false, timed_out_value: true, code: 0, return_message: "timeout")),
      FakeWatchRequest.new(chunks: [], response: FakeResponse.new(success_value: false, timed_out_value: true, code: 0, return_message: "timeout"))
    )

    expect(watch).to receive(:sleep).with(1.0).ordered
    expect(watch).to receive(:sleep).with(2.0).ordered
    expect(watch).to receive(:sleep).with(4.0).ordered

    expect do
      watch.connect("/api/v1/pods") { |_event| nil }
    end.to raise_error(Kubernetes::ApiError, /Watch connection timed out/)
  end

  it "raises ApiError after exhausting reconnect attempts on repeated 410 reset events" do
    allow(client).to receive(:build_request).and_return(
      FakeWatchRequest.new(
        chunks: ["{\"type\":\"ERROR\",\"object\":{\"kind\":\"Status\",\"code\":410,\"message\":\"too old resource version\"}}\n"],
        response: FakeResponse.new(success_value: true, timed_out_value: false, code: 200, return_message: nil)
      ),
      FakeWatchRequest.new(
        chunks: ["{\"type\":\"ERROR\",\"object\":{\"kind\":\"Status\",\"code\":410,\"message\":\"too old resource version\"}}\n"],
        response: FakeResponse.new(success_value: true, timed_out_value: false, code: 200, return_message: nil)
      ),
      FakeWatchRequest.new(
        chunks: ["{\"type\":\"ERROR\",\"object\":{\"kind\":\"Status\",\"code\":410,\"message\":\"too old resource version\"}}\n"],
        response: FakeResponse.new(success_value: true, timed_out_value: false, code: 200, return_message: nil)
      ),
      FakeWatchRequest.new(
        chunks: ["{\"type\":\"ERROR\",\"object\":{\"kind\":\"Status\",\"code\":410,\"message\":\"too old resource version\"}}\n"],
        response: FakeResponse.new(success_value: true, timed_out_value: false, code: 200, return_message: nil)
      )
    )

    expect(watch).not_to receive(:sleep)

    expect do
      watch.connect("/api/v1/pods") { |_event| nil }
    end.to raise_error(Kubernetes::ApiError) do |error|
      expect(error.code).to eq(410)
      expect(error.message).to include("Watch resource version expired")
    end
  end
end

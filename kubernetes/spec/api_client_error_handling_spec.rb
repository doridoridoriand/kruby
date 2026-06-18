# frozen_string_literal: true

require "spec_helper"

RSpec.describe Kubernetes::ApiClient do
  let(:config) { Kubernetes::Configuration.new }
  let(:api_client) { described_class.new(config) }
  let(:request) { instance_double(Typhoeus::Request) }

  def stub_response(response)
    allow(request).to receive(:run).and_return(response)
    allow(api_client).to receive(:build_request).and_return(request)
  end

  describe "#call_api" do
    {
      400 => "Bad Request",
      401 => "Unauthorized",
      403 => "Forbidden",
      429 => "Too Many Requests",
      502 => "Bad Gateway",
      503 => "Service Unavailable"
    }.each do |status, status_message|
      it "raises ApiError for HTTP #{status}" do
        response = instance_double(
          Typhoeus::Response,
          success?: false,
          timed_out?: false,
          code: status,
          status_message: status_message,
          headers: { "Content-Type" => "application/json" },
          body: %({"message":"#{status_message.downcase}"})
        )
        stub_response(response)

        expect do
          api_client.call_api(:get, "/api/v1/pods")
        end.to raise_error(Kubernetes::ApiError) do |error|
          expect(error.code).to eq(status)
          expect(error.response_body).to eq(%({"message":"#{status_message.downcase}"}))
          expect(error.response_headers).to eq("Content-Type" => "application/json")
        end
      end
    end

    it "surfaces a raw non-JSON error body for upstream HTTP failures" do
      response = instance_double(
        Typhoeus::Response,
        success?: false,
        timed_out?: false,
        code: 502,
        status_message: "Bad Gateway",
        headers: { "Content-Type" => "text/html" },
        body: "<html>proxy error</html>"
      )
      stub_response(response)

      expect do
        api_client.call_api(:get, "/api/v1/pods")
      end.to raise_error(Kubernetes::ApiError) do |error|
        expect(error.code).to eq(502)
        expect(error.response_body).to eq("<html>proxy error</html>")
      end
    end

    it "returns nil data for an empty response body even when return_type is specified" do
      response = instance_double(
        Typhoeus::Response,
        success?: true,
        code: 200,
        headers: { "Content-Type" => "application/json" },
        body: ""
      )
      stub_response(response)

      data, status, headers = api_client.call_api(:get, "/api/v1/pods", return_type: "Hash<String, String>")

      expect(data).to be_nil
      expect(status).to eq(200)
      expect(headers).to eq("Content-Type" => "application/json")
    end

    it "raises JSON::ParserError for malformed JSON success responses" do
      response = instance_double(
        Typhoeus::Response,
        success?: true,
        code: 200,
        headers: { "Content-Type" => "application/json" },
        body: '{"items": [}'
      )
      stub_response(response)

      expect do
        api_client.call_api(:get, "/api/v1/pods", return_type: "Hash<String, String>")
      end.to raise_error(JSON::ParserError)
    end

    it "raises an error for unsupported success response content types" do
      response = instance_double(
        Typhoeus::Response,
        success?: true,
        code: 200,
        headers: { "Content-Type" => "text/plain" },
        body: "ok"
      )
      stub_response(response)

      expect do
        api_client.call_api(:get, "/api/v1/pods", return_type: "Hash<String, String>")
      end.to raise_error(/Content-Type is not supported/)
    end

    it "raises ApiError on read timeout" do
      response = instance_double(
        Typhoeus::Response,
        success?: false,
        timed_out?: true,
        code: 0,
        return_message: "Operation timed out after 1000 milliseconds with 0 bytes received"
      )
      stub_response(response)

      expect do
        api_client.call_api(:get, "/api/v1/pods")
      end.to raise_error(Kubernetes::ApiError, /Connection timed out/)
    end

    it "raises ApiError on DNS resolution failures" do
      response = instance_double(
        Typhoeus::Response,
        success?: false,
        timed_out?: false,
        code: 0,
        return_message: "Couldn't resolve host name"
      )
      stub_response(response)

      expect do
        api_client.call_api(:get, "/api/v1/pods")
      end.to raise_error(Kubernetes::ApiError) do |error|
        expect(error.code).to eq(0)
        expect(error.message).to include("Couldn't resolve host name")
      end
    end

    it "raises ApiError when the upstream connection is reset" do
      response = instance_double(
        Typhoeus::Response,
        success?: false,
        timed_out?: false,
        code: 0,
        return_message: "Recv failure: Connection reset by peer"
      )
      stub_response(response)

      expect do
        api_client.call_api(:get, "/api/v1/pods")
      end.to raise_error(Kubernetes::ApiError) do |error|
        expect(error.code).to eq(0)
        expect(error.message).to include("Connection reset by peer")
      end
    end
  end
end

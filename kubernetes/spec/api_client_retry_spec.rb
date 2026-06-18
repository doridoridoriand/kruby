# frozen_string_literal: true

require "spec_helper"

RSpec.describe Kubernetes::ApiClient do
  let(:logger) { instance_double(Logger, info: nil, debug: nil) }
  let(:config) do
    Kubernetes::Configuration.new.tap do |value|
      value.logger = logger
      value.retry_configuration = {
        max_retries: 4,
        base_interval_seconds: 1.0,
        retry_statuses: [429, 500, 501, 502, 503]
      }
    end
  end
  let(:api_client) { described_class.new(config) }

  def request_for(response)
    instance_double(Typhoeus::Request, run: response)
  end

  def error_response(code, status_message: "Temporary Failure", body: '{"message":"retry me"}', headers: { "Content-Type" => "application/json" })
    instance_double(
      Typhoeus::Response,
      success?: false,
      timed_out?: false,
      code: code,
      status_message: status_message,
      headers: headers,
      body: body
    )
  end

  def success_response(body: '{"message":"ok"}')
    instance_double(
      Typhoeus::Response,
      success?: true,
      code: 200,
      headers: { "Content-Type" => "application/json" },
      body: body
    )
  end

  describe "#call_api" do
    [429, 500, 501, 502, 503].each do |status|
      it "retries HTTP #{status} and returns the eventual success response" do
        allow(api_client).to receive(:build_request).and_return(
          request_for(error_response(status, status_message: "HTTP #{status}")),
          request_for(success_response)
        )
        allow(api_client).to receive(:sleep)

        data, response_status, = api_client.call_api(:get, "/api/v1/pods", return_type: "Hash<String, String>")

        expect(data).to eq(message: "ok")
        expect(response_status).to eq(200)
        expect(api_client).to have_received(:build_request).twice
        expect(api_client).to have_received(:sleep).with(1.0).once
      end
    end

    it "raises the final ApiError after the configured retry limit is reached" do
      allow(api_client).to receive(:build_request).and_return(
        request_for(error_response(503, status_message: "Service Unavailable")),
        request_for(error_response(503, status_message: "Service Unavailable")),
        request_for(error_response(503, status_message: "Service Unavailable")),
        request_for(error_response(503, status_message: "Service Unavailable")),
        request_for(error_response(503, status_message: "Service Unavailable"))
      )
      allow(api_client).to receive(:sleep)

      expect do
        api_client.call_api(:get, "/api/v1/pods")
      end.to raise_error(Kubernetes::ApiError) do |error|
        expect(error.code).to eq(503)
        expect(error.response_body).to eq('{"message":"retry me"}')
      end

      expect(api_client).to have_received(:build_request).exactly(5).times
      expect(api_client).to have_received(:sleep).exactly(4).times
    end

    it "uses exponential backoff intervals of 1, 2, 4, and 8 seconds" do
      allow(api_client).to receive(:build_request).and_return(
        request_for(error_response(503)),
        request_for(error_response(503)),
        request_for(error_response(503)),
        request_for(error_response(503)),
        request_for(success_response)
      )

      expect(api_client).to receive(:sleep).with(1.0).ordered
      expect(api_client).to receive(:sleep).with(2.0).ordered
      expect(api_client).to receive(:sleep).with(4.0).ordered
      expect(api_client).to receive(:sleep).with(8.0).ordered

      data, response_status, = api_client.call_api(:get, "/api/v1/pods", return_type: "Hash<String, String>")

      expect(data).to eq(message: "ok")
      expect(response_status).to eq(200)
    end

    it "logs retry attempts at info and debug levels" do
      config.debugging = true
      allow(api_client).to receive(:build_request).and_return(
        request_for(error_response(503, body: '{"message":"please retry"}')),
        request_for(success_response)
      )
      allow(api_client).to receive(:sleep)

      api_client.call_api(:get, "/api/v1/pods", return_type: "Hash<String, String>")

      expect(logger).to have_received(:info)
        .with(include("HTTP 503", "retry 1/4", "1.0 seconds"))
      expect(logger).to have_received(:debug)
        .with(include("Retry response body:", '{"message":"please retry"}'))
    end

    it "does not emit retry response body logs when debugging is disabled" do
      allow(api_client).to receive(:build_request).and_return(
        request_for(error_response(503, body: '{"message":"please retry"}')),
        request_for(success_response)
      )
      allow(api_client).to receive(:sleep)

      api_client.call_api(:get, "/api/v1/pods", return_type: "Hash<String, String>")

      expect(logger).to have_received(:info)
      expect(logger).not_to have_received(:debug)
    end

    it "honors Retry-After response headers when they exceed the exponential backoff" do
      allow(api_client).to receive(:build_request).and_return(
        request_for(error_response(429, headers: { "Content-Type" => "application/json", "Retry-After" => "5" })),
        request_for(success_response)
      )

      expect(api_client).to receive(:sleep).with(5.0).ordered

      data, response_status, = api_client.call_api(:get, "/api/v1/pods", return_type: "Hash<String, String>")

      expect(data).to eq(message: "ok")
      expect(response_status).to eq(200)
    end

    it "honors status details.retryAfterSeconds when present in the response body" do
      allow(api_client).to receive(:build_request).and_return(
        request_for(error_response(503, body: '{"details":{"retryAfterSeconds":6}}')),
        request_for(success_response)
      )

      expect(api_client).to receive(:sleep).with(6.0).ordered

      data, response_status, = api_client.call_api(:get, "/api/v1/pods", return_type: "Hash<String, String>")

      expect(data).to eq(message: "ok")
      expect(response_status).to eq(200)
    end

    it "clamps negative retry intervals to zero seconds" do
      config.retry_configuration[:base_interval_seconds] = -1
      allow(api_client).to receive(:build_request).and_return(
        request_for(error_response(503)),
        request_for(success_response)
      )

      expect(api_client).to receive(:sleep).with(0.0).ordered

      data, response_status, = api_client.call_api(:get, "/api/v1/pods", return_type: "Hash<String, String>")

      expect(data).to eq(message: "ok")
      expect(response_status).to eq(200)
    end

    it "does not retry non-retryable HTTP statuses" do
      allow(api_client).to receive(:build_request).and_return(
        request_for(error_response(404, status_message: "Not Found"))
      )
      allow(api_client).to receive(:sleep)

      expect do
        api_client.call_api(:get, "/api/v1/pods")
      end.to raise_error(Kubernetes::ApiError) do |error|
        expect(error.code).to eq(404)
      end

      expect(api_client).to have_received(:build_request).once
      expect(api_client).not_to have_received(:sleep)
    end
  end
end

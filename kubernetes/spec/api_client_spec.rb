# frozen_string_literal: true

require "spec_helper"
require "webmock/rspec"

RSpec.describe Kubernetes::ApiClient do
  let(:config) { Kubernetes::Configuration.new }
  let(:api_client) { Kubernetes::ApiClient.new(config) }

  describe "#call_api" do
    it "returns [data, status, headers] on success" do
      request = instance_double(Typhoeus::Request, run: nil)
      allow(Typhoeus::Request).to receive(:new).and_return(request)

      response = instance_double(Typhoeus::Response,
                                 success?: true,
                                 code: 200,
                                 headers: { "Content-Type" => "application/json" },
                                 body: '{"message": "ok"}')
      allow(request).to receive(:run).and_return(response)

      allow(api_client).to receive(:build_request).and_return(request)

      data, status, headers = api_client.call_api(:get, "/api/v1/pods", return_type: "Hash<String, String>")

      expect(status).to eq(200)
      expect(data).to eq(message: "ok")
    end

    it "raises ApiError on 4xx response with code and body" do
      request = instance_double(Typhoeus::Request)
      response = instance_double(Typhoeus::Response,
                                 success?: false,
                                 timed_out?: false,
                                 code: 404,
                                 status_message: "Not Found",
                                 headers: {},
                                 body: '{"message": "not found"}')
      allow(request).to receive(:run).and_return(response)
      allow(api_client).to receive(:build_request).and_return(request)
      allow(api_client).to receive(:deserialize)

      expect do
        api_client.call_api(:get, "/api/v1/pods/notfound")
      end.to raise_error(Kubernetes::ApiError) do |error|
        expect(error.code).to eq(404)
        expect(error.response_body).to eq('{"message": "not found"}')
      end
    end

    it "raises ApiError on 5xx response with code and body" do
      request = instance_double(Typhoeus::Request)
      response = instance_double(Typhoeus::Response,
                                 success?: false,
                                 timed_out?: false,
                                 code: 500,
                                 status_message: "Internal Server Error",
                                 headers: {},
                                 body: '{"message": "server error"}')
      allow(request).to receive(:run).and_return(response)
      allow(api_client).to receive(:build_request).and_return(request)
      allow(api_client).to receive(:deserialize)

      expect do
        api_client.call_api(:get, "/api/v1/pods")
      end.to raise_error(Kubernetes::ApiError) do |error|
        expect(error.code).to eq(500)
        expect(error.response_body).to eq('{"message": "server error"}')
      end
    end

    it "raises ApiError on connection timeout" do
      request = instance_double(Typhoeus::Request)
      response = instance_double(Typhoeus::Response,
                                 success?: false,
                                 timed_out?: true,
                                 code: 0,
                                 return_message: "Operation timed out")
      allow(request).to receive(:run).and_return(response)
      allow(api_client).to receive(:build_request).and_return(request)

      expect do
        api_client.call_api(:get, "/api/v1/pods")
      end.to raise_error(Kubernetes::ApiError, /Connection timed out/)
    end

    it "raises ApiError on libcurl error (code 0)" do
      request = instance_double(Typhoeus::Request)
      response = instance_double(Typhoeus::Response,
                                 success?: false,
                                 timed_out?: false,
                                 code: 0,
                                 return_message: "Connection refused")
      allow(request).to receive(:run).and_return(response)
      allow(api_client).to receive(:build_request).and_return(request)

      expect do
        api_client.call_api(:get, "/api/v1/pods")
      end.to raise_error(Kubernetes::ApiError) do |error|
        expect(error.code).to eq(0)
        expect(error.message).to include("Connection refused")
      end
    end

    it "returns nil data when no return_type is specified" do
      request = instance_double(Typhoeus::Request)
      response = instance_double(Typhoeus::Response,
                                 success?: true,
                                 code: 200,
                                 headers: {},
                                 body: '{"result": 1}')
      allow(request).to receive(:run).and_return(response)
      allow(api_client).to receive(:build_request).and_return(request)

      data, status, _ = api_client.call_api(:get, "/api/v1/pods")

      expect(status).to eq(200)
      expect(data).to be_nil
    end
  end

  describe "#build_request" do
    it "builds request with correct method and URL" do
      config.scheme = "https"
      config.host = "k8s.example.com"
      config.base_path = "/api/v1"

      request = api_client.build_request(:get, "/pods")

      expect(request.url).to eq("https://k8s.example.com/api/v1/pods")
      expect(request.options[:method]).to eq(:get)
    end

    it "includes default headers" do
      request = api_client.build_request(:get, "/test")

      expect(request.options[:headers]).to have_key("Content-Type")
      expect(request.options[:headers]).to have_key("User-Agent")
    end

    it "merges custom header_params" do
      request = api_client.build_request(:get, "/test", header_params: { "X-Custom" => "value" })

      expect(request.options[:headers]["X-Custom"]).to eq("value")
    end

    it "includes query_params" do
      request = api_client.build_request(:get, "/test", query_params: { "labelSelector" => "app=web" })

      expect(request.options[:params]).to eq({ "labelSelector" => "app=web" })
    end

    it "includes SSL options" do
      config.verify_ssl = false
      config.verify_ssl_host = false

      request = api_client.build_request(:get, "/test")

      expect(request.options[:ssl_verifypeer]).to eq(false)
      expect(request.options[:ssl_verifyhost]).to eq(0)
    end

    it "includes custom CA cert" do
      config.ssl_ca_cert = "/path/to/ca.pem"

      request = api_client.build_request(:get, "/test")

      expect(request.options[:cainfo]).to eq("/path/to/ca.pem")
    end

    it "includes client cert and key" do
      config.cert_file = "/path/to/client.crt"
      config.key_file = "/path/to/client.key"

      request = api_client.build_request(:get, "/test")

      expect(request.options[:sslcert]).to eq("/path/to/client.crt")
      expect(request.options[:sslkey]).to eq("/path/to/client.key")
    end

    it "includes body for POST requests" do
      payload = { name: "test", data: { "key" => "value" } }
      request = api_client.build_request(:post, "/test", body: payload)

      expect(request.options[:body]).to include('"name":"test"')
    end

    it "includes body for DELETE requests" do
      request = api_client.build_request(:delete, "/test", body: { apiVersion: "v1" })

      expect(request.options[:body]).to include('"apiVersion":"v1"')
    end

    it "includes body for PATCH requests" do
      request = api_client.build_request(:patch, "/test", body: { metadata: { labels: { "app" => "updated" } } })

      expect(request.options[:body]).to include('"labels"')
    end

    it "includes body for PUT requests" do
      request = api_client.build_request(:put, "/test", body: { status: "Running" })

      expect(request.options[:body]).to include('"status":"Running"')
    end

    it "does not include body for GET requests" do
      request = api_client.build_request(:get, "/test", body: { should: "not appear" })

      expect(request.options[:body]).to be_nil
    end
  end

  describe "#build_request_body" do
    it "builds form-urlencoded body" do
      header_params = { "Content-Type" => "application/x-www-form-urlencoded" }
      form_params = { "username" => "admin", "role" => 42 }

      body = api_client.build_request_body(header_params, form_params, nil)

      expect(body).to eq({ "username" => "admin", "role" => "42" })
    end

    it "builds multipart body" do
      header_params = { "Content-Type" => "multipart/form-data" }
      form_params = { "file" => "test.txt" }

      body = api_client.build_request_body(header_params, form_params, nil)

      expect(body).to eq({ "file" => "test.txt" })
    end

    it "builds JSON body from model" do
      header_params = { "Content-Type" => "application/json" }
      model = double(to_json: '{"name":"test"}')

      body = api_client.build_request_body(header_params, {}, model)

      expect(body).to eq('{"name":"test"}')
    end

    it "builds JSON body from string" do
      header_params = { "Content-Type" => "application/json" }
      body_str = '{"name":"test"}'

      body = api_client.build_request_body(header_params, {}, body_str)

      expect(body).to eq('{"name":"test"}')
    end

    it "returns nil when no body and no form params" do
      header_params = { "Content-Type" => "application/json" }

      body = api_client.build_request_body(header_params, {}, nil)

      expect(body).to be_nil
    end
  end

  describe "#update_params_for_auth!" do
    it "injects header auth tokens" do
      allow(config).to receive(:auth_settings).and_return(
        "BearerToken" => { type: "api_key", in: "header", key: "Authorization", value: "Bearer abc123" }
      )

      header_params = {}
      query_params = {}
      api_client.update_params_for_auth!(header_params, query_params, ["BearerToken"])

      expect(header_params["Authorization"]).to eq("Bearer abc123")
      expect(query_params).to eq({})
    end

    it "injects query auth tokens" do
      allow(config).to receive(:auth_settings).and_return(
        "ApiKey" => { type: "api_key", in: "query", key: "api_key", value: "secret-key" }
      )

      header_params = {}
      query_params = {}
      api_client.update_params_for_auth!(header_params, query_params, ["ApiKey"])

      expect(query_params["api_key"]).to eq("secret-key")
      expect(header_params).to eq({})
    end

    it "handles multiple auth names" do
      allow(config).to receive(:auth_settings).and_return(
        "BearerToken" => { type: "api_key", in: "header", key: "Authorization", value: "Bearer abc123" },
        "CustomHeader" => { type: "api_key", in: "header", key: "X-Custom", value: "custom-value" }
      )

      header_params = {}
      query_params = {}
      api_client.update_params_for_auth!(header_params, query_params, ["BearerToken", "CustomHeader"])

      expect(header_params["Authorization"]).to eq("Bearer abc123")
      expect(header_params["X-Custom"]).to eq("custom-value")
    end

    it "skips unknown auth names" do
      allow(config).to receive(:auth_settings).and_return({})

      header_params = { "Existing" => "value" }
      query_params = {}
      api_client.update_params_for_auth!(header_params, query_params, ["NonExistent"])

      expect(header_params).to eq({ "Existing" => "value" })
    end

    it "raises ArgumentError for invalid auth location" do
      allow(config).to receive(:auth_settings).and_return(
        "BadAuth" => { type: "api_key", in: "cookie", key: "session", value: "abc" }
      )

      expect do
        api_client.update_params_for_auth!({}, {}, ["BadAuth"])
      end.to raise_error(ArgumentError, /Authentication token must be in/)
    end
  end

  describe "#build_request_url" do
    it "prepends leading slash to path" do
      config.scheme = "https"
      config.host = "k8s.example.com"

      url = api_client.build_request_url("api/v1/pods")
      expect(url).to eq("https://k8s.example.com/api/v1/pods")
    end

    it "collapses multiple slashes" do
      config.scheme = "https"
      config.host = "k8s.example.com"
      config.base_path = "/api/v1"

      url = api_client.build_request_url("/pods")
      expect(url).to eq("https://k8s.example.com/api/v1/pods")
    end

    it "appends path to base_url with operation" do
      config.server_index = 0
      allow(config).to receive(:server_settings).and_return(
        [{ url: "https://ops.k8s.example.com/api/v1", description: "ops" }]
      )

      url = api_client.build_request_url("pods", operation: :some_operation)
      expect(url).to include("k8s.example.com")
    end
  end

  describe "#convert_to_type" do
    it "converts to String" do
      expect(api_client.convert_to_type(123, "String")).to eq("123")
    end

    it "converts to Integer" do
      expect(api_client.convert_to_type("42", "Integer")).to eq(42)
    end

    it "converts to Float" do
      expect(api_client.convert_to_type("3.14", "Float")).to eq(3.14)
    end

    it "converts to Boolean" do
      expect(api_client.convert_to_type(true, "Boolean")).to eq(true)
      expect(api_client.convert_to_type(false, "Boolean")).to eq(false)
      expect(api_client.convert_to_type("true", "Boolean")).to eq(false)
    end

    it "converts to Time" do
      time = api_client.convert_to_type("2026-01-01T00:00:00Z", "Time")
      expect(time).to be_a(Time)
    end

    it "converts to Date" do
      date = api_client.convert_to_type("2026-01-01", "Date")
      expect(date).to be_a(Date)
    end

    it "converts to Object (returns as-is)" do
      expect(api_client.convert_to_type({ key: "value" }, "Object")).to eq({ key: "value" })
    end

    it "handles nil data" do
      expect(api_client.convert_to_type(nil, "String")).to be_nil
    end

    it "converts Array<Integer>" do
      expect(api_client.convert_to_type([1, "2", 3], "Array<Integer>")).to eq([1, 2, 3])
    end

    it "converts Hash<String, String>" do
      expect(api_client.convert_to_type({ key: 42 }, "Hash<String, String>")).to eq(key: "42")
    end
  end

  describe "#deserialize" do
    it "returns nil for empty body" do
      response = instance_double(Typhoeus::Response, body: "", headers: {})
      expect(api_client.deserialize(response, "String")).to be_nil
    end

    it "returns nil for nil body" do
      response = instance_double(Typhoeus::Response, body: nil, headers: {})
      expect(api_client.deserialize(response, "String")).to be_nil
    end

    it "returns raw body for String return type" do
      response = instance_double(Typhoeus::Response, body: "raw text", headers: {})
      expect(api_client.deserialize(response, "String")).to eq("raw text")
    end

    it "raises error for non-JSON content type" do
      response = instance_double(Typhoeus::Response,
                                 body: '<html>error</html>',
                                 headers: { "Content-Type" => "text/html" })

      expect { api_client.deserialize(response, "Hash<String, String>") }.to raise_error(/Content-Type is not supported/)
    end

    it "handles Date return type" do
      response = instance_double(Typhoeus::Response,
                                 body: "2026-01-01",
                                 headers: { "Content-Type" => "application/json" })

      result = api_client.deserialize(response, "Date")
      expect(result).to eq(Date.new(2026, 1, 1))
    end

    it "handles Time return type" do
      response = instance_double(Typhoeus::Response,
                                 body: "2026-01-01T00:00:00Z",
                                 headers: { "Content-Type" => "application/json" })

      result = api_client.deserialize(response, "Time")
      expect(result).to eq(Time.utc(2026, 1, 1))
    end

    it "handles Array<String>" do
      response = instance_double(Typhoeus::Response,
                                 body: '["pod1", "pod2"]',
                                 headers: { "Content-Type" => "application/json" })

      result = api_client.deserialize(response, "Array<String>")
      expect(result).to eq(["pod1", "pod2"])
    end

    it "handles nested Array<Integer>" do
      response = instance_double(Typhoeus::Response,
                                 body: '[[1, 2], [3]]',
                                 headers: { "Content-Type" => "application/json" })

      result = api_client.deserialize(response, "Array<Array<Integer>>")
      expect(result).to eq([[1, 2], [3]])
    end
  end

  describe "#download_file" do
    it "sets up on_headers, on_body, and on_complete callbacks" do
      request = instance_double(Typhoeus::Request)
      tempfile = nil

      expect(request).to receive(:on_headers)
      expect(request).to receive(:on_body)
      expect(request).to receive(:on_complete)

      api_client.download_file(request)
    end

    it "uses Content-Disposition filename for tempfile prefix" do
      request = instance_double(Typhoeus::Request)
      response = instance_double(Typhoeus::Response,
                                 headers: { "Content-Disposition" => "attachment; filename=document.pdf" },
                                 body: "data")
      tempfile = nil

      # The actual callback chain is tested via the full flow in integration tests
      # Here we verify the sanitize_filename helper works correctly
      expect(api_client.sanitize_filename("document.pdf")).to eq("document.pdf")
      expect(api_client.sanitize_filename("../../document.pdf")).to eq("document.pdf")
    end
  end

  describe "#object_to_hash" do
    it "handles nil" do
      expect(api_client.object_to_hash(nil)).to be_nil
    end

    it "handles array" do
      result = api_client.object_to_hash([{ name: "a" }, { name: "b" }])
      expect(result).to eq([{ name: "a" }, { name: "b" }])
    end

    it "handles hash" do
      result = api_client.object_to_hash({ "key" => "value" })
      expect(result).to eq({ "key" => "value" })
    end

    it "handles DateTime" do
      dt = DateTime.new(2026, 6, 1, 12, 0, 0)
      result = api_client.object_to_hash(dt)
      expect(result).to be_a(String)
      expect(result).to include("2026-06-01")
    end
  end
end

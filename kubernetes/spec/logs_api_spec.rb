# frozen_string_literal: true

require "spec_helper"
require "webmock/rspec"

RSpec.describe Kubernetes::LogsApi do
  let(:config) do
    Kubernetes::Configuration.new.tap do |c|
      c.scheme = "https"
      c.host = "k8s.example.com"
      c.base_path = ""
    end
  end
  let(:api_client) { Kubernetes::ApiClient.new(config) }
  let(:api) { Kubernetes::LogsApi.new(api_client) }

  describe "#log_file_handler" do
    it "returns nil with a successful response" do
      WebMock.stub_request(:get, "https://k8s.example.com/logs/var%2Flog%2Fmyfile.log")
        .to_return(status: 200, body: "2024-01-01 00:00:00 INFO Starting application")

      result, status, _ = api.log_file_handler_with_http_info("var/log/myfile.log")
      expect(status).to eq(200)
      expect(result).to be_nil
    end

    it "returns nil for log_file_handler" do
      WebMock.stub_request(:get, "https://k8s.example.com/logs/var%2Flog%2Fmyfile.log")
        .to_return(status: 200, body: "some log content")

      result = api.log_file_handler("var/log/myfile.log")
      expect(result).to be_nil
    end

    it "raises ApiError on 404" do
      WebMock.stub_request(:get, "https://k8s.example.com/logs/var%2Flog%2Fnotfound.log")
        .to_return(status: 404, body: { message: "not found", reason: "NotFound" }.to_json)

      expect { api.log_file_handler("var/log/notfound.log") }.to raise_error(Kubernetes::ApiError) do |e|
        expect(e.code).to eq(404)
      end
    end

    it "raises ApiError on 403 forbidden" do
      WebMock.stub_request(:get, "https://k8s.example.com/logs/secure%2Ffile.log")
        .to_return(status: 403, body: { message: "forbidden", reason: "Forbidden" }.to_json)

      expect { api.log_file_handler("secure/file.log") }.to raise_error(Kubernetes::ApiError) do |e|
        expect(e.code).to eq(403)
      end
    end

    it "raises ArgumentError when logpath is nil" do
      api.api_client.config.client_side_validation = true
      expect { api.log_file_handler(nil) }.to raise_error(ArgumentError, /logpath/)
    end
  end

  describe "#log_file_list_handler" do
    it "returns nil with a successful response" do
      response = { directories: ["a/", "b/"], files: ["file1.log", "file2.log"] }
      WebMock.stub_request(:get, "https://k8s.example.com/logs/")
        .to_return(status: 200, body: response.to_json)

      result, status, _ = api.log_file_list_handler_with_http_info
      expect(status).to eq(200)
      expect(result).to be_nil
    end

    it "raises ApiError on 500" do
      WebMock.stub_request(:get, "https://k8s.example.com/logs/")
        .to_return(status: 500, body: { message: "internal error" }.to_json)

      expect { api.log_file_list_handler }.to raise_error(Kubernetes::ApiError) do |e|
        expect(e.code).to eq(500)
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"
require "webmock/rspec"

RSpec.describe Kubernetes::VersionApi do
  let(:config) do
    Kubernetes::Configuration.new.tap do |c|
      c.scheme = "https"
      c.host = "k8s.example.com"
      c.base_path = ""
    end
  end
  let(:api_client) { Kubernetes::ApiClient.new(config) }
  let(:api) { Kubernetes::VersionApi.new(api_client) }

  describe "#get_code" do
    it "returns version information on success" do
      response = {
        major: "1",
        minor: "36",
        gitVersion: "v1.36.0",
        gitCommit: "abc123",
        platform: "linux/amd64"
      }
      WebMock.stub_request(:get, "https://k8s.example.com/version/")
        .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })

      result, status, _ = api.get_code_with_http_info
      expect(status).to eq(200)
      expect(result).to be_a(Kubernetes::VersionInfo)
      expect(result.major).to eq("1")
      expect(result.minor).to eq("36")
      expect(result.git_version).to eq("v1.36.0")
    end

    it "returns VersionInfo with all fields" do
      response = {
        major: "1",
        minor: "36",
        gitVersion: "v1.36.1",
        gitCommit: "def456",
        gitTreeState: "clean",
        buildDate: "2026-06-01T00:00:00Z",
        goVersion: "go1.22",
        compiler: "gc",
        platform: "linux/amd64"
      }
      WebMock.stub_request(:get, "https://k8s.example.com/version/")
        .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })

      result = api.get_code
      expect(result.major).to eq("1")
      expect(result.minor).to eq("36")
      expect(result.git_version).to eq("v1.36.1")
      expect(result.platform).to eq("linux/amd64")
    end

    it "raises ApiError on 500" do
      WebMock.stub_request(:get, "https://k8s.example.com/version/")
        .to_return(status: 500, body: { message: "server error" }.to_json)

      expect { api.get_code }.to raise_error(Kubernetes::ApiError) do |e|
        expect(e.code).to eq(500)
      end
    end

    it "raises ApiError on 503 service unavailable" do
      WebMock.stub_request(:get, "https://k8s.example.com/version/")
        .to_return(status: 503, body: "")

      expect { api.get_code }.to raise_error(Kubernetes::ApiError) do |e|
        expect(e.code).to eq(503)
      end
    end

    it "raises ApiError on connection timeout" do
      WebMock.stub_request(:get, "https://k8s.example.com/version/")
        .to_timeout

      expect { api.get_code }.to raise_error(Kubernetes::ApiError)
    end
  end
end

# frozen_string_literal: true

require "spec_helper"
require "webmock/rspec"

RSpec.describe Kubernetes::DiscoveryApi do
  let(:config) do
    Kubernetes::Configuration.new.tap do |c|
      c.scheme = "https"
      c.host = "k8s.example.com"
      c.base_path = ""
    end
  end
  let(:api_client) { Kubernetes::ApiClient.new(config) }
  let(:api) { Kubernetes::DiscoveryApi.new(api_client) }

  describe "#get_api_group_get_apis_discovery_k8s_io" do
    it "returns API group information on success" do
      response = {
        apiVersion: "v1",
        kind: "APIGroup",
        name: "discovery.k8s.io",
        versions: [{ groupVersion: "discovery.k8s.io/v1", version: "v1" }],
        preferredVersion: { groupVersion: "discovery.k8s.io/v1", version: "v1" }
      }
      WebMock.stub_request(:get, "https://k8s.example.com/apis/discovery.k8s.io/")
        .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })

      result, status, _ = api.get_api_group_get_apis_discovery_k8s_io_with_http_info
      expect(status).to eq(200)
      expect(result).to be_a(Kubernetes::V1APIGroup)
      expect(result.name).to eq("discovery.k8s.io")
    end

    it "raises ApiError on 403 forbidden" do
      WebMock.stub_request(:get, "https://k8s.example.com/apis/discovery.k8s.io/")
        .to_return(status: 403, body: { message: "forbidden", reason: "Forbidden" }.to_json)

      expect { api.get_api_group_get_apis_discovery_k8s_io }.to raise_error(Kubernetes::ApiError) do |e|
        expect(e.code).to eq(403)
      end
    end

    it "raises ApiError on 404" do
      WebMock.stub_request(:get, "https://k8s.example.com/apis/discovery.k8s.io/")
        .to_return(status: 404, body: { message: "not found", reason: "NotFound" }.to_json)

      expect { api.get_api_group_get_apis_discovery_k8s_io }.to raise_error(Kubernetes::ApiError) do |e|
        expect(e.code).to eq(404)
      end
    end

    it "raises ApiError on 500" do
      WebMock.stub_request(:get, "https://k8s.example.com/apis/discovery.k8s.io/")
        .to_return(status: 500, body: { message: "server error" }.to_json)

      expect { api.get_api_group_get_apis_discovery_k8s_io }.to raise_error(Kubernetes::ApiError) do |e|
        expect(e.code).to eq(500)
      end
    end

    it "returns V1APIGroup with correct structure" do
      response = {
        apiVersion: "v1",
        kind: "APIGroup",
        name: "discovery.k8s.io",
        versions: [
          { groupVersion: "discovery.k8s.io/v1", version: "v1" },
          { groupVersion: "discovery.k8s.io/v1beta1", version: "v1beta1" }
        ],
        preferredVersion: { groupVersion: "discovery.k8s.io/v1", version: "v1" }
      }
      WebMock.stub_request(:get, "https://k8s.example.com/apis/discovery.k8s.io/")
        .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })

      result = api.get_api_group_get_apis_discovery_k8s_io
      expect(result.name).to eq("discovery.k8s.io")
      expect(result.versions.length).to eq(2)
      expect(result.preferred_version.group_version).to eq("discovery.k8s.io/v1")
    end
  end
end

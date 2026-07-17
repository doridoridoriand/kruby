# frozen_string_literal: true

require "spec_helper"
require "webmock/rspec"

RSpec.describe Kubernetes::WellKnownApi do
  let(:config) do
    Kubernetes::Configuration.new.tap do |c|
      c.scheme = "https"
      c.host = "k8s.example.com"
      c.base_path = ""
    end
  end
  let(:api_client) { Kubernetes::ApiClient.new(config) }
  let(:api) { Kubernetes::WellKnownApi.new(api_client) }

  describe "#get_service_account_issuer_open_id_configuration" do
    it "returns OIDC discovery document on success" do
      response = {
        issuer: "https://k8s.example.com",
        jwks_uri: "https://k8s.example.com/.well-known/jwks",
        response_types_supported: ["id_token"],
        subject_types_supported: ["public"]
      }
      expected_json = response.to_json
      WebMock.stub_request(:get, "https://k8s.example.com/.well-known/openid-configuration")
        .to_return(status: 200, body: expected_json)

      result, status, _ = api.get_service_account_issuer_open_id_configuration_with_http_info
      expect(status).to eq(200)
      expect(result).to be_a(String)
      expect(result).to include("issuer")
      expect(result).to include("k8s.example.com")
    end

    it "returns raw string response" do
      response = { issuer: "https://k8s.example.com", jwks_uri: "https://k8s.example.com/.well-known/jwks" }
      WebMock.stub_request(:get, "https://k8s.example.com/.well-known/openid-configuration")
        .to_return(status: 200, body: response.to_json)

      result = api.get_service_account_issuer_open_id_configuration
      expect(result).to be_a(String)
    end

    it "raises ApiError on 404" do
      WebMock.stub_request(:get, "https://k8s.example.com/.well-known/openid-configuration")
        .to_return(status: 404, body: { message: "not found", reason: "NotFound" }.to_json)

      expect { api.get_service_account_issuer_open_id_configuration }.to raise_error(Kubernetes::ApiError) do |e|
        expect(e.code).to eq(404)
      end
    end

    it "raises ApiError on 401 unauthorized" do
      WebMock.stub_request(:get, "https://k8s.example.com/.well-known/openid-configuration")
        .to_return(status: 401, body: { message: "unauthorized", reason: "Unauthorized" }.to_json)

      expect { api.get_service_account_issuer_open_id_configuration }.to raise_error(Kubernetes::ApiError) do |e|
        expect(e.code).to eq(401)
      end
    end

    it "raises ApiError on 500" do
      WebMock.stub_request(:get, "https://k8s.example.com/.well-known/openid-configuration")
        .to_return(status: 500, body: { message: "server error" }.to_json)

      expect { api.get_service_account_issuer_open_id_configuration }.to raise_error(Kubernetes::ApiError) do |e|
        expect(e.code).to eq(500)
      end
    end
  end
end

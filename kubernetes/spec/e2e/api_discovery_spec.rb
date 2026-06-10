# frozen_string_literal: true

require "spec_helper"

RSpec.describe SpecSupport::E2E::ApiDiscovery do
  let(:api_client) { instance_double(Kubernetes::ApiClient) }
  let(:discovery) { described_class.new(api_client) }

  def stub_discovery(group, version, resources)
    path = group == "core" ? "/api/#{version}" : "/apis/#{group}/#{version}"
    body = JSON.generate("resources" => resources)

    allow(api_client).to receive(:call_api)
      .with(:get, path, return_type: "String", auth_names: ["BearerToken"])
      .and_return([body, 200, {}])
  end

  it "discovers resources through ApiClient#call_api" do
    resources = [
      { "name" => "volumeattachments", "kind" => "VolumeAttachment", "namespaced" => false }
    ]
    stub_discovery("storage.k8s.io", "v1", resources)

    expect(discovery.discover_resources("storage.k8s.io", "v1")).to eq(resources)
  end

  it "identifies namespaced resources" do
    stub_discovery("networking.k8s.io", "v1", [
      { "name" => "networkpolicies", "kind" => "NetworkPolicy", "namespaced" => true }
    ])

    expect(discovery.namespaced_resource_served?("networking.k8s.io", "v1", "NetworkPolicy")).to be true
    expect(discovery.cluster_resource_served?("networking.k8s.io", "v1", "NetworkPolicy")).to be false
  end

  it "identifies cluster-scoped resources" do
    stub_discovery("storage.k8s.io", "v1", [
      { "name" => "volumeattachments", "kind" => "VolumeAttachment", "namespaced" => false }
    ])

    expect(discovery.cluster_resource_served?("storage.k8s.io", "v1", "VolumeAttachment")).to be true
    expect(discovery.namespaced_resource_served?("storage.k8s.io", "v1", "VolumeAttachment")).to be false
  end

  it "checks predefined kind-incompatible resource selectors" do
    stub_discovery("storage.k8s.io", "v1", [
      { "name" => "volumeattachments", "kind" => "VolumeAttachment", "namespaced" => false }
    ])

    expect(discovery.kind_incompatible_resource_served?("storage.k8s.io/v1/volumeattachments")).to be true
  end

  it "returns false for non-gated bare resource selectors" do
    expect(discovery.kind_incompatible_resource_served?("core/v1/pods")).to be false
  end

  it "reports target availability for discovery-gated resources" do
    stub_discovery("storage.k8s.io", "v1", [
      { "name" => "storageclasses", "kind" => "StorageClass", "namespaced" => false }
    ])

    availability = discovery.target_availability("storage.k8s.io/v1/volumeattributesclasses:list")

    expect(availability).not_to be_served
    expect(availability.reason).to eq("Resource storage.k8s.io/v1/VolumeAttributesClass not served by cluster")
  end

  it "treats non-gated targets as available without discovery" do
    expect(api_client).not_to receive(:call_api)

    availability = discovery.target_availability("core/v1/pods:list")

    expect(availability).to be_served
  end

  it "caches discovery responses by group and version" do
    stub_discovery("networking.k8s.io", "v1", [
      { "name" => "ipaddresses", "kind" => "IPAddress", "namespaced" => false }
    ])

    2.times do
      expect(discovery.target_availability("networking.k8s.io/v1/ipaddresses:list")).to be_served
    end

    expect(api_client).to have_received(:call_api).once
  end

  it "propagates non-404 discovery errors from target availability" do
    allow(api_client).to receive(:call_api)
      .and_raise(Kubernetes::ApiError.new(code: 500, message: "discovery failed"))

    expect do
      discovery.target_availability("networking.k8s.io/v1/ipaddresses:list")
    end.to raise_error(Kubernetes::ApiError)
  end

  it "treats 404 discovery errors as unavailable target resources" do
    allow(api_client).to receive(:call_api)
      .and_raise(Kubernetes::ApiError.new(code: 404, message: "not found"))

    availability = discovery.target_availability("networking.k8s.io/v1/ipaddresses:list")

    expect(availability).not_to be_served
    expect(availability.reason).to eq("Resource networking.k8s.io/v1/IPAddress not served by cluster")
  end

  it "uses the core API discovery path for core resources" do
    stub_discovery("core", "v1", [
      { "name" => "pods", "kind" => "Pod", "namespaced" => true }
    ])

    expect(discovery.namespaced_resource_served?("core", "v1", "Pod")).to be true
  end
end

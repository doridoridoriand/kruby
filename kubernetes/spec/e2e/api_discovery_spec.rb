# frozen_string_literal: true

require "spec_helper"

RSpec.describe SpecSupport::E2E::ApiDiscovery do
  let(:api_client) { instance_double(Kubernetes::ApiClient) }
  let(:discovery) { described_class.new(api_client) }

  def stub_discovery(group, version, resources)
    path = group == "core" ? "/api/#{version}" : "/apis/#{group}/#{version}"
    body = JSON.generate("resources" => resources)

    allow(api_client).to receive(:call_api)
      .with(:get, path, return_type: "String")
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

  it "uses the core API discovery path for core resources" do
    stub_discovery("core", "v1", [
      { "name" => "pods", "kind" => "Pod", "namespaced" => true }
    ])

    expect(discovery.namespaced_resource_served?("core", "v1", "Pod")).to be true
  end
end

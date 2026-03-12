# frozen_string_literal: true

require "tmpdir"
require "spec_helper"

RSpec.describe SpecSupport::E2E::ClusterManager do
  let(:success_result) do
    described_class::CommandResult.new(command: "kind create cluster", status: 0, stdout: "", stderr: "")
  end

  describe ".default_cluster_name" do
    it "includes the Kubernetes version in full-mode cluster names" do
      expect(described_class.default_cluster_name(mode: "full", kubernetes_version: "1.31")).to eq("kruby-e2e-full-v1-31")
    end

    it "keeps non-full cluster names unique while preserving the Kubernetes version" do
      cluster_name = described_class.default_cluster_name(mode: "targeted", kubernetes_version: "1.35")

      expect(cluster_name).to match(/\Akruby-e2e-v1-35-\d+-[0-9a-f]{6}\z/)
    end
  end

  describe "#create" do
    it "creates a version-scoped cluster with a pinned node image and isolated kubeconfig" do
      Dir.mktmpdir("kruby-e2e-kubeconfig") do |tmpdir|
        manager = described_class.new(
          mode: "full",
          kubernetes_version: "1.33",
          kubeconfig_path: File.join(tmpdir, "kubeconfig"),
          reuse_cluster: false
        )

        allow(manager).to receive(:run_command).and_return(success_result)

        manager.create

        expect(manager.kubernetes_version).to eq("1.33")
        expect(manager.kind_node_image).to eq(
          SpecSupport::E2E::KindVersionResolver.resolve_node_image(kubernetes_version: "1.33")
        )
        expect(manager).to have_received(:run_command).with(
          [
            "kind", "create", "cluster", "--name", "kruby-e2e-full-v1-33",
            "--image", manager.kind_node_image,
            "--kubeconfig", File.join(tmpdir, "kubeconfig")
          ]
        )
      end
    end

    it "defaults kubeconfig paths under kubernetes/tmp/e2e/kubeconfig" do
      manager = described_class.new(mode: "full", kubernetes_version: "1.35", reuse_cluster: false)

      expect(manager.kubeconfig_path).to end_with("kubernetes/tmp/e2e/kubeconfig/kruby-e2e-full-v1-35.kubeconfig")
    end
  end
end

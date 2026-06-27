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
        custom_kind_bin = "/tmp/custom-kind"
        manager = described_class.new(
          mode: "full",
          kubernetes_version: "1.33",
          kind_bin: custom_kind_bin,
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
            custom_kind_bin, "create", "cluster", "--name", "kruby-e2e-full-v1-33",
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

    it "rehydrates a missing managed kubeconfig when reusing an existing cluster" do
      Dir.mktmpdir("kruby-e2e-kubeconfig") do |tmpdir|
        allow(described_class).to receive(:default_kubeconfig_path).and_return(File.join(tmpdir, "managed.kubeconfig"))

        manager = described_class.new(mode: "full", kubernetes_version: "1.35", reuse_cluster: true)
        cluster_list_result = described_class::CommandResult.new(
          command: "kind get clusters",
          status: 0,
          stdout: "#{manager.cluster_name}\n",
          stderr: ""
        )
        kubeconfig_result = described_class::CommandResult.new(
          command: "kind get kubeconfig",
          status: 0,
          stdout: "apiVersion: v1\n",
          stderr: ""
        )

        allow(manager).to receive(:run_command).and_return(cluster_list_result, kubeconfig_result)

        manager.create

        expect(File.read(manager.kubeconfig_path)).to eq("apiVersion: v1\n")
      end
    end

    it "expands explicit kubeconfig paths before using them" do
      Dir.mktmpdir("kruby-e2e-home") do |home_dir|
        original_home = ENV["HOME"]
        ENV["HOME"] = home_dir

        manager = described_class.new(
          mode: "full",
          kubernetes_version: "1.35",
          kubeconfig_path: "~/shared.kubeconfig",
          reuse_cluster: false
        )

        expect(manager.kubeconfig_path).to eq(File.join(home_dir, "shared.kubeconfig"))
      ensure
        ENV["HOME"] = original_home
      end
    end

    it "retries kind cluster creation when docker host port binding collides" do
      manager = described_class.new(mode: "full", kubernetes_version: "1.33", reuse_cluster: false)
      port_conflict_result = described_class::CommandResult.new(
        command: "kind create cluster",
        status: 125,
        stdout: "",
        stderr: "docker: Error response from daemon: failed to bind host port 127.0.0.1:61424/tcp: address already in use.\n"
      )
      port_conflict_error = described_class::CommandError.new("command failed", port_conflict_result)
      call_count = 0

      allow(manager).to receive(:run_command) do
        call_count += 1
        raise port_conflict_error if call_count == 1

        success_result
      end
      allow(manager).to receive(:sleep)

      manager.create

      expect(manager).to have_received(:run_command).exactly(3).times
      expect(manager).to have_received(:sleep).with(described_class::CREATE_RETRY_INTERVAL_SECONDS).once
    end

    it "retries kind cluster creation when startup times out" do
      manager = described_class.new(mode: "full", kubernetes_version: "1.33", reuse_cluster: false)
      timeout_result = described_class::CommandResult.new(
        command: "kind create cluster",
        status: 1,
        stdout: "",
        stderr: "ERROR: failed to create cluster: timed out waiting for the condition\n"
      )
      timeout_error = described_class::CommandError.new("command failed", timeout_result)
      call_count = 0

      allow(manager).to receive(:run_command) do
        call_count += 1
        raise timeout_error if call_count == 1

        success_result
      end
      allow(manager).to receive(:sleep)

      manager.create

      expect(manager).to have_received(:run_command).exactly(3).times
      expect(manager).to have_received(:sleep).with(described_class::CREATE_RETRY_INTERVAL_SECONDS).once
    end
  end

  describe "#delete" do
    it "removes autogenerated kubeconfig files after a successful cluster delete" do
      Dir.mktmpdir("kruby-e2e-kubeconfig") do |tmpdir|
        allow(described_class).to receive(:default_kubeconfig_path).and_return(File.join(tmpdir, "generated.kubeconfig"))

        manager = described_class.new(mode: "full", kubernetes_version: "1.35", reuse_cluster: false)
        File.write(manager.kubeconfig_path, "generated")
        allow(manager).to receive(:run_command).and_return(success_result)

        manager.delete

        expect(File.exist?(manager.kubeconfig_path)).to be(false)
      end
    end

    it "keeps caller-provided kubeconfig files after cluster deletion" do
      Dir.mktmpdir("kruby-e2e-kubeconfig") do |tmpdir|
        kubeconfig_path = File.join(tmpdir, "shared.kubeconfig")
        manager = described_class.new(
          mode: "full",
          kubernetes_version: "1.35",
          kubeconfig_path: kubeconfig_path,
          reuse_cluster: false
        )

        File.write(kubeconfig_path, "shared")
        allow(manager).to receive(:run_command).and_return(success_result)

        manager.delete

        expect(File.read(kubeconfig_path)).to eq("shared")
      end
    end
  end
end

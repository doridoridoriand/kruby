# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

RSpec.describe SpecSupport::E2E::CoverageGate do
  let(:inventory_json) do
    {
      "candidates" => [
        { "api" => "core_v1_api", "method" => "create_namespace" },
        { "api" => "core_v1_api", "method" => "read_namespace" },
        { "api" => "core_v1_api", "method" => "list_namespace" },
        { "api" => "apps_v1_api", "method" => "create_namespaced_deployment" },
        { "api" => "apps_v1_api", "method" => "read_namespaced_deployment" },
        { "api" => "networking_v1_api", "method" => "create_namespaced_ingress" },
        { "api" => "networking_v1_api", "method" => "read_namespaced_ingress" },
        { "api" => "batch_v1_api", "method" => "create_namespaced_job" },
        { "api" => "storage_v1_api", "method" => "create_storage_class" },
        { "api" => "autoscaling_v2_api", "method" => "create_namespaced_horizontal_pod_autoscaler" }
      ]
    }
  end

  let(:policy_yaml) do
    "explicitly_excluded_apis: []\nexclude_method_patterns: []"
  end

  let(:inventory_path) { File.join(test_dir, "coverage_inventory.json") }
  let(:policy_path) { File.join(test_dir, "coverage_policy.yml") }
  let(:test_dir) { Dir.mktmpdir("coverage_gate_test") }

  before do
    File.write(inventory_path, JSON.generate(inventory_json))
    File.write(policy_path, policy_yaml)
  end

  after do
    FileUtils.rm_rf(test_dir)
  end

  subject { described_class.new(inventory_path: inventory_path, policy_path: policy_path) }

  describe "#check" do
    it "returns all candidates as covered when no exclusions" do
      result = subject.check

      expect(result.total_candidates).to eq(10)
      expect(result.covered).to eq(10)
      expect(result.excluded).to eq(0)
      expect(result.missing).to eq(0)
      expect(result.passing).to be true
    end

    it "detects missing candidates for APIs not in the covered set" do
      inventory_json["candidates"] << { "api" => "admissionregistration_v1_api", "method" => "create_mutating_webhook_configuration" }
      File.write(inventory_path, JSON.generate(inventory_json))

      result = subject.check

      expect(result.missing).to eq(1)
      expect(result.missing_methods).to include("AdmissionregistrationV1Api#create_mutating_webhook_configuration")
      expect(result.passing).to be false
    end

    it "excludes APIs listed in explicitly_excluded_apis" do
      inventory_json["candidates"] << { "api" => "admissionregistration_v1_api", "method" => "create_mutating_webhook_configuration" }
      File.write(inventory_path, JSON.generate(inventory_json))

      policy_yaml_text = <<~YAML
        explicitly_excluded_apis:
          - AdmissionregistrationV1Api
        exclude_method_patterns: []
      YAML
      File.write(policy_path, policy_yaml_text)

      result = subject.check

      expect(result.excluded).to eq(1)
      expect(result.missing).to eq(0)
      expect(result.passing).to be true
    end

    it "excludes methods matching exclude_method_patterns" do
      inventory_json["candidates"] << { "api" => "core_v1_api", "method" => "create_namespaced_binding" }
      File.write(inventory_path, JSON.generate(inventory_json))

      policy_yaml_text = <<~YAML
        explicitly_excluded_apis: []
        exclude_method_patterns:
          - "^create_namespaced_binding$"
      YAML
      File.write(policy_path, policy_yaml_text)

      result = subject.check

      expect(result.excluded).to eq(1)
      expect(result.missing).to eq(0)
      expect(result.passing).to be true
    end

    it "handles empty inventory gracefully" do
      inventory_json["candidates"] = []
      File.write(inventory_path, JSON.generate(inventory_json))

      result = subject.check

      expect(result.total_candidates).to eq(0)
      expect(result.covered).to eq(0)
      expect(result.excluded).to eq(0)
      expect(result.missing).to eq(0)
      expect(result.passing).to be true
    end

    it "handles missing policy file gracefully" do
      File.delete(policy_path)
      result = subject.check
      expect(result.passing).to be true
    end
  end

  describe "#write_report" do
    it "writes a JSON report file" do
      result = subject.check
      report_path = subject.write_report(result)

      expect(File.exist?(report_path)).to be true
      data = JSON.parse(File.read(report_path))
      expect(data["result"]["totalCandidates"]).to eq(10)
      expect(data["result"]["passing"]).to be true
      expect(data["generatedAt"]).not_to be_nil
    end
  end

  describe "#check with real inventory" do
    it "loads the real coverage inventory and passes the gate" do
      real_inventory = File.expand_path("../../../../specs/002-real-api-e2e-coverage/coverage_inventory.json", __dir__)
      real_policy = File.expand_path("../support/e2e/coverage_policy.yml", __dir__)

      skip "Real inventory not found" unless File.exist?(real_inventory)
      skip "Real policy not found" unless File.exist?(real_policy)

      gate = described_class.new(inventory_path: real_inventory, policy_path: real_policy)
      result = gate.check

      expect(result.passing).to be true
      expect(result.missing).to eq(0)
    end
  end
end

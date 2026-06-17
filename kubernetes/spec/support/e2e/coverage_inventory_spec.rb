# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

RSpec.describe SpecSupport::E2E::CoverageInventory do
  let(:test_dir) { Dir.mktmpdir("coverage_inventory_test") }
  let(:api_dir) { File.join(test_dir, "api") }
  let(:policy_path) { File.join(test_dir, "coverage_policy.yml") }

  before do
    FileUtils.mkdir_p(api_dir)
  end

  after do
    FileUtils.rm_rf(test_dir)
  end

  describe "#generate" do
    it "tracks explicit API exclusions without shrinking the candidate set" do
      File.write(
        File.join(api_dir, "authentication_v1_api.rb"),
        <<~RUBY
          class AuthenticationV1Api
            def create_self_subject_review; end
            def create_token_review; end
            def helper_method; end
          end
        RUBY
      )
      File.write(
        File.join(api_dir, "core_v1_api.rb"),
        <<~RUBY
          class CoreV1Api
            def create_namespace; end
          end
        RUBY
      )
      File.write(
        policy_path,
        <<~YAML
          explicitly_excluded_apis:
            - AuthenticationV1Api
          exclude_method_patterns: []
        YAML
      )

      inventory = described_class.new(
        api_glob: File.join(api_dir, "*_api.rb"),
        policy_path: policy_path,
        repo_root: test_dir
      )

      payload = inventory.generate

      expect(payload.dig("policy", "explicitApiExclusionCount")).to eq(1)
      expect(payload.dig("totals", "candidateMethods")).to eq(3)
      expect(payload.dig("totals", "candidateMethodsExcludedByExplicitApiPolicy")).to eq(2)
      expect(payload.dig("totals", "excludedByPolicy")).to eq(0)
      expect(payload.dig("totals", "nonTargetOperations")).to eq(1)
      expect(payload.fetch("candidates").map { |entry| entry.fetch("method") })
        .to contain_exactly("create_self_subject_review", "create_token_review", "create_namespace")
      expect(payload.fetch("exclusions").map { |entry| entry.fetch("method") })
        .to contain_exactly("helper_method")

      authn_summary = payload.fetch("apis").find { |entry| entry.fetch("api") == "authentication_v1_api" }
      expect(authn_summary.dig("counts", "candidateMethods")).to eq(2)
      expect(authn_summary.dig("counts", "excludedByPolicy")).to eq(0)
      expect(authn_summary.dig("counts", "nonTargetOperations")).to eq(1)
    end

    it "applies string-form method exclusion rules" do
      File.write(
        File.join(api_dir, "core_v1_api.rb"),
        <<~RUBY
          class CoreV1Api
            def create_namespace; end
            def create_namespaced_binding; end
          end
        RUBY
      )
      File.write(
        policy_path,
        <<~YAML
          explicitly_excluded_apis: []
          exclude_method_patterns:
            - "^create_namespaced_binding$"
        YAML
      )

      inventory = described_class.new(
        api_glob: File.join(api_dir, "*_api.rb"),
        policy_path: policy_path,
        repo_root: test_dir
      )

      payload = inventory.generate

      expect(payload.dig("totals", "candidateMethods")).to eq(1)
      expect(payload.dig("totals", "excludedByPolicy")).to eq(1)

      excluded = payload.fetch("exclusions").find { |entry| entry.fetch("method") == "create_namespaced_binding" }
      expect(excluded.fetch("classification")).to eq("excluded_by_policy")
      expect(excluded.fetch("exclusionRule")).to eq("^create_namespaced_binding$")
    end
  end
end

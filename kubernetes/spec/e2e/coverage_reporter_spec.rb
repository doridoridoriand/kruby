# frozen_string_literal: true

require "json"
require "spec_helper"
require "tmpdir"

RSpec.describe SpecSupport::E2E::CoverageReporter do
  it "writes coverage summary with covered/unsupported/failed counts" do
    Dir.mktmpdir("kruby-e2e-coverage") do |tmpdir|
      output_path = File.join(tmpdir, "coverage.json")
      reporter = described_class.new(
        run_id: "run-20260306-coverage",
        mode: "full",
        output_path: output_path
      )

      reporter.start!(resolved_targets: %w[core/v1/pods:create apps/v1/deployments:watch batch/v1/jobs:update])
      reporter.record(target_id: "core/v1/pods:create", status: "covered", api_method: "CoreV1Api#create_namespaced_pod")
      reporter.record(target_id: "apps/v1/deployments:watch", status: "unsupported", reason: "watch not implemented yet")
      reporter.record(target_id: "batch/v1/jobs:update", status: "failed", reason: "replace call failed")

      path = reporter.write
      expect(path).to eq(output_path)
      expect(File.exist?(output_path)).to be(true)

      payload = JSON.parse(File.read(output_path))
      expect(payload).to include(
        "runId" => "run-20260306-coverage",
        "mode" => "full"
      )
      expect(payload.fetch("summary")).to include(
        "resolved" => 3,
        "recorded" => 3,
        "covered" => 1,
        "unsupported" => 1,
        "failed" => 1
      )
      expect(payload.fetch("targets").map { |entry| entry.fetch("status") }).to eq(%w[covered unsupported failed])
    end
  end
end

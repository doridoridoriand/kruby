# frozen_string_literal: true

require "json"
require "spec_helper"
require "tmpdir"

RSpec.describe "failure artifact emission" do
  it "emits structured artifact with required keys and writes JSON file" do
    Dir.mktmpdir("kruby-e2e-artifacts") do |tmpdir|
      reporter = SpecSupport::E2E::FailureReporter.new(
        run_id: "run-20260306-000001",
        output_dir: tmpdir
      )

      artifact = reporter.record(
        target_id: "core/v1/pods:create",
        error: StandardError.new("intentional failure"),
        repro_command: "scripts/e2e/run-e2e --mode targeted --targets core/v1/pods:create",
        api_method: "CoreV1Api#create_namespaced_pod"
      )

      expect(artifact).to include(
        "runId" => "run-20260306-000001",
        "targetId" => "core/v1/pods:create",
        "errorType" => "StandardError",
        "reproCommand" => "scripts/e2e/run-e2e --mode targeted --targets core/v1/pods:create",
        "apiMethod" => "CoreV1Api#create_namespaced_pod"
      )
      expect(artifact).to have_key("httpStatus")
      expect(artifact.fetch("httpStatus")).to be_nil

      artifacts = Dir.glob(File.join(tmpdir, "failure-run-20260306-000001-*.json"))
      expect(artifacts.length).to eq(1)

      persisted = JSON.parse(File.read(artifacts.first))
      expect(persisted).to eq(artifact)
    end
  end

  it "keeps UTF-8 response excerpts valid when truncating by byte size" do
    Dir.mktmpdir("kruby-e2e-artifacts") do |tmpdir|
      reporter = SpecSupport::E2E::FailureReporter.new(
        run_id: "run-20260306-utf8",
        output_dir: tmpdir
      )
      utf8_text = "あ" * (SpecSupport::E2E::FailureReporter::MAX_RESPONSE_EXCERPT_BYTES + 100)

      artifact = reporter.record(
        target_id: "core/v1/pods:create",
        error: StandardError.new("intentional failure"),
        repro_command: "scripts/e2e/run-e2e --mode targeted --targets core/v1/pods:create",
        response_excerpt: utf8_text
      )

      excerpt = artifact.fetch("responseExcerpt")
      expect(excerpt.encoding).to eq(Encoding::UTF_8)
      expect(excerpt.valid_encoding?).to be(true)
      expect(excerpt.bytesize).to be <= SpecSupport::E2E::FailureReporter::MAX_RESPONSE_EXCERPT_BYTES
    end
  end
end

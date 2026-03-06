# frozen_string_literal: true

require "json"
require "spec_helper"

RSpec.describe "real API selector execution", :real_api do
  REQUIRED_COMMANDS = %w[kind kubectl docker].freeze

  before do
    missing_command = REQUIRED_COMMANDS.find do |command|
      !system("command -v #{command} >/dev/null 2>&1")
    end
    skip("missing required command: #{missing_command}") if missing_command

    docker_ready = system("docker info >/dev/null 2>&1")
    skip("docker daemon is not available") unless docker_ready
  end

  it "executes resolved selectors against a kind cluster and records coverage" do
    context = SpecSupport::E2E::RunContext.from_env(ENV)
    executor = SpecSupport::E2E::Executor.new
    result = executor.execute(run_context: context)

    summary = result.fetch("coverage").fetch("summary")
    expect(summary.fetch("resolved")).to be > 0
    expect(summary.fetch("recorded")).to eq(summary.fetch("resolved"))
    expect(summary.fetch("covered")).to be > 0
    expect(summary.fetch("failed")).to eq(0), JSON.pretty_generate(result)

    coverage_path = result.fetch("coveragePath")
    expect(File.exist?(coverage_path)).to be(true), "coverage file missing: #{coverage_path}"
  end
end

# frozen_string_literal: true

require "spec_helper"
require "support/changed_spec_selector"

RSpec.describe SpecSupport::ChangedSpecSelector do
  subject(:selector) { described_class.new }

  it "returns a changed spec file directly" do
    selection = selector.resolve(changed_files: ["kubernetes/spec/api_client_spec.rb"])

    expect(selection.fallback_used).to be(false)
    expect(selection.selected_specs).to eq(["spec/api_client_spec.rb"])
  end

  it "maps generated model changes to serialization smoke coverage" do
    selection = selector.resolve(changed_files: ["kubernetes/lib/kubernetes/models/v1_pod.rb"])

    expect(selection.fallback_used).to be(false)
    expect(selection.selected_specs).to eq(%w[spec/models/serialization_spec.rb spec/models/smoke_spec.rb])
  end

  it "maps client runtime changes to focused client specs" do
    selection = selector.resolve(changed_files: ["kubernetes/lib/kubernetes/api_client.rb"])

    expect(selection.fallback_used).to be(false)
    expect(selection.selected_specs).to eq(["spec/api_client_spec.rb"])
  end

  it "maps e2e target changes to the e2e selector and coverage specs" do
    selection = selector.resolve(changed_files: ["kubernetes/spec/support/e2e/targets/core_v1_pods.rb"])

    expect(selection.fallback_used).to be(false)
    expect(selection.selected_specs).to include(
      "spec/e2e/changed_mode_selection_spec.rb",
      "spec/e2e/executor_mapping_spec.rb",
      "spec/e2e/full_mode_regression_spec.rb",
      "spec/support/e2e/coverage_gate_spec.rb",
      "spec/support/e2e/coverage_inventory_spec.rb"
    )
  end

  it "falls back to the smoke suite for non-code changes" do
    selection = selector.resolve(changed_files: ["README.md"])

    expect(selection.fallback_used).to be(true)
    expect(selection.reason).to eq("No focused specs could be mapped from changed files")
    expect(selection.selected_specs).to eq(described_class::DEFAULT_SMOKE_SPECS)
  end
end

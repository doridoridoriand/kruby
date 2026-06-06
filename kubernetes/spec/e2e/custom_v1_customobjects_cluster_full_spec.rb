# frozen_string_literal: true

require "spec_helper"

RSpec.describe "full mode custom/v1 customobjects-cluster (cluster-scoped) coverage" do
  it "contains all CRUD+watch selectors for custom/v1 customobjects-cluster" do
    context = SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full")
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expected = %w[create get list update patch delete].map do |op|
      "custom/v1/customobjects-cluster:#{op}"
    end

    expect(selection.mode).to eq("full")
    expect(selection.resolved_targets).to include(*expected)
  end
end

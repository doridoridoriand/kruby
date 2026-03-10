# frozen_string_literal: true

require "spec_helper"

RSpec.describe "full mode batch/v1 jobs coverage" do
  it "contains CRUD+watch selectors for batch/v1 jobs" do
    context = SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full")
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expected = %w[create get list update patch delete watch].map { |op| "batch/v1/jobs:#{op}" }

    expect(selection.mode).to eq("full")
    expect(selection.resolved_targets).to include(*expected)
    expect(selection.resolved_targets.index("batch/v1/jobs:create"))
      .to be < selection.resolved_targets.index("batch/v1/jobs:delete")
  end
end

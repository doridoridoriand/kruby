# frozen_string_literal: true

require "spec_helper"

RSpec.describe "full mode batch/v1 cron jobs coverage" do
  it "contains CRUD selectors for batch/v1 cron jobs" do
    context = SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full")
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expected_ops = %w[create get list update patch delete].map do |op|
      "batch/v1/cron-jobs:#{op}"
    end

    expect(selection.mode).to eq("full")
    expect(selection.resolved_targets).to include(*expected_ops)
    expect(selection.resolved_targets.index("batch/v1/cron-jobs:create"))
      .to be < selection.resolved_targets.index("batch/v1/cron-jobs:delete")
  end
end

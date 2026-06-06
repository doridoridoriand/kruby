# frozen_string_literal: true

require "spec_helper"

RSpec.describe "full mode core/v1 resource quotas coverage" do
  it "contains CRUD selectors for core/v1 resource quotas" do
    context = SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full")
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expected_ops = %w[create get list update patch delete].map do |op|
      "core/v1/resource-quotas:#{op}"
    end

    expect(selection.mode).to eq("full")
    expect(selection.resolved_targets).to include(*expected_ops)
    expect(selection.resolved_targets.index("core/v1/resource-quotas:create"))
      .to be < selection.resolved_targets.index("core/v1/resource-quotas:delete")
  end
end

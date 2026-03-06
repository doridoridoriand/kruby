# frozen_string_literal: true

require "spec_helper"

RSpec.describe "full mode apps/v1 deployments coverage" do
  it "contains CRUD selectors for apps/v1 deployments" do
    context = SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full")
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expected_crud = %w[create get list update patch delete].map do |op|
      "apps/v1/deployments:#{op}"
    end

    expect(selection.mode).to eq("full")
    expect(selection.resolved_targets).to include(*expected_crud)
    expect(selection.resolved_targets.index("apps/v1/deployments:create"))
      .to be < selection.resolved_targets.index("apps/v1/deployments:delete")
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe "full mode apps/v1 replicasets coverage" do
  it "contains CRUD+watch selectors for apps/v1 replicasets" do
    context = SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full")
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expected = %w[create get list update patch delete watch].map { |op| "apps/v1/replicasets:#{op}" }

    expect(selection.mode).to eq("full")
    expect(selection.resolved_targets).to include(*expected)
    expect(selection.resolved_targets.index("apps/v1/replicasets:create"))
      .to be < selection.resolved_targets.index("apps/v1/replicasets:delete")
  end
end

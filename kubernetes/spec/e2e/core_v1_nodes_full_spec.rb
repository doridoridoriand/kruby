# frozen_string_literal: true

require "spec_helper"

RSpec.describe "full mode core/v1 nodes coverage" do
  it "contains safe selectors for core/v1 nodes" do
    context = SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full")
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expected = %w[get list patch watch].map { |op| "core/v1/nodes:#{op}" }

    expect(selection.mode).to eq("full")
    expect(selection.resolved_targets).to include(*expected)
    expect(selection.resolved_targets).not_to include("core/v1/nodes:create")
    expect(selection.resolved_targets).not_to include("core/v1/nodes:delete")
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe "full mode policy/v1 poddisruptionbudgets coverage" do
  it "contains CRUD+watch selectors for policy/v1 poddisruptionbudgets" do
    context = SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full")
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expected = %w[create get list update patch delete watch].map do |op|
      "policy/v1/poddisruptionbudgets:#{op}"
    end

    expect(selection.mode).to eq("full")
    expect(selection.resolved_targets).to include(*expected)
  end
end

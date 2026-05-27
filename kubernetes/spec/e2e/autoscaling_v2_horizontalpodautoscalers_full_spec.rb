# frozen_string_literal: true

require "spec_helper"

RSpec.describe "full mode autoscaling/v2 horizontalpodautoscalers coverage" do
  it "contains CRUD+watch selectors for autoscaling/v2 horizontalpodautoscalers" do
    context = SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full")
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expected = %w[create get list update patch delete watch].map do |op|
      "autoscaling/v2/horizontalpodautoscalers:#{op}"
    end

    expect(selection.mode).to eq("full")
    expect(selection.resolved_targets).to include(*expected)
  end
end

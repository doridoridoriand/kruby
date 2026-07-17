# frozen_string_literal: true

require "spec_helper"

RSpec.describe "full mode autoscaling/v1 horizontalpodautoscalers coverage" do
  it "contains CRUD selectors for autoscaling/v1 horizontalpodautoscalers" do
    context = SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full")
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expected = %w[create get list update patch delete].map do |op|
      "autoscaling/v1/horizontalpodautoscalers:#{op}"
    end

    expect(selection.mode).to eq("full")
    expect(selection.resolved_targets).to include(*expected)
    expect(selection.resolved_targets.index("autoscaling/v1/horizontalpodautoscalers:create"))
      .to be < selection.resolved_targets.index("autoscaling/v1/horizontalpodautoscalers:delete")
  end
end

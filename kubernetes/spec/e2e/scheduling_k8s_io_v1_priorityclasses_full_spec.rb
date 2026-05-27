# frozen_string_literal: true

require "spec_helper"

RSpec.describe "full mode scheduling.k8s.io/v1 priorityclasses coverage" do
  it "contains CRUD+watch selectors for scheduling.k8s.io/v1 priorityclasses" do
    context = SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full")
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expected = %w[create get list update patch delete watch].map do |op|
      "scheduling.k8s.io/v1/priorityclasses:#{op}"
    end

    expect(selection.mode).to eq("full")
    expect(selection.resolved_targets).to include(*expected)
    expect(selection.resolved_targets.index("scheduling.k8s.io/v1/priorityclasses:create"))
      .to be < selection.resolved_targets.index("scheduling.k8s.io/v1/priorityclasses:delete")
  end
end

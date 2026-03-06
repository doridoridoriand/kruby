# frozen_string_literal: true

require "spec_helper"

RSpec.describe "targeted mode for core/v1 pods" do
  it "resolves only core/v1 pod create and delete selectors" do
    context = SpecSupport::E2E::RunContext.from_env(
      "E2E_MODE" => "targeted",
      "E2E_TARGETS" => "core/v1/pods:create,core/v1/pods:delete"
    )
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expect(selection.mode).to eq("targeted")
    expect(selection.requested_targets).to eq(%w[core/v1/pods:create core/v1/pods:delete])
    expect(selection.resolved_targets).to eq(%w[core/v1/pods:create core/v1/pods:delete])
    expect(selection.fallback_used).to be(false)
  end
end

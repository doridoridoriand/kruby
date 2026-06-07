# frozen_string_literal: true

require "spec_helper"

RSpec.describe "full mode storage.k8s.io/v1 csinodes coverage" do
  it "contains read-only selectors for storage.k8s.io/v1 csinodes" do
    context = SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full")
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expected = %w[get list].map do |op|
      "storage.k8s.io/v1/csinodes:#{op}"
    end

    expect(selection.mode).to eq("full")
    expect(selection.resolved_targets).to include(*expected)
    expect(selection.resolved_targets).not_to include("storage.k8s.io/v1/csinodes:patch")
  end
end

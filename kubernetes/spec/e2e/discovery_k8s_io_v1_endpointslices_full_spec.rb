# frozen_string_literal: true

require "spec_helper"

RSpec.describe "full mode discovery.k8s.io/v1 endpointslices coverage" do
  it "contains CRUD selectors for discovery.k8s.io/v1 endpointslices" do
    context = SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full")
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expected = %w[create get list update patch delete].map do |op|
      "discovery.k8s.io/v1/endpointslices:#{op}"
    end

    expect(selection.mode).to eq("full")
    expect(selection.resolved_targets).to include(*expected)
  end
end

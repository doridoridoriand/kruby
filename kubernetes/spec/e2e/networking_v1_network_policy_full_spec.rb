# frozen_string_literal: true

require "spec_helper"

RSpec.describe "full mode networking.k8s.io/v1 network policies coverage" do
  it "contains CRUD selectors for networking.k8s.io/v1 network policies" do
    context = SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full")
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expected_crud = %w[create get list update patch delete].map do |op|
      "networking.k8s.io/v1/network_policies:#{op}"
    end

    expect(selection.mode).to eq("full")
    expect(selection.resolved_targets).to include(*expected_crud)
    expect(selection.resolved_targets.index("networking.k8s.io/v1/network_policies:create"))
      .to be < selection.resolved_targets.index("networking.k8s.io/v1/network_policies:delete")
  end
end

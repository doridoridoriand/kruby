# frozen_string_literal: true

require "spec_helper"

RSpec.describe "full mode networking.k8s.io/v1 ipaddresses coverage" do
  it "contains CRUD selectors for networking.k8s.io/v1 ipaddresses" do
    context = SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full")
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expected = %w[create get list update patch delete].map do |op|
      "networking.k8s.io/v1/ipaddresses:#{op}"
    end

    expect(selection.mode).to eq("full")
    expect(selection.resolved_targets).to include(*expected)
    expect(selection.resolved_targets.index("networking.k8s.io/v1/ipaddresses:create"))
      .to be < selection.resolved_targets.index("networking.k8s.io/v1/ipaddresses:delete")
  end
end

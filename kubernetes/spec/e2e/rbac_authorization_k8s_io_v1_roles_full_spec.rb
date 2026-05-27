# frozen_string_literal: true

require "spec_helper"

RSpec.describe "full mode rbac.authorization.k8s.io/v1 roles coverage" do
  it "contains CRUD selectors for rbac.authorization.k8s.io/v1 roles" do
    context = SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full")
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expected_ops = %w[create get list update patch delete].map do |op|
      "rbac.authorization.k8s.io/v1/roles:#{op}"
    end

    expect(selection.mode).to eq("full")
    expect(selection.resolved_targets).to include(*expected_ops)
    expect(selection.resolved_targets.index("rbac.authorization.k8s.io/v1/roles:create"))
      .to be < selection.resolved_targets.index("rbac.authorization.k8s.io/v1/roles:delete")
  end
end

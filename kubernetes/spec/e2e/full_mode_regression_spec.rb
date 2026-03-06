# frozen_string_literal: true

require "spec_helper"

RSpec.describe "full mode orchestration" do
  it "expands catalog into deterministic execution order" do
    context = SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full")
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expect(selection.mode).to eq("full")
    expect(selection.requested_targets).to eq([])
    expect(selection.fallback_used).to be(false)
    expect(selection.resolved_targets).to eq(selection.resolved_targets.uniq)

    expect(selection.resolved_targets).to include("core/v1/pods:create")
    expect(selection.resolved_targets).to include("apps/v1/deployments:create")
    expect(selection.resolved_targets).to include("batch/v1/jobs:create")

    expect(selection.resolved_targets.index("core/v1/pods:create"))
      .to be < selection.resolved_targets.index("core/v1/pods:delete")
    expect(selection.resolved_targets.index("apps/v1/deployments:create"))
      .to be < selection.resolved_targets.index("apps/v1/deployments:delete")
    expect(selection.resolved_targets.index("batch/v1/jobs:create"))
      .to be < selection.resolved_targets.index("batch/v1/jobs:delete")
  end
end

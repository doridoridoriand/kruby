# frozen_string_literal: true

require "spec_helper"

RSpec.describe "changed mode selector resolution" do
  it "maps core_v1_api changes to core/v1 pod selectors" do
    context = SpecSupport::E2E::RunContext.from_env(
      "E2E_MODE" => "changed",
      "BASE_REF" => "origin/HEAD",
      "E2E_FALLBACK_STRATEGY" => "minimal-smoke"
    ).with_changed_files(["kubernetes/lib/kubernetes/api/core_v1_api.rb"])

    dispatcher = SpecSupport::E2E::ModeDispatcher.new
    selection = dispatcher.dispatch(context)

    expect(selection.mode).to eq("changed")
    expect(selection.fallback_used).to be(false)
    expect(selection.resolved_targets).to include("core/v1/pods:create")
    expect(selection.resolved_targets).to include("core/v1/pods:delete")
  end

  it "falls back to minimal-smoke selectors when changes are unresolved" do
    context = SpecSupport::E2E::RunContext.from_env(
      "E2E_MODE" => "changed",
      "BASE_REF" => "origin/HEAD",
      "E2E_FALLBACK_STRATEGY" => "minimal-smoke"
    ).with_changed_files(["kubernetes/lib/kubernetes/models/v1_pod.rb"])

    dispatcher = SpecSupport::E2E::ModeDispatcher.new
    selection = dispatcher.dispatch(context)

    expect(selection.fallback_used).to be(true)
    expect(selection.resolved_targets).to include("core/v1/pods:create", "core/v1/pods:list")
  end

  it "falls back to full catalog when fallback strategy is full" do
    context = SpecSupport::E2E::RunContext.from_env(
      "E2E_MODE" => "changed",
      "BASE_REF" => "origin/HEAD",
      "E2E_FALLBACK_STRATEGY" => "full"
    ).with_changed_files(["kubernetes/lib/kubernetes/models/v1_pod.rb"])

    dispatcher = SpecSupport::E2E::ModeDispatcher.new
    selection = dispatcher.dispatch(context)

    expect(selection.fallback_used).to be(true)
    expect(selection.resolved_targets).to include("core/v1/pods:create")
    expect(selection.resolved_targets).to include("core/v1/pods:delete")
    expect(selection.resolved_targets).to include("apps/v1/deployments:update")
  end
end

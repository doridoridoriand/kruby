# frozen_string_literal: true

require "spec_helper"

RSpec.describe "full mode storage.k8s.io/v1 volumeattachments coverage" do
  it "contains the kind-compatible list selector for storage.k8s.io/v1 volumeattachments" do
    context = SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full")
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expect(selection.mode).to eq("full")
    expect(selection.resolved_targets).to include("storage.k8s.io/v1/volumeattachments:list")
    expect(selection.resolved_targets).not_to include(
      "storage.k8s.io/v1/volumeattachments:get",
      "storage.k8s.io/v1/volumeattachments:patch"
    )
  end
end

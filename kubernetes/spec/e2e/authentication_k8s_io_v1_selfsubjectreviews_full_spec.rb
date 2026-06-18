# frozen_string_literal: true

require "spec_helper"

RSpec.describe "full mode authentication.k8s.io/v1 selfsubjectreviews coverage" do
  it "contains the create selector for authentication.k8s.io/v1 selfsubjectreviews" do
    context = SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full")
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expect(selection.mode).to eq("full")
    expect(selection.resolved_targets).to include("authentication.k8s.io/v1/selfsubjectreviews:create")
  end
end

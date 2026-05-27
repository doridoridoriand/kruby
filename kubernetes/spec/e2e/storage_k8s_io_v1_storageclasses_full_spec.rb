# frozen_string_literal: true

require "spec_helper"

RSpec.describe "full mode storage.k8s.io/v1 storageclasses coverage" do
  it "contains CRUD+watch selectors for storage.k8s.io/v1 storageclasses" do
    context = SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full")
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expected = %w[create get list update patch delete watch].map do |op|
      "storage.k8s.io/v1/storageclasses:#{op}"
    end

    expect(selection.mode).to eq("full")
    expect(selection.resolved_targets).to include(*expected)
    expect(selection.resolved_targets.index("storage.k8s.io/v1/storageclasses:create"))
      .to be < selection.resolved_targets.index("storage.k8s.io/v1/storageclasses:delete")
  end
end

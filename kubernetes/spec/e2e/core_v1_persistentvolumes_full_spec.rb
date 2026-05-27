# frozen_string_literal: true

require "spec_helper"

RSpec.describe "full mode core/v1 persistent volumes coverage" do
  it "contains CRUD+watch selectors for core/v1 persistentvolumes" do
    context = SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full")
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expected = %w[create get list update patch delete watch].map do |op|
      "core/v1/persistentvolumes:#{op}"
    end

    expect(selection.mode).to eq("full")
    expect(selection.resolved_targets).to include(*expected)
    expect(selection.resolved_targets.index("core/v1/persistentvolumes:create"))
      .to be < selection.resolved_targets.index("core/v1/persistentvolumes:delete")
  end
end

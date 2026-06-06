# frozen_string_literal: true

require "spec_helper"

RSpec.describe "full mode storage.k8s.io/v1 volumeattachments coverage" do
  it "contains get/list/patch selectors for storage.k8s.io/v1 volumeattachments" do
    context = SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full")
    dispatcher = SpecSupport::E2E::ModeDispatcher.new

    selection = dispatcher.dispatch(context)

    expected = %w[get list patch].map do |op|
      "storage.k8s.io/v1/volumeattachments:#{op}"
    end

    expect(selection.mode).to eq("full")
    expect(selection.resolved_targets).to include(*expected)
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe SpecSupport::E2E::ReproCommandBuilder do
  it "includes the Kubernetes version in generated repro commands" do
    command = described_class.new.build(
      mode: "targeted",
      targets: ["core/v1/pods:create"],
      fallback_strategy: "minimal-smoke",
      kubernetes_version: "1.31"
    )

    expect(command).to eq(
      "scripts/e2e/run-e2e --mode targeted --targets core/v1/pods:create --fallback minimal-smoke --kubernetes-version 1.31"
    )
  end
end

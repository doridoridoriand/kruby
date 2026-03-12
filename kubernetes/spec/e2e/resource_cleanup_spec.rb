# frozen_string_literal: true

require "spec_helper"

RSpec.describe SpecSupport::E2E::ResourceCleanup do
  let(:success_result) { instance_double("CommandResult", success?: true) }
  let(:failure_result) { instance_double("CommandResult", success?: false) }

  it "waits for the default service account after creating a namespace" do
    cluster_manager = instance_double("ClusterManager")
    cleanup = described_class.new(cluster_manager: cluster_manager)

    allow(cleanup).to receive(:sleep)
    allow(cluster_manager).to receive(:kubectl).and_return(
      success_result,
      failure_result,
      failure_result,
      success_result
    )

    cleanup.create_namespace("kruby-e2e-test")

    expect(cluster_manager).to have_received(:kubectl).with("create", "namespace", "kruby-e2e-test", allow_failure: true)
    expect(cluster_manager).to have_received(:kubectl).with(
      "-n", "kruby-e2e-test", "get", "serviceaccount", "default", "-o", "name", allow_failure: true
    ).exactly(3).times
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe SpecSupport::E2E::Executor do
  it "maps update and watch selectors to concrete API method names" do
    executor = described_class.new

    update_pod = SpecSupport::E2E::TargetSelector.parse("core/v1/pods:update")
    update_deployment = SpecSupport::E2E::TargetSelector.parse("apps/v1/deployments:update")
    update_job = SpecSupport::E2E::TargetSelector.parse("batch/v1/jobs:update")

    watch_pod = SpecSupport::E2E::TargetSelector.parse("core/v1/pods:watch")
    watch_deployment = SpecSupport::E2E::TargetSelector.parse("apps/v1/deployments:watch")
    watch_job = SpecSupport::E2E::TargetSelector.parse("batch/v1/jobs:watch")

    # api_method_name is a critical selector->API contract; we verify it directly via `executor.send`.
    expect(executor.send(:api_method_name, update_pod)).to eq("CoreV1Api#replace_namespaced_pod")
    expect(executor.send(:api_method_name, update_deployment)).to eq("AppsV1Api#replace_namespaced_deployment")
    expect(executor.send(:api_method_name, update_job)).to eq("BatchV1Api#replace_namespaced_job")

    expect(executor.send(:api_method_name, watch_pod)).to eq("CoreV1Api#watch_namespaced_pod")
    expect(executor.send(:api_method_name, watch_deployment)).to eq("AppsV1Api#watch_namespaced_deployment")
    expect(executor.send(:api_method_name, watch_job)).to eq("BatchV1Api#watch_namespaced_job")
  end
end

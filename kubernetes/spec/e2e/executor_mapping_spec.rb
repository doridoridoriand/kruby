# frozen_string_literal: true

require "spec_helper"

RSpec.describe SpecSupport::E2E::Executor do
  it "maps update and watch selectors to concrete API method names" do
    executor = described_class.new

    update_pod = SpecSupport::E2E::TargetSelector.parse("core/v1/pods:update")
    update_service = SpecSupport::E2E::TargetSelector.parse("core/v1/services:update")
    update_deployment = SpecSupport::E2E::TargetSelector.parse("apps/v1/deployments:update")
    update_job = SpecSupport::E2E::TargetSelector.parse("batch/v1/jobs:update")

    watch_pod = SpecSupport::E2E::TargetSelector.parse("core/v1/pods:watch")
    watch_service = SpecSupport::E2E::TargetSelector.parse("core/v1/services:watch")
    watch_deployment = SpecSupport::E2E::TargetSelector.parse("apps/v1/deployments:watch")
    watch_job = SpecSupport::E2E::TargetSelector.parse("batch/v1/jobs:watch")

    # api_method_name is a critical selector->API contract; we verify it directly via `executor.send`.
    expect(executor.send(:api_method_name, update_pod)).to eq("CoreV1Api#replace_namespaced_pod")
    expect(executor.send(:api_method_name, update_service)).to eq("CoreV1Api#replace_namespaced_service")
    expect(executor.send(:api_method_name, update_deployment)).to eq("AppsV1Api#replace_namespaced_deployment")
    expect(executor.send(:api_method_name, update_job)).to eq("BatchV1Api#replace_namespaced_job")

    expect(executor.send(:api_method_name, watch_pod)).to eq("CoreV1Api#list_namespaced_pod(watch: true)")
    expect(executor.send(:api_method_name, watch_service)).to eq("CoreV1Api#list_namespaced_service(watch: true)")
    expect(executor.send(:api_method_name, watch_deployment)).to eq("AppsV1Api#list_namespaced_deployment(watch: true)")
    expect(executor.send(:api_method_name, watch_job)).to eq("BatchV1Api#list_namespaced_job(watch: true)")
  end

  it "maps config-maps, secrets, and namespaces to CoreV1Api methods" do
    executor = described_class.new

    %w[create get list update patch delete].each do |op|
      cm = SpecSupport::E2E::TargetSelector.parse("core/v1/config-maps:#{op}")
      secret = SpecSupport::E2E::TargetSelector.parse("core/v1/secrets:#{op}")
      ns = SpecSupport::E2E::TargetSelector.parse("core/v1/namespaces:#{op}")

      api_action = case op
      when "create"
        ["create_namespaced_config_map", "create_namespaced_secret", "create_namespace"]
      when "get"
        ["read_namespaced_config_map", "read_namespaced_secret", "read_namespace"]
      when "list"
        ["list_namespaced_config_map", "list_namespaced_secret", "list_namespace"]
      when "update"
        ["replace_namespaced_config_map", "replace_namespaced_secret", "replace_namespace"]
      when "patch"
        ["patch_namespaced_config_map", "patch_namespaced_secret", "patch_namespace"]
      when "delete"
        ["delete_namespaced_config_map", "delete_namespaced_secret", "delete_namespace"]
      end

      expect(executor.send(:api_method_name, cm)).to eq("CoreV1Api##{api_action[0]}")
      expect(executor.send(:api_method_name, secret)).to eq("CoreV1Api##{api_action[1]}")
      expect(executor.send(:api_method_name, ns)).to eq("CoreV1Api##{api_action[2]}")
    end

    delete_collection_config_map = SpecSupport::E2E::TargetSelector.parse("core/v1/config-maps:delete_collection")
    expect(executor.send(:api_method_name, delete_collection_config_map))
      .to eq("CoreV1Api#delete_collection_namespaced_config_map")
  end

  it "executes config-map delete_collection with a label selector scoped to the seeded resource" do
    executor = described_class.new
    api = instance_double(Kubernetes::CoreV1Api)
    cleanup = instance_double("Cleanup")

    allow(executor).to receive(:build_api_client).and_return(double("api_client"))
    allow(Kubernetes::CoreV1Api).to receive(:new).and_return(api)
    allow(executor).to receive(:seed_config_map).with(api, namespace: "test-ns", cleanup: cleanup).and_return("cm-123")
    allow(executor).to receive(:wait_for_resource_absence!).with("configmap collection test-ns/cm-123")

    expect(api).to receive(:delete_collection_namespaced_config_map)
      .with("test-ns", label_selector: "app.kubernetes.io/instance=cm-123")

    executor.send(:execute_config_map_operation, "delete_collection", namespace: "test-ns", cleanup: cleanup)
  end

  it "maps every registered full-mode selector to an API method name" do
    executor = described_class.new
    dispatcher = SpecSupport::E2E::ModeDispatcher.new
    selection = dispatcher.dispatch(SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full"))

    unmapped = selection.resolved_targets.select do |target_id|
      parsed = SpecSupport::E2E::TargetSelector.parse(target_id)
      executor.send(:api_method_name, parsed).nil?
    end

    expect(unmapped).to eq([])
  end
end

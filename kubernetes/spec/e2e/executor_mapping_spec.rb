# frozen_string_literal: true

require "spec_helper"

RSpec.describe SpecSupport::E2E::Executor do
  let(:executor) { described_class.new }

  def established_crd
    {
      "status" => {
        "conditions" => [
          { "type" => "Established", "status" => "True" }
        ]
      }
    }
  end

  it "maps update and watch selectors to concrete API method names" do
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
    dispatcher = SpecSupport::E2E::ModeDispatcher.new
    selection = dispatcher.dispatch(SpecSupport::E2E::RunContext.from_env("E2E_MODE" => "full"))

    unmapped = selection.resolved_targets.select do |target_id|
      parsed = SpecSupport::E2E::TargetSelector.parse(target_id)
      executor.send(:api_method_name, parsed).nil?
    end

    expect(unmapped).to eq([])
  end

  it "maps new core, apps, and batch resources to API method names" do
    # LimitRange (core/v1)
    %w[create get list update patch delete].each do |op|
      sel = SpecSupport::E2E::TargetSelector.parse("core/v1/limit-ranges:#{op}")
      expected = {
        "create" => "CoreV1Api#create_namespaced_limit_range",
        "get" => "CoreV1Api#read_namespaced_limit_range",
        "list" => "CoreV1Api#list_namespaced_limit_range",
        "update" => "CoreV1Api#replace_namespaced_limit_range",
        "patch" => "CoreV1Api#patch_namespaced_limit_range",
        "delete" => "CoreV1Api#delete_namespaced_limit_range"
      }
      expect(executor.send(:api_method_name, sel)).to eq(expected[op])
    end

    # ResourceQuota (core/v1)
    %w[create get list update patch delete].each do |op|
      sel = SpecSupport::E2E::TargetSelector.parse("core/v1/resource-quotas:#{op}")
      expected = {
        "create" => "CoreV1Api#create_namespaced_resource_quota",
        "get" => "CoreV1Api#read_namespaced_resource_quota",
        "list" => "CoreV1Api#list_namespaced_resource_quota",
        "update" => "CoreV1Api#replace_namespaced_resource_quota",
        "patch" => "CoreV1Api#patch_namespaced_resource_quota",
        "delete" => "CoreV1Api#delete_namespaced_resource_quota"
      }
      expect(executor.send(:api_method_name, sel)).to eq(expected[op])
    end

    # ServiceAccount (core/v1)
    %w[create get list update patch delete].each do |op|
      sel = SpecSupport::E2E::TargetSelector.parse("core/v1/service-accounts:#{op}")
      expected = {
        "create" => "CoreV1Api#create_namespaced_service_account",
        "get" => "CoreV1Api#read_namespaced_service_account",
        "list" => "CoreV1Api#list_namespaced_service_account",
        "update" => "CoreV1Api#replace_namespaced_service_account",
        "patch" => "CoreV1Api#patch_namespaced_service_account",
        "delete" => "CoreV1Api#delete_namespaced_service_account"
      }
      expect(executor.send(:api_method_name, sel)).to eq(expected[op])
    end

    # PodTemplate (core/v1)
    %w[create get list update patch delete].each do |op|
      sel = SpecSupport::E2E::TargetSelector.parse("core/v1/pod-templates:#{op}")
      expected = {
        "create" => "CoreV1Api#create_namespaced_pod_template",
        "get" => "CoreV1Api#read_namespaced_pod_template",
        "list" => "CoreV1Api#list_namespaced_pod_template",
        "update" => "CoreV1Api#replace_namespaced_pod_template",
        "patch" => "CoreV1Api#patch_namespaced_pod_template",
        "delete" => "CoreV1Api#delete_namespaced_pod_template"
      }
      expect(executor.send(:api_method_name, sel)).to eq(expected[op])
    end

    # ReplicationController (core/v1)
    %w[create get list update patch delete].each do |op|
      sel = SpecSupport::E2E::TargetSelector.parse("core/v1/replication-controllers:#{op}")
      expected = {
        "create" => "CoreV1Api#create_namespaced_replication_controller",
        "get" => "CoreV1Api#read_namespaced_replication_controller",
        "list" => "CoreV1Api#list_namespaced_replication_controller",
        "update" => "CoreV1Api#replace_namespaced_replication_controller",
        "patch" => "CoreV1Api#patch_namespaced_replication_controller",
        "delete" => "CoreV1Api#delete_namespaced_replication_controller"
      }
      expect(executor.send(:api_method_name, sel)).to eq(expected[op])
    end

    # ControllerRevision (apps/v1)
    %w[create get list update patch delete].each do |op|
      sel = SpecSupport::E2E::TargetSelector.parse("apps/v1/controller-revisions:#{op}")
      expected = {
        "create" => "AppsV1Api#create_namespaced_controller_revision",
        "get" => "AppsV1Api#read_namespaced_controller_revision",
        "list" => "AppsV1Api#list_namespaced_controller_revision",
        "update" => "AppsV1Api#replace_namespaced_controller_revision",
        "patch" => "AppsV1Api#patch_namespaced_controller_revision",
        "delete" => "AppsV1Api#delete_namespaced_controller_revision"
      }
      expect(executor.send(:api_method_name, sel)).to eq(expected[op])
    end

    # CronJob (batch/v1)
    %w[create get list update patch delete].each do |op|
      sel = SpecSupport::E2E::TargetSelector.parse("batch/v1/cron-jobs:#{op}")
      expected = {
        "create" => "BatchV1Api#create_namespaced_cron_job",
        "get" => "BatchV1Api#read_namespaced_cron_job",
        "list" => "BatchV1Api#list_namespaced_cron_job",
        "update" => "BatchV1Api#replace_namespaced_cron_job",
        "patch" => "BatchV1Api#patch_namespaced_cron_job",
        "delete" => "BatchV1Api#delete_namespaced_cron_job"
      }
      expect(executor.send(:api_method_name, sel)).to eq(expected[op])
    end
  end

  it "creates the namespaced CustomObjects test CRD when it is missing" do
    crd_api = instance_double(Kubernetes::ApiextensionsV1Api)
    cleanup = instance_double("Cleanup")
    crd_name = "samplecrs.kruby-e2e.cyberagent.co.jp"
    read_attempts = 0

    allow(crd_api).to receive(:read_custom_resource_definition).with(crd_name) do
      read_attempts += 1
      raise Kubernetes::ApiError.new(code: 404, message: "not found") if read_attempts == 1

      established_crd
    end
    expect(crd_api).to receive(:create_custom_resource_definition) do |body|
      expect(body["metadata"]["name"]).to eq(crd_name)
      expect(body["spec"]["group"]).to eq("kruby-e2e.cyberagent.co.jp")
      expect(body["spec"]["scope"]).to eq("Namespaced")
      expect(body["spec"]["names"]).to include(
        "plural" => "samplecrs",
        "singular" => "samplecr",
        "kind" => "SampleCR",
        "shortNames" => ["scr"]
      )
    end
    expect(cleanup).to receive(:register)

    executor.send(:ensure_test_crd, crd_api, cleanup: cleanup, cluster_scoped: false)

    expect(read_attempts).to eq(2)
  end

  it "creates a separate cluster-scoped CustomObjects test CRD when it is missing" do
    crd_api = instance_double(Kubernetes::ApiextensionsV1Api)
    cleanup = instance_double("Cleanup")
    crd_name = "clustersamplecrs.kruby-e2e.cyberagent.co.jp"
    read_attempts = 0

    allow(crd_api).to receive(:read_custom_resource_definition).with(crd_name) do
      read_attempts += 1
      raise Kubernetes::ApiError.new(code: 404, message: "not found") if read_attempts == 1

      established_crd
    end
    expect(crd_api).to receive(:create_custom_resource_definition) do |body|
      expect(body["metadata"]["name"]).to eq(crd_name)
      expect(body["spec"]["group"]).to eq("kruby-e2e.cyberagent.co.jp")
      expect(body["spec"]["scope"]).to eq("Cluster")
      expect(body["spec"]["names"]).to include(
        "plural" => "clustersamplecrs",
        "singular" => "clustersamplecr",
        "kind" => "ClusterSampleCR",
        "shortNames" => ["cscr"]
      )
    end
    expect(cleanup).to receive(:register)

    executor.send(:ensure_test_crd, crd_api, cleanup: cleanup, cluster_scoped: true)

    expect(read_attempts).to eq(2)
  end

  it "reuses an already established CustomObjects test CRD without registering deletion" do
    crd_api = instance_double(Kubernetes::ApiextensionsV1Api)
    cleanup = instance_double("Cleanup")

    expect(crd_api).to receive(:read_custom_resource_definition)
      .with("samplecrs.kruby-e2e.cyberagent.co.jp")
      .and_return(established_crd)
    expect(crd_api).not_to receive(:create_custom_resource_definition)
    expect(cleanup).not_to receive(:register)

    executor.send(:ensure_test_crd, crd_api, cleanup: cleanup, cluster_scoped: false)
  end

  it "treats a CRD with nil status conditions as not established" do
    crd = double("CRD", status: double("Status", conditions: nil))

    expect(executor.send(:crd_established?, crd)).to be(false)
  end

  it "extracts list items from symbol-keyed API responses" do
    list = {
      items: [
        { metadata: { name: "kruby-e2e-scr-1" } }
      ]
    }

    expect(executor.send(:resource_items, list)).to eq(list[:items])
    expect { executor.send(:assert_list_includes!, list, "kruby-e2e-scr-1") }.not_to raise_error
  end

  it "updates labels on symbol-keyed API responses without adding duplicate metadata keys" do
    resource = {
      apiVersion: "kruby-e2e.cyberagent.co.jp/v1",
      kind: "SampleCR",
      metadata: {
        name: "kruby-e2e-scr-1",
        labels: { "app.kubernetes.io/name" => "kruby-e2e" }
      }
    }

    updated = executor.send(:with_updated_label, resource, key: "e2e-updated", value: "true")

    expect(updated).to equal(resource)
    expect(updated).not_to have_key("metadata")
    expect(updated[:metadata][:labels]).to include("e2e-updated" => "true")
  end

  it "generates valid IP address names for IPAddress catalog resources" do
    definition = described_class::CATALOG_RESOURCE_EXECUTIONS.fetch(
      ["networking.k8s.io", "v1", "ipaddresses"]
    )

    expect(executor.send(:catalog_resource_name, definition)).to match(/\A192\.0\.2\.\d{1,3}\z/)
  end
end

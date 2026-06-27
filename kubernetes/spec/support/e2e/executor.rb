# frozen_string_literal: true

require "kubernetes"
require "securerandom"

require_relative "api_discovery"
require_relative "cluster_manager"
require_relative "coverage_reporter"
require_relative "failure_reporter"
require_relative "factories"
require_relative "kind_version_resolver"
require_relative "mode_dispatcher"
require_relative "repro_command_builder"
require_relative "resource_cleanup"
require_relative "run_context"
require_relative "target_selector"

module SpecSupport
  module E2E
    class Executor
      DELETE_WAIT_TIMEOUT_SECONDS = 20
      DELETE_WAIT_INTERVAL_SECONDS = 0.2
      CRD_ESTABLISH_TIMEOUT_SECONDS = 20
      CRD_ESTABLISH_INTERVAL_SECONDS = 0.2
      CONFLICT_RETRY_ATTEMPTS = 10
      CONFLICT_RETRY_INTERVAL_SECONDS = 0.2

      class UnsupportedTargetError < StandardError; end

      class ExecutionError < StandardError
        attr_reader :result

        def initialize(message, result)
          super(message)
          @result = result
        end
      end

      OPERATION_METHOD_KEYS = {
        "create" => :create_method,
        "get" => :read_method,
        "list" => :list_method,
        "update" => :replace_method,
        "patch" => :patch_method,
        "delete" => :delete_method,
        "watch" => :list_method
      }.freeze

      CATALOG_RESOURCE_EXECUTIONS = {
        ["core", "v1", "endpoints"] => {
          api_class: "CoreV1Api",
          factory: :endpoints,
          name_prefix: "endpoints",
          namespace_scoped: true,
          kubectl_resource: "endpoints",
          create_method: :create_namespaced_endpoints,
          read_method: :read_namespaced_endpoints,
          list_method: :list_namespaced_endpoints,
          replace_method: :replace_namespaced_endpoints,
          patch_method: :patch_namespaced_endpoints,
          delete_method: :delete_namespaced_endpoints
        },
        ["core", "v1", "persistentvolumeclaims"] => {
          api_class: "CoreV1Api",
          factory: :persistent_volume_claim,
          name_prefix: "pvc",
          namespace_scoped: true,
          kubectl_resource: "persistentvolumeclaim",
          create_method: :create_namespaced_persistent_volume_claim,
          read_method: :read_namespaced_persistent_volume_claim,
          list_method: :list_namespaced_persistent_volume_claim,
          replace_method: :replace_namespaced_persistent_volume_claim,
          patch_method: :patch_namespaced_persistent_volume_claim,
          delete_method: :delete_namespaced_persistent_volume_claim
        },
        ["core", "v1", "persistentvolumes"] => {
          api_class: "CoreV1Api",
          factory: :persistent_volume,
          name_prefix: "pv",
          namespace_scoped: false,
          create_method: :create_persistent_volume,
          read_method: :read_persistent_volume,
          list_method: :list_persistent_volume,
          replace_method: :replace_persistent_volume,
          patch_method: :patch_persistent_volume,
          delete_method: :delete_persistent_volume
        },
        ["core", "v1", "nodes"] => {
          api_class: "CoreV1Api",
          namespace_scoped: false,
          read_method: :read_node,
          list_method: :list_node,
          patch_method: :patch_node
        },
        ["apps", "v1", "daemonsets"] => {
          api_class: "AppsV1Api",
          factory: :daemon_set,
          name_prefix: "daemonset",
          namespace_scoped: true,
          kubectl_resource: "daemonset",
          create_method: :create_namespaced_daemon_set,
          read_method: :read_namespaced_daemon_set,
          list_method: :list_namespaced_daemon_set,
          replace_method: :replace_namespaced_daemon_set,
          patch_method: :patch_namespaced_daemon_set,
          delete_method: :delete_namespaced_daemon_set
        },
        ["apps", "v1", "replicasets"] => {
          api_class: "AppsV1Api",
          factory: :replica_set,
          name_prefix: "replicaset",
          namespace_scoped: true,
          kubectl_resource: "replicaset",
          create_method: :create_namespaced_replica_set,
          read_method: :read_namespaced_replica_set,
          list_method: :list_namespaced_replica_set,
          replace_method: :replace_namespaced_replica_set,
          patch_method: :patch_namespaced_replica_set,
          delete_method: :delete_namespaced_replica_set
        },
        ["apps", "v1", "statefulsets"] => {
          api_class: "AppsV1Api",
          factory: :stateful_set,
          name_prefix: "statefulset",
          namespace_scoped: true,
          kubectl_resource: "statefulset",
          create_method: :create_namespaced_stateful_set,
          read_method: :read_namespaced_stateful_set,
          list_method: :list_namespaced_stateful_set,
          replace_method: :replace_namespaced_stateful_set,
          patch_method: :patch_namespaced_stateful_set,
          delete_method: :delete_namespaced_stateful_set
        },
        ["storage.k8s.io", "v1", "csidrivers"] => {
          api_class: "StorageV1Api",
          factory: :csi_driver,
          name_prefix: "csidriver",
          namespace_scoped: false,
          create_method: :create_csi_driver,
          read_method: :read_csi_driver,
          list_method: :list_csi_driver,
          replace_method: :replace_csi_driver,
          patch_method: :patch_csi_driver,
          delete_method: :delete_csi_driver
        },
        ["storage.k8s.io", "v1", "csistoragecapacities"] => {
          api_class: "StorageV1Api",
          factory: :csi_storage_capacity,
          name_prefix: "csistoragecapacity",
          namespace_scoped: true,
          kubectl_resource: "csistoragecapacities.storage.k8s.io",
          create_method: :create_namespaced_csi_storage_capacity,
          read_method: :read_namespaced_csi_storage_capacity,
          list_method: :list_namespaced_csi_storage_capacity,
          replace_method: :replace_namespaced_csi_storage_capacity,
          patch_method: :patch_namespaced_csi_storage_capacity,
          delete_method: :delete_namespaced_csi_storage_capacity
        },
        ["storage.k8s.io", "v1", "storageclasses"] => {
          api_class: "StorageV1Api",
          factory: :storage_class,
          name_prefix: "storageclass",
          namespace_scoped: false,
          create_method: :create_storage_class,
          read_method: :read_storage_class,
          list_method: :list_storage_class,
          replace_method: :replace_storage_class,
          patch_method: :patch_storage_class,
          delete_method: :delete_storage_class
        },
        ["autoscaling", "v1", "horizontalpodautoscalers"] => {
          api_class: "AutoscalingV1Api",
          factory: :horizontal_pod_autoscaler_v1,
          name_prefix: "hpa-v1",
          namespace_scoped: true,
          kubectl_resource: "horizontalpodautoscaler",
          create_method: :create_namespaced_horizontal_pod_autoscaler,
          read_method: :read_namespaced_horizontal_pod_autoscaler,
          list_method: :list_namespaced_horizontal_pod_autoscaler,
          replace_method: :replace_namespaced_horizontal_pod_autoscaler,
          patch_method: :patch_namespaced_horizontal_pod_autoscaler,
          delete_method: :delete_namespaced_horizontal_pod_autoscaler
        },
        ["autoscaling", "v2", "horizontalpodautoscalers"] => {
          api_class: "AutoscalingV2Api",
          factory: :horizontal_pod_autoscaler,
          name_prefix: "hpa",
          namespace_scoped: true,
          kubectl_resource: "horizontalpodautoscaler",
          create_method: :create_namespaced_horizontal_pod_autoscaler_post_apis_autoscaling_v2_namespaces_by_namespace_horizontalpodautoscalers,
          read_method: :read_namespaced_horizontal_pod_autoscaler_get_apis_autoscaling_v2_namespaces_by_namespace_horizontalpodautoscalers_by_name,
          list_method: :list_namespaced_horizontal_pod_autoscaler_get_apis_autoscaling_v2_namespaces_by_namespace_horizontalpodautoscalers,
          replace_method: :replace_namespaced_horizontal_pod_autoscaler_put_apis_autoscaling_v2_namespaces_by_namespace_horizontalpodautoscalers_by_name,
          patch_method: :patch_namespaced_horizontal_pod_autoscaler_patch_apis_autoscaling_v2_namespaces_by_namespace_horizontalpodautoscalers_by_name,
          delete_method: :delete_namespaced_horizontal_pod_autoscaler_delete_apis_autoscaling_v2_namespaces_by_namespace_horizontalpodautoscalers_by_name
        },
        ["policy", "v1", "poddisruptionbudgets"] => {
          api_class: "PolicyV1Api",
          factory: :pod_disruption_budget,
          name_prefix: "pdb",
          namespace_scoped: true,
          kubectl_resource: "poddisruptionbudget",
          create_method: :create_namespaced_pod_disruption_budget,
          read_method: :read_namespaced_pod_disruption_budget,
          list_method: :list_namespaced_pod_disruption_budget,
          replace_method: :replace_namespaced_pod_disruption_budget,
          patch_method: :patch_namespaced_pod_disruption_budget,
          delete_method: :delete_namespaced_pod_disruption_budget
        },
        ["discovery.k8s.io", "v1", "endpointslices"] => {
          api_class: "DiscoveryV1Api",
          factory: :endpoint_slice,
          name_prefix: "endpointslice",
          namespace_scoped: true,
          kubectl_resource: "endpointslices.discovery.k8s.io",
          create_method: :create_namespaced_endpoint_slice,
          read_method: :read_namespaced_endpoint_slice,
          list_method: :list_namespaced_endpoint_slice,
          replace_method: :replace_namespaced_endpoint_slice,
          patch_method: :patch_namespaced_endpoint_slice,
          delete_method: :delete_namespaced_endpoint_slice
        },
        ["coordination.k8s.io", "v1", "leases"] => {
          api_class: "CoordinationV1Api",
          factory: :lease,
          name_prefix: "lease",
          namespace_scoped: true,
          kubectl_resource: "lease",
          create_method: :create_namespaced_lease,
          read_method: :read_namespaced_lease,
          list_method: :list_namespaced_lease,
          replace_method: :replace_namespaced_lease,
          patch_method: :patch_namespaced_lease,
          delete_method: :delete_namespaced_lease
        },
        ["scheduling.k8s.io", "v1", "priorityclasses"] => {
          api_class: "SchedulingV1Api",
          factory: :priority_class,
          name_prefix: "priorityclass",
          namespace_scoped: false,
          create_method: :create_priority_class,
          read_method: :read_priority_class,
          list_method: :list_priority_class,
          replace_method: :replace_priority_class,
          patch_method: :patch_priority_class,
          delete_method: :delete_priority_class
        },
        ["core", "v1", "limit-ranges"] => {
          api_class: "CoreV1Api",
          factory: :limit_range,
          name_prefix: "limitrange",
          namespace_scoped: true,
          kubectl_resource: "limitrange",
          create_method: :create_namespaced_limit_range,
          read_method: :read_namespaced_limit_range,
          list_method: :list_namespaced_limit_range,
          replace_method: :replace_namespaced_limit_range,
          patch_method: :patch_namespaced_limit_range,
          delete_method: :delete_namespaced_limit_range
        },
        ["core", "v1", "resource-quotas"] => {
          api_class: "CoreV1Api",
          factory: :resource_quota,
          name_prefix: "resourcequota",
          namespace_scoped: true,
          kubectl_resource: "resourcequota",
          create_method: :create_namespaced_resource_quota,
          read_method: :read_namespaced_resource_quota,
          list_method: :list_namespaced_resource_quota,
          replace_method: :replace_namespaced_resource_quota,
          patch_method: :patch_namespaced_resource_quota,
          delete_method: :delete_namespaced_resource_quota
        },
        ["core", "v1", "service-accounts"] => {
          api_class: "CoreV1Api",
          factory: :service_account,
          name_prefix: "serviceaccount",
          namespace_scoped: true,
          kubectl_resource: "serviceaccount",
          create_method: :create_namespaced_service_account,
          read_method: :read_namespaced_service_account,
          list_method: :list_namespaced_service_account,
          replace_method: :replace_namespaced_service_account,
          patch_method: :patch_namespaced_service_account,
          delete_method: :delete_namespaced_service_account
        },
        ["core", "v1", "pod-templates"] => {
          api_class: "CoreV1Api",
          factory: :pod_template,
          name_prefix: "podtemplate",
          namespace_scoped: true,
          kubectl_resource: "podtemplate",
          create_method: :create_namespaced_pod_template,
          read_method: :read_namespaced_pod_template,
          list_method: :list_namespaced_pod_template,
          replace_method: :replace_namespaced_pod_template,
          patch_method: :patch_namespaced_pod_template,
          delete_method: :delete_namespaced_pod_template
        },
        ["core", "v1", "replication-controllers"] => {
          api_class: "CoreV1Api",
          factory: :replication_controller,
          name_prefix: "rc",
          namespace_scoped: true,
          kubectl_resource: "replicationcontroller",
          create_method: :create_namespaced_replication_controller,
          read_method: :read_namespaced_replication_controller,
          list_method: :list_namespaced_replication_controller,
          replace_method: :replace_namespaced_replication_controller,
          patch_method: :patch_namespaced_replication_controller,
          delete_method: :delete_namespaced_replication_controller
        },
        ["apps", "v1", "controller-revisions"] => {
          api_class: "AppsV1Api",
          factory: :controller_revision,
          name_prefix: "controllerrevision",
          namespace_scoped: true,
          kubectl_resource: "controllerrevision",
          create_method: :create_namespaced_controller_revision,
          read_method: :read_namespaced_controller_revision,
          list_method: :list_namespaced_controller_revision,
          replace_method: :replace_namespaced_controller_revision,
          patch_method: :patch_namespaced_controller_revision,
          delete_method: :delete_namespaced_controller_revision
        },
        ["batch", "v1", "cron-jobs"] => {
          api_class: "BatchV1Api",
          factory: :cron_job,
          name_prefix: "cronjob",
          namespace_scoped: true,
          kubectl_resource: "cronjob",
          create_method: :create_namespaced_cron_job,
          read_method: :read_namespaced_cron_job,
          list_method: :list_namespaced_cron_job,
          replace_method: :replace_namespaced_cron_job,
          patch_method: :patch_namespaced_cron_job,
          delete_method: :delete_namespaced_cron_job
        },
        ["storage.k8s.io", "v1", "volumeattachments"] => {
          api_class: "StorageV1Api",
          name_prefix: "volumeattachment",
          namespace_scoped: false,
          kubectl_resource: "volumeattachment",
          allow_empty_list: true,
          read_method: :read_volume_attachment,
          list_method: :list_volume_attachment,
          patch_method: :patch_volume_attachment
        },
        ["storage.k8s.io", "v1", "csinodes"] => {
          api_class: "StorageV1Api",
          name_prefix: "csinode",
          namespace_scoped: false,
          kubectl_resource: "csinode",
          read_method: :read_csi_node,
          list_method: :list_csi_node,
          patch_method: :patch_csi_node
        },
        ["storage.k8s.io", "v1", "volumeattributesclasses"] => {
          api_class: "StorageV1Api",
          factory: :volume_attributes_class,
          name_prefix: "vac",
          namespace_scoped: false,
          kubectl_resource: "volumeattributesclass",
          create_method: :create_volume_attributes_class,
          read_method: :read_volume_attributes_class,
          list_method: :list_volume_attributes_class,
          replace_method: :replace_volume_attributes_class,
          patch_method: :patch_volume_attributes_class,
          delete_method: :delete_volume_attributes_class
        },
        ["networking.k8s.io", "v1", "ipaddresses"] => {
          api_class: "NetworkingV1Api",
          factory: :ip_address,
          name_prefix: "ipaddr",
          namespace_scoped: false,
          kubectl_resource: "ipaddress",
          create_method: :create_ip_address,
          read_method: :read_ip_address,
          list_method: :list_ip_address,
          replace_method: :replace_ip_address,
          patch_method: :patch_ip_address,
          delete_method: :delete_ip_address
        },
        ["networking.k8s.io", "v1", "servicecidrs"] => {
          api_class: "NetworkingV1Api",
          factory: :service_cidr,
          name_prefix: "svcidr",
          namespace_scoped: false,
          kubectl_resource: "servicecidr",
          create_method: :create_service_cidr,
          read_method: :read_service_cidr,
          list_method: :list_service_cidr,
          replace_method: :replace_service_cidr,
          patch_method: :patch_service_cidr,
          delete_method: :delete_service_cidr
        }
      }.freeze

      WATCH_ONLY_EXECUTIONS = {
        ["core", "v1", "pods"] => {
          api_class: "CoreV1Api",
          namespace_scoped: true,
          list_method: :list_namespaced_pod
        },
        ["core", "v1", "services"] => {
          api_class: "CoreV1Api",
          namespace_scoped: true,
          list_method: :list_namespaced_service
        },
        ["apps", "v1", "deployments"] => {
          api_class: "AppsV1Api",
          namespace_scoped: true,
          list_method: :list_namespaced_deployment
        },
        ["batch", "v1", "jobs"] => {
          api_class: "BatchV1Api",
          namespace_scoped: true,
          list_method: :list_namespaced_job
        }
      }.freeze

      attr_reader :run_id

      def initialize(mode_dispatcher: ModeDispatcher.new,
                     run_id: nil,
                     cluster_manager: nil,
                     failure_reporter: nil,
                     api_discovery: nil,
                     coverage_output_path: ENV["E2E_COVERAGE_REPORT"])
        @mode_dispatcher = mode_dispatcher
        @run_id = run_id || default_run_id
        @cluster_manager = cluster_manager
        @failure_reporter = failure_reporter || FailureReporter.new(run_id: @run_id)
        @api_discovery = api_discovery
        @coverage_output_path = coverage_output_path.to_s.empty? ? nil : coverage_output_path
        @repro_command_builder = ReproCommandBuilder.new
      end

      def execute(run_context: RunContext.from_env)
        context = run_context.is_a?(RunContext) ? run_context : RunContext.from_env(run_context)
        selection = @mode_dispatcher.dispatch(context)

        coverage_reporter = CoverageReporter.new(
          run_id: run_id,
          mode: selection.mode,
          output_path: @coverage_output_path
        )
        coverage_reporter.start!(resolved_targets: selection.resolved_targets)

        cluster_manager = @cluster_manager || ClusterManager.new(
          mode: context.mode,
          kubernetes_version: context.kubernetes_version
        )
        run_error = nil
        failure_summary_path = nil
        coverage_path = nil

        begin
          with_kubeconfig(cluster_manager) do
            cluster_manager.with_cluster do
              cleanup = ResourceCleanup.new(cluster_manager: cluster_manager)
              cleanup.with_namespace do |namespace|
                selection.resolved_targets.each do |target_id|
                  execute_target_with_reporting(
                    target_id: target_id,
                    namespace: namespace,
                    cleanup: cleanup,
                    context: context,
                    coverage_reporter: coverage_reporter
                  )
                end
              end
            end
          end
        rescue StandardError => e
          run_error = e
          @failure_reporter.record_run_failure(
            error: e,
            repro_command: run_failure_repro_command(context: context, selection: selection)
          )
        ensure
          failure_summary_path = @failure_reporter.write_summary
          coverage_path = coverage_reporter.write
        end

        raise run_error if run_error

        result = {
          "runId" => run_id,
          "mode" => selection.mode,
          "kubernetesVersion" => context.kubernetes_version,
          "requestedTargets" => selection.requested_targets,
          "resolvedTargets" => selection.resolved_targets,
          "fallbackUsed" => selection.fallback_used,
          "fallbackReason" => selection.reason,
          "coveragePath" => coverage_path,
          "failureSummaryPath" => failure_summary_path,
          "coverage" => coverage_reporter.payload
        }

        summary = result.fetch("coverage").fetch("summary")
        failed = summary.fetch("failed")
        raise ExecutionError.new("real API execution had #{failed} failures", result) if failed.positive?

        unsupported = summary.fetch("unsupported")
        raise ExecutionError.new("real API execution had #{unsupported} unsupported targets", result) if unsupported.positive?

        result
      end

      private

      def with_kubeconfig(cluster_manager)
        desired = cluster_manager.kubeconfig_path.to_s
        original = ENV["KUBECONFIG"]
        override_applied = false

        unless desired.empty?
          ENV["KUBECONFIG"] = desired
          override_applied = true
        end

        yield
      ensure
        if override_applied
          original.nil? ? ENV.delete("KUBECONFIG") : ENV["KUBECONFIG"] = original
        end
      end

      def execute_target_with_reporting(target_id:, namespace:, cleanup:, context:, coverage_reporter:)
        parsed = TargetSelector.parse(target_id)
        api_method = api_method_name(parsed)
        started_at = monotonic_time

        begin
          availability = target_availability(target_id)
          unless availability.served?
            coverage_reporter.record(
              target_id: target_id,
              status: "unavailable",
              api_method: api_method,
              reason: availability.reason,
              duration_ms: elapsed_ms(started_at)
            )
            return
          end

          execute_target(parsed, namespace: namespace, cleanup: cleanup)
          coverage_reporter.record(
            target_id: target_id,
            status: "covered",
            api_method: api_method,
            duration_ms: elapsed_ms(started_at)
          )
        rescue UnsupportedTargetError => e
          coverage_reporter.record(
            target_id: target_id,
            status: "unsupported",
            api_method: api_method,
            reason: e.message,
            duration_ms: elapsed_ms(started_at)
          )
        rescue StandardError => e
          repro_command = @repro_command_builder.build(
            mode: context.mode,
            targets: [target_id],
            base_ref: context.base_ref,
            fallback_strategy: context.fallback_strategy,
            kubernetes_version: context.kubernetes_version
          )
          @failure_reporter.record(
            target_id: target_id,
            error: e,
            repro_command: repro_command,
            response_excerpt: e.message,
            api_method: api_method
          )
          coverage_reporter.record(
            target_id: target_id,
            status: "failed",
            api_method: api_method,
            reason: e.message,
            duration_ms: elapsed_ms(started_at)
          )
        end
      end

      def target_availability(target_id)
        api_discovery.target_availability(target_id)
      end

      def execute_target(parsed_target, namespace:, cleanup:)
        key = [
          parsed_target.fetch(:api_group),
          parsed_target.fetch(:version),
          parsed_target.fetch(:resource)
        ]

        operation = parsed_target.fetch(:operation)
        resource_definition = CATALOG_RESOURCE_EXECUTIONS[key]

        if resource_definition
          execute_catalog_resource_operation(resource_definition, operation, namespace: namespace, cleanup: cleanup)
          return
        end

        if operation == "watch"
          watch_definition = WATCH_ONLY_EXECUTIONS[key]
          if watch_definition
            execute_watch_operation(watch_definition, namespace: namespace)
            return
          end
        end

        case key
        when ["authentication.k8s.io", "v1", "selfsubjectreviews"]
          execute_self_subject_review_operation(operation)
        when ["authentication.k8s.io", "v1", "tokenreviews"]
          execute_token_review_operation(operation)
        when ["authorization.k8s.io", "v1", "localsubjectaccessreviews"]
          execute_local_subject_access_review_operation(operation, namespace: namespace)
        when ["authorization.k8s.io", "v1", "selfsubjectaccessreviews"]
          execute_self_subject_access_review_operation(operation, namespace: namespace)
        when ["authorization.k8s.io", "v1", "selfsubjectrulesreviews"]
          execute_self_subject_rules_review_operation(operation, namespace: namespace)
        when ["authorization.k8s.io", "v1", "subjectaccessreviews"]
          execute_subject_access_review_operation(operation, namespace: namespace)
        when %w[core v1 pods]
          execute_pod_operation(operation, namespace: namespace, cleanup: cleanup)
        when %w[core v1 services]
          execute_service_operation(operation, namespace: namespace, cleanup: cleanup)
        when %w[apps v1 deployments]
          execute_deployment_operation(operation, namespace: namespace, cleanup: cleanup)
        when %w[batch v1 jobs]
          execute_job_operation(operation, namespace: namespace, cleanup: cleanup)
        when ["rbac.authorization.k8s.io", "v1", "roles"]
          execute_role_operation(operation, namespace: namespace, cleanup: cleanup)
        when ["rbac.authorization.k8s.io", "v1", "clusterroles"]
          execute_cluster_role_operation(operation, namespace: namespace, cleanup: cleanup)
        when ["rbac.authorization.k8s.io", "v1", "rolebindings"]
          execute_role_binding_operation(operation, namespace: namespace, cleanup: cleanup)
        when ["rbac.authorization.k8s.io", "v1", "clusterrolebindings"]
          execute_cluster_role_binding_operation(operation, namespace: namespace, cleanup: cleanup)
        when ["networking.k8s.io", "v1", "ingresses"]
          execute_ingress_operation(operation, namespace: namespace, cleanup: cleanup)
        when ["networking.k8s.io", "v1", "networkpolicies"]
          execute_network_policy_operation(operation, namespace: namespace, cleanup: cleanup)
        when ["networking.k8s.io", "v1", "ingressclasses"]
          execute_ingress_class_operation(operation, namespace: namespace, cleanup: cleanup)
        when ["core", "v1", "config-maps"]
          execute_config_map_operation(operation, namespace: namespace, cleanup: cleanup)
        when ["core", "v1", "secrets"]
          execute_secret_operation(operation, namespace: namespace, cleanup: cleanup)
        when ["core", "v1", "namespaces"]
          execute_namespace_operation(operation, namespace: namespace, cleanup: cleanup)
        when ["custom", "v1", "customobjects"], ["custom", "v1", "customobjects-cluster"]
          execute_custom_object_operation(operation, namespace: namespace, cleanup: cleanup, cluster_scoped: key == ["custom", "v1", "customobjects-cluster"])
        else
          raise UnsupportedTargetError, "no executor registered for #{parsed_target.fetch(:id)}"
        end
      end

      def execute_self_subject_review_operation(operation)
        raise UnsupportedTargetError, "operation '#{operation}' is not implemented for authentication.k8s.io/v1/selfsubjectreviews" unless operation == "create"

        api = Kubernetes::AuthenticationV1Api.new(build_api_client)
        review = api.create_self_subject_review(Factories.self_subject_review)
        user_info = nested_value(review, :status, :user_info)
        raise "expected SelfSubjectReview response to include status.user_info" if user_info.nil?
      end

      def execute_token_review_operation(operation)
        raise UnsupportedTargetError, "operation '#{operation}' is not implemented for authentication.k8s.io/v1/tokenreviews" unless operation == "create"

        api = Kubernetes::AuthenticationV1Api.new(build_api_client)
        review = api.create_token_review(Factories.token_review(token: "kruby-e2e.invalid-token"))
        authenticated = nested_value(review, :status, :authenticated)
        error = nested_value(review, :status, :error)
        return unless authenticated.nil? && error.to_s.strip.empty?

        status = nested_value(review, :status)
        serialized_status = status.respond_to?(:to_hash) ? status.to_hash : status
        raise "expected TokenReview response to include status.authenticated or status.error, got #{serialized_status.inspect}"
      end

      def execute_local_subject_access_review_operation(operation, namespace:)
        raise UnsupportedTargetError, "operation '#{operation}' is not implemented for authorization.k8s.io/v1/localsubjectaccessreviews" unless operation == "create"

        api = Kubernetes::AuthorizationV1Api.new(build_api_client)
        review = api.create_namespaced_local_subject_access_review(
          namespace,
          Factories.local_subject_access_review(namespace: namespace)
        )
        assert_subject_access_review_response!(review, "LocalSubjectAccessReview")
      end

      def execute_self_subject_access_review_operation(operation, namespace:)
        raise UnsupportedTargetError, "operation '#{operation}' is not implemented for authorization.k8s.io/v1/selfsubjectaccessreviews" unless operation == "create"

        api = Kubernetes::AuthorizationV1Api.new(build_api_client)
        review = api.create_self_subject_access_review(Factories.self_subject_access_review(namespace: namespace))
        assert_subject_access_review_response!(review, "SelfSubjectAccessReview")
      end

      def execute_self_subject_rules_review_operation(operation, namespace:)
        raise UnsupportedTargetError, "operation '#{operation}' is not implemented for authorization.k8s.io/v1/selfsubjectrulesreviews" unless operation == "create"

        api = Kubernetes::AuthorizationV1Api.new(build_api_client)
        review = api.create_self_subject_rules_review(Factories.self_subject_rules_review(namespace: namespace))
        resource_rules = nested_value(review, :status, :resource_rules)
        raise "expected SelfSubjectRulesReview response to include status.resource_rules" if resource_rules.nil?
      end

      def execute_subject_access_review_operation(operation, namespace:)
        raise UnsupportedTargetError, "operation '#{operation}' is not implemented for authorization.k8s.io/v1/subjectaccessreviews" unless operation == "create"

        api = Kubernetes::AuthorizationV1Api.new(build_api_client)
        review = api.create_subject_access_review(Factories.subject_access_review(namespace: namespace))
        assert_subject_access_review_response!(review, "SubjectAccessReview")
      end

      def execute_pod_operation(operation, namespace:, cleanup:)
        api = Kubernetes::CoreV1Api.new(build_api_client)

        case operation
        when "create"
          name = seed_pod(api, namespace: namespace, cleanup: cleanup)
          pod = api.read_namespaced_pod(name, namespace)
          assert_resource_name!(pod, name)
        when "get"
          name = seed_pod(api, namespace: namespace, cleanup: cleanup)
          pod = api.read_namespaced_pod(name, namespace)
          assert_resource_name!(pod, name)
        when "list"
          name = seed_pod(api, namespace: namespace, cleanup: cleanup)
          list = api.list_namespaced_pod(namespace)
          assert_list_includes!(list, name)
        when "patch"
          name = seed_pod(api, namespace: namespace, cleanup: cleanup)
          api.patch_namespaced_pod(name, namespace, [
                                     {
                                       op: "add",
                                       path: "/metadata/labels/e2e-patched",
                                       value: "true"
                                     }
                                   ])
          pod = api.read_namespaced_pod(name, namespace)
          labels = resource_labels(pod)
          raise "patch verification failed for pod #{name}" unless labels["e2e-patched"] == "true"
        when "update"
          name = seed_pod(api, namespace: namespace, cleanup: cleanup)
          with_conflict_retry do
            pod = api.read_namespaced_pod(name, namespace)
            api.replace_namespaced_pod(
              name,
              namespace,
              with_updated_label(pod, key: "e2e-updated", value: "true")
            )
          end
          pod = api.read_namespaced_pod(name, namespace)
          labels = resource_labels(pod)
          raise "update verification failed for pod #{name}" unless labels["e2e-updated"] == "true"
        when "delete"
          name = seed_pod(api, namespace: namespace, cleanup: cleanup)
          api.delete_namespaced_pod(name, namespace, grace_period_seconds: 0)
          wait_for_resource_absence!("pod #{namespace}/#{name}") do
            resource_present? { api.read_namespaced_pod(name, namespace) }
          end
        else
          raise UnsupportedTargetError, "operation '#{operation}' is not implemented for core/v1/pods"
        end
      end

      def execute_service_operation(operation, namespace:, cleanup:)
        api = Kubernetes::CoreV1Api.new(build_api_client)

        case operation
        when "create"
          name = seed_service(api, namespace: namespace, cleanup: cleanup)
          service = api.read_namespaced_service(name, namespace)
          assert_resource_name!(service, name)
        when "get"
          name = seed_service(api, namespace: namespace, cleanup: cleanup)
          service = api.read_namespaced_service(name, namespace)
          assert_resource_name!(service, name)
        when "list"
          name = seed_service(api, namespace: namespace, cleanup: cleanup)
          list = api.list_namespaced_service(namespace)
          assert_list_includes!(list, name)
        when "patch"
          name = seed_service(api, namespace: namespace, cleanup: cleanup)
          api.patch_namespaced_service(name, namespace, [
                                         {
                                           op: "add",
                                           path: "/metadata/labels/e2e-patched",
                                           value: "true"
                                         }
                                       ])
          service = api.read_namespaced_service(name, namespace)
          labels = resource_labels(service)
          raise "patch verification failed for service #{name}" unless labels["e2e-patched"] == "true"
        when "update"
          name = seed_service(api, namespace: namespace, cleanup: cleanup)
          with_conflict_retry do
            service = api.read_namespaced_service(name, namespace)
            api.replace_namespaced_service(
              name,
              namespace,
              with_updated_label(service, key: "e2e-updated", value: "true")
            )
          end
          service = api.read_namespaced_service(name, namespace)
          labels = resource_labels(service)
          raise "update verification failed for service #{name}" unless labels["e2e-updated"] == "true"
        when "delete"
          name = seed_service(api, namespace: namespace, cleanup: cleanup)
          api.delete_namespaced_service(name, namespace)
          wait_for_resource_absence!("service #{namespace}/#{name}") do
            resource_present? { api.read_namespaced_service(name, namespace) }
          end
        else
          raise UnsupportedTargetError, "operation '#{operation}' is not implemented for core/v1/services"
        end
      end

      def execute_deployment_operation(operation, namespace:, cleanup:)
        api = Kubernetes::AppsV1Api.new(build_api_client)

        case operation
        when "create"
          name = seed_deployment(api, namespace: namespace, cleanup: cleanup)
          deployment = api.read_namespaced_deployment(name, namespace)
          assert_resource_name!(deployment, name)
        when "get"
          name = seed_deployment(api, namespace: namespace, cleanup: cleanup)
          deployment = api.read_namespaced_deployment(name, namespace)
          assert_resource_name!(deployment, name)
        when "list"
          name = seed_deployment(api, namespace: namespace, cleanup: cleanup)
          list = api.list_namespaced_deployment(namespace)
          assert_list_includes!(list, name)
        when "patch"
          name = seed_deployment(api, namespace: namespace, cleanup: cleanup)
          api.patch_namespaced_deployment(name, namespace, [
                                            {
                                              op: "add",
                                              path: "/metadata/labels/e2e-patched",
                                              value: "true"
                                            }
                                          ])
          deployment = api.read_namespaced_deployment(name, namespace)
          labels = resource_labels(deployment)
          raise "patch verification failed for deployment #{name}" unless labels["e2e-patched"] == "true"
        when "update"
          name = seed_deployment(api, namespace: namespace, cleanup: cleanup)
          with_conflict_retry do
            deployment = api.read_namespaced_deployment(name, namespace)
            api.replace_namespaced_deployment(
              name,
              namespace,
              with_updated_label(deployment, key: "e2e-updated", value: "true")
            )
          end
          deployment = api.read_namespaced_deployment(name, namespace)
          labels = resource_labels(deployment)
          raise "update verification failed for deployment #{name}" unless labels["e2e-updated"] == "true"
        when "delete"
          name = seed_deployment(api, namespace: namespace, cleanup: cleanup)
          api.delete_namespaced_deployment(name, namespace, grace_period_seconds: 0)
          wait_for_resource_absence!("deployment #{namespace}/#{name}") do
            resource_present? { api.read_namespaced_deployment(name, namespace) }
          end
        else
          raise UnsupportedTargetError, "operation '#{operation}' is not implemented for apps/v1/deployments"
        end
      end

      def execute_job_operation(operation, namespace:, cleanup:)
        api = Kubernetes::BatchV1Api.new(build_api_client)

        case operation
        when "create"
          name = seed_job(api, namespace: namespace, cleanup: cleanup)
          job = api.read_namespaced_job(name, namespace)
          assert_resource_name!(job, name)
        when "get"
          name = seed_job(api, namespace: namespace, cleanup: cleanup)
          job = api.read_namespaced_job(name, namespace)
          assert_resource_name!(job, name)
        when "list"
          name = seed_job(api, namespace: namespace, cleanup: cleanup)
          list = api.list_namespaced_job(namespace)
          assert_list_includes!(list, name)
        when "patch"
          name = seed_job(api, namespace: namespace, cleanup: cleanup)
          api.patch_namespaced_job(name, namespace, [
                                     {
                                       op: "add",
                                       path: "/metadata/labels/e2e-patched",
                                       value: "true"
                                     }
                                   ])
          job = api.read_namespaced_job(name, namespace)
          labels = resource_labels(job)
          raise "patch verification failed for job #{name}" unless labels["e2e-patched"] == "true"
        when "update"
          name = seed_job(api, namespace: namespace, cleanup: cleanup)
          with_conflict_retry do
            job = api.read_namespaced_job(name, namespace)
            api.replace_namespaced_job(
              name,
              namespace,
              with_updated_label(job, key: "e2e-updated", value: "true")
            )
          end
          job = api.read_namespaced_job(name, namespace)
          labels = resource_labels(job)
          raise "update verification failed for job #{name}" unless labels["e2e-updated"] == "true"
        when "delete"
          name = seed_job(api, namespace: namespace, cleanup: cleanup)
          api.delete_namespaced_job(name, namespace, grace_period_seconds: 0)
          wait_for_resource_absence!("job #{namespace}/#{name}") do
            resource_present? { api.read_namespaced_job(name, namespace) }
          end
        else
          raise UnsupportedTargetError, "operation '#{operation}' is not implemented for batch/v1/jobs"
        end
      end

      def execute_catalog_resource_operation(definition, operation, namespace:, cleanup:)
        method_key = OPERATION_METHOD_KEYS.fetch(operation, nil)
        method_name = method_key && definition[method_key]
        raise UnsupportedTargetError, "operation '#{operation}' is not implemented for catalog resource" unless method_name

        api = Kubernetes.const_get(definition.fetch(:api_class)).new(build_api_client)

        case operation
        when "create"
          name = seed_catalog_resource(api, definition, namespace: namespace, cleanup: cleanup)
          resource = read_catalog_resource(api, definition, name, namespace: namespace)
          assert_resource_name!(resource, name)
        when "get"
          name = definition[:factory] ? seed_catalog_resource(api, definition, namespace: namespace, cleanup: cleanup) : first_resource_name_from_list(api, definition)
          resource = read_catalog_resource(api, definition, name, namespace: namespace)
          assert_resource_name!(resource, name)
        when "list"
          name = seed_catalog_resource(api, definition, namespace: namespace, cleanup: cleanup) if definition[:factory]
          list = list_catalog_resources(api, definition, namespace: namespace)
          if name
            assert_list_includes!(list, name)
          elsif !definition[:allow_empty_list]
            raise "expected at least one resource in list" if resource_items(list).empty?
          end
        when "patch"
          if definition[:factory]
            name = seed_catalog_resource(api, definition, namespace: namespace, cleanup: cleanup)
          else
            name = first_resource_name_from_list(api, definition)
            cleanup.register { patch_catalog_resource(api, definition, name, namespace: nil, key: "e2e-patched", value: "false") rescue nil }
          end

          patch_catalog_resource(api, definition, name, namespace: namespace, key: "e2e-patched", value: "true")
          resource = read_catalog_resource(api, definition, name, namespace: namespace)
          labels = resource_labels(resource)
          raise "patch verification failed for #{name}" unless labels["e2e-patched"] == "true"
        when "update"
          name = seed_catalog_resource(api, definition, namespace: namespace, cleanup: cleanup)
          with_conflict_retry do
            resource = read_catalog_resource(api, definition, name, namespace: namespace)
            replace_catalog_resource(
              api,
              definition,
              name,
              with_updated_label(resource, key: "e2e-updated", value: "true"),
              namespace: namespace
            )
          end
          resource = read_catalog_resource(api, definition, name, namespace: namespace)
          labels = resource_labels(resource)
          raise "update verification failed for #{name}" unless labels["e2e-updated"] == "true"
        when "delete"
          name = seed_catalog_resource(api, definition, namespace: namespace, cleanup: cleanup)
          delete_catalog_resource(api, definition, name, namespace: namespace)
          wait_for_resource_absence!("#{definition.fetch(:api_class)} #{name}") do
            resource_present? { read_catalog_resource(api, definition, name, namespace: namespace) }
          end
        when "watch"
          seed_catalog_resource(api, definition, namespace: namespace, cleanup: cleanup) if definition[:factory]
          execute_watch_operation(definition, namespace: namespace, api: api)
        end
      end

      def seed_catalog_resource(api, definition, namespace:, cleanup:)
        name = catalog_resource_name(definition)
        body = Factories.public_send(definition.fetch(:factory), name: name, labels: base_labels(name))

        if definition.fetch(:namespace_scoped)
          api.public_send(definition.fetch(:create_method), namespace, body)
          cleanup.track_resource(namespace: namespace, resource_type: definition.fetch(:kubectl_resource), name: name)
        else
          api.public_send(definition.fetch(:create_method), body)
          cleanup.register { api.public_send(definition.fetch(:delete_method), name) rescue nil }
        end

        name
      end

      def read_catalog_resource(api, definition, name, namespace:)
        if definition.fetch(:namespace_scoped)
          api.public_send(definition.fetch(:read_method), name, namespace)
        else
          api.public_send(definition.fetch(:read_method), name)
        end
      end

      def list_catalog_resources(api, definition, namespace:)
        if definition.fetch(:namespace_scoped)
          api.public_send(definition.fetch(:list_method), namespace)
        else
          api.public_send(definition.fetch(:list_method))
        end
      end

      def first_resource_name_from_list(api, definition)
        list = list_catalog_resources(api, definition, namespace: nil)
        names = resource_items(list).map { |item| resource_name_from(item) }.compact
        names.first || raise("expected at least one #{definition.fetch(:api_class)} resource in the cluster")
      end

      def catalog_resource_name(definition)
        return test_ip_address_name if definition[:factory] == :ip_address

        resource_name(definition.fetch(:name_prefix))
      end

      def test_ip_address_name
        current = @test_ip_address_octet || SecureRandom.random_number(254)
        @test_ip_address_octet = (current % 254) + 1
        "192.0.2.#{@test_ip_address_octet}"
      end

      def patch_catalog_resource(api, definition, name, namespace:, key:, value:)
        patch_body = [
          {
            op: "add",
            path: "/metadata/labels/#{key}",
            value: value
          }
        ]

        if definition.fetch(:namespace_scoped)
          api.public_send(definition.fetch(:patch_method), name, namespace, patch_body)
        else
          api.public_send(definition.fetch(:patch_method), name, patch_body)
        end
      end

      def replace_catalog_resource(api, definition, name, body, namespace:)
        if definition.fetch(:namespace_scoped)
          api.public_send(definition.fetch(:replace_method), name, namespace, body)
        else
          api.public_send(definition.fetch(:replace_method), name, body)
        end
      end

      def delete_catalog_resource(api, definition, name, namespace:)
        if definition.fetch(:namespace_scoped)
          api.public_send(definition.fetch(:delete_method), name, namespace)
        else
          api.public_send(definition.fetch(:delete_method), name)
        end
      end

      def execute_watch_operation(definition, namespace:, api: nil)
        api ||= Kubernetes.const_get(definition.fetch(:api_class)).new(build_api_client)
        watch_opts = {
          watch: true,
          timeout_seconds: 1,
          debug_return_type: "String"
        }

        if definition.fetch(:namespace_scoped)
          api.public_send(definition.fetch(:list_method), namespace, watch_opts)
        else
          api.public_send(definition.fetch(:list_method), watch_opts)
        end
      end

      def first_node_name!(api)
        names = resource_items(api.list_node).map { |item| resource_name_from(item) }.compact
        names.first || raise("expected at least one node in the cluster")
      end

      def remove_node_label(api, name, key)
        api.patch_node(name, [{ op: "remove", path: "/metadata/labels/#{key}" }])
      rescue StandardError => e
        raise unless not_found_error?(e) || unprocessable_entity_error?(e)
      end

      def execute_role_operation(operation, namespace:, cleanup:)
        api = Kubernetes::RbacAuthorizationV1Api.new(build_api_client)

        case operation
        when "create"
          name = seed_role(api, namespace: namespace, cleanup: cleanup)
          role = api.read_namespaced_role(name, namespace)
          assert_resource_name!(role, name)
        when "get"
          name = seed_role(api, namespace: namespace, cleanup: cleanup)
          role = api.read_namespaced_role(name, namespace)
          assert_resource_name!(role, name)
        when "list"
          name = seed_role(api, namespace: namespace, cleanup: cleanup)
          list = api.list_namespaced_role(namespace)
          assert_list_includes!(list, name)
        when "patch"
          name = seed_role(api, namespace: namespace, cleanup: cleanup)
          api.patch_namespaced_role(name, namespace, [
                                        {
                                          op: "add",
                                          path: "/metadata/labels/e2e-patched",
                                          value: "true"
                                        }
                                      ])
          role = api.read_namespaced_role(name, namespace)
          labels = resource_labels(role)
          raise "patch verification failed for role #{name}" unless labels["e2e-patched"] == "true"
        when "update"
          name = seed_role(api, namespace: namespace, cleanup: cleanup)
          with_conflict_retry do
            role = api.read_namespaced_role(name, namespace)
            api.replace_namespaced_role(
              name,
              namespace,
              with_updated_label(role, key: "e2e-updated", value: "true")
            )
          end
          role = api.read_namespaced_role(name, namespace)
          labels = resource_labels(role)
          raise "update verification failed for role #{name}" unless labels["e2e-updated"] == "true"
        when "delete"
          name = seed_role(api, namespace: namespace, cleanup: cleanup)
          api.delete_namespaced_role(name, namespace)
          wait_for_resource_absence!("role #{namespace}/#{name}") do
            resource_present? { api.read_namespaced_role(name, namespace) }
          end
        else
          raise UnsupportedTargetError, "operation '#{operation}' is not implemented for rbac.authorization.k8s.io/v1/roles"
        end
      end

      def execute_cluster_role_operation(operation, namespace:, cleanup:)
        api = Kubernetes::RbacAuthorizationV1Api.new(build_api_client)

        case operation
        when "create"
          name = seed_cluster_role(api, namespace: namespace, cleanup: cleanup)
          cluster_role = api.read_cluster_role(name)
          assert_resource_name!(cluster_role, name)
        when "get"
          name = seed_cluster_role(api, namespace: namespace, cleanup: cleanup)
          cluster_role = api.read_cluster_role(name)
          assert_resource_name!(cluster_role, name)
        when "list"
          name = seed_cluster_role(api, namespace: namespace, cleanup: cleanup)
          list = api.list_cluster_role
          assert_list_includes!(list, name)
        when "patch"
          name = seed_cluster_role(api, namespace: namespace, cleanup: cleanup)
          api.patch_cluster_role(name, [
                                     {
                                       op: "add",
                                       path: "/metadata/labels/e2e-patched",
                                       value: "true"
                                     }
                                   ])
          cluster_role = api.read_cluster_role(name)
          labels = resource_labels(cluster_role)
          raise "patch verification failed for clusterrole #{name}" unless labels["e2e-patched"] == "true"
        when "update"
          name = seed_cluster_role(api, namespace: namespace, cleanup: cleanup)
          with_conflict_retry do
            cluster_role = api.read_cluster_role(name)
            api.replace_cluster_role(
              name,
              with_updated_label(cluster_role, key: "e2e-updated", value: "true")
            )
          end
          cluster_role = api.read_cluster_role(name)
          labels = resource_labels(cluster_role)
          raise "update verification failed for clusterrole #{name}" unless labels["e2e-updated"] == "true"
        when "delete"
          name = seed_cluster_role(api, namespace: namespace, cleanup: cleanup)
          api.delete_cluster_role(name)
          wait_for_resource_absence!("clusterrole #{name}") do
            resource_present? { api.read_cluster_role(name) }
          end
        else
          raise UnsupportedTargetError, "operation '#{operation}' is not implemented for rbac.authorization.k8s.io/v1/clusterroles"
        end
      end

      def execute_role_binding_operation(operation, namespace:, cleanup:)
        api = Kubernetes::RbacAuthorizationV1Api.new(build_api_client)

        case operation
        when "create"
          name = seed_role_binding(api, namespace: namespace, cleanup: cleanup)
          binding = api.read_namespaced_role_binding(name, namespace)
          assert_resource_name!(binding, name)
        when "get"
          name = seed_role_binding(api, namespace: namespace, cleanup: cleanup)
          binding = api.read_namespaced_role_binding(name, namespace)
          assert_resource_name!(binding, name)
        when "list"
          name = seed_role_binding(api, namespace: namespace, cleanup: cleanup)
          list = api.list_namespaced_role_binding(namespace)
          assert_list_includes!(list, name)
        when "patch"
          name = seed_role_binding(api, namespace: namespace, cleanup: cleanup)
          api.patch_namespaced_role_binding(name, namespace, [
                                                {
                                                  op: "add",
                                                  path: "/metadata/labels/e2e-patched",
                                                  value: "true"
                                                }
                                              ])
          binding = api.read_namespaced_role_binding(name, namespace)
          labels = resource_labels(binding)
          raise "patch verification failed for rolebinding #{name}" unless labels["e2e-patched"] == "true"
        when "update"
          name = seed_role_binding(api, namespace: namespace, cleanup: cleanup)
          with_conflict_retry do
            binding = api.read_namespaced_role_binding(name, namespace)
            api.replace_namespaced_role_binding(
              name,
              namespace,
              with_updated_label(binding, key: "e2e-updated", value: "true")
            )
          end
          binding = api.read_namespaced_role_binding(name, namespace)
          labels = resource_labels(binding)
          raise "update verification failed for rolebinding #{name}" unless labels["e2e-updated"] == "true"
        when "delete"
          name = seed_role_binding(api, namespace: namespace, cleanup: cleanup)
          api.delete_namespaced_role_binding(name, namespace)
          wait_for_resource_absence!("rolebinding #{namespace}/#{name}") do
            resource_present? { api.read_namespaced_role_binding(name, namespace) }
          end
        else
          raise UnsupportedTargetError, "operation '#{operation}' is not implemented for rbac.authorization.k8s.io/v1/rolebindings"
        end
      end

      def execute_cluster_role_binding_operation(operation, namespace:, cleanup:)
        api = Kubernetes::RbacAuthorizationV1Api.new(build_api_client)

        case operation
        when "create"
          name = seed_cluster_role_binding(api, namespace: namespace, cleanup: cleanup)
          binding = api.read_cluster_role_binding(name)
          assert_resource_name!(binding, name)
        when "get"
          name = seed_cluster_role_binding(api, namespace: namespace, cleanup: cleanup)
          binding = api.read_cluster_role_binding(name)
          assert_resource_name!(binding, name)
        when "list"
          name = seed_cluster_role_binding(api, namespace: namespace, cleanup: cleanup)
          list = api.list_cluster_role_binding
          assert_list_includes!(list, name)
        when "patch"
          name = seed_cluster_role_binding(api, namespace: namespace, cleanup: cleanup)
          api.patch_cluster_role_binding(name, [
                                             {
                                               op: "add",
                                               path: "/metadata/labels/e2e-patched",
                                               value: "true"
                                             }
                                           ])
          binding = api.read_cluster_role_binding(name)
          labels = resource_labels(binding)
          raise "patch verification failed for clusterrolebinding #{name}" unless labels["e2e-patched"] == "true"
        when "update"
          name = seed_cluster_role_binding(api, namespace: namespace, cleanup: cleanup)
          with_conflict_retry do
            binding = api.read_cluster_role_binding(name)
            api.replace_cluster_role_binding(
              name,
              with_updated_label(binding, key: "e2e-updated", value: "true")
            )
          end
          binding = api.read_cluster_role_binding(name)
          labels = resource_labels(binding)
          raise "update verification failed for clusterrolebinding #{name}" unless labels["e2e-updated"] == "true"
        when "delete"
          name = seed_cluster_role_binding(api, namespace: namespace, cleanup: cleanup)
          api.delete_cluster_role_binding(name)
          wait_for_resource_absence!("clusterrolebinding #{name}") do
            resource_present? { api.read_cluster_role_binding(name) }
          end
        else
          raise UnsupportedTargetError, "operation '#{operation}' is not implemented for rbac.authorization.k8s.io/v1/clusterrolebindings"
        end
      end

      def seed_pod(api, namespace:, cleanup:)
        name = resource_name("pod")
        api.create_namespaced_pod(namespace, Factories.pod(name: name, labels: base_labels(name)))
        cleanup.track_resource(namespace: namespace, resource_type: "pod", name: name)
        name
      end

      def seed_service(api, namespace:, cleanup:)
        name = resource_name("service")
        api.create_namespaced_service(namespace, Factories.service(name: name, labels: base_labels(name)))
        cleanup.track_resource(namespace: namespace, resource_type: "service", name: name)
        name
      end

      def seed_deployment(api, namespace:, cleanup:)
        name = resource_name("deployment")
        api.create_namespaced_deployment(namespace, Factories.deployment(name: name, labels: base_labels(name)))
        cleanup.track_resource(namespace: namespace, resource_type: "deployment", name: name)
        name
      end

      def seed_job(api, namespace:, cleanup:)
        name = resource_name("job")
        api.create_namespaced_job(namespace, Factories.job(name: name, labels: base_labels(name)))
        cleanup.track_resource(namespace: namespace, resource_type: "job", name: name)
        name
      end

      def seed_role(api, namespace:, cleanup:)
        name = resource_name("role")
        api.create_namespaced_role(namespace, Factories.role(name: name, labels: base_labels(name)))
        cleanup.track_resource(namespace: namespace, resource_type: "role", name: name)
        name
      end

      def seed_cluster_role(api, namespace:, cleanup:)
        name = resource_name("clusterrole")
        api.create_cluster_role(Factories.cluster_role(name: name, labels: base_labels(name)))
        cleanup.register { api.delete_cluster_role(name) rescue nil }
        name
      end

      def seed_role_binding(api, namespace:, cleanup:)
        role_name = seed_role(api, namespace: namespace, cleanup: cleanup)
        name = resource_name("rolebinding")
        api.create_namespaced_role_binding(
          namespace,
          Factories.role_binding(name: name, role_name: role_name, namespace: namespace, labels: base_labels(name))
        )
        cleanup.track_resource(namespace: namespace, resource_type: "rolebinding", name: name)
        name
      end

      def seed_cluster_role_binding(api, namespace:, cleanup:)
        cluster_role_name = seed_cluster_role(api, namespace: namespace, cleanup: cleanup)
        name = resource_name("clusterrolebinding")
        api.create_cluster_role_binding(
          Factories.cluster_role_binding(name: name, cluster_role_name: cluster_role_name, labels: base_labels(name))
        )
        cleanup.register { api.delete_cluster_role_binding(name) rescue nil }
        name
      end

      def execute_ingress_operation(operation, namespace:, cleanup:)
        api = Kubernetes::NetworkingV1Api.new(build_api_client)

        case operation
        when "create"
          name = seed_ingress(api, namespace: namespace, cleanup: cleanup)
          ingress = api.read_namespaced_ingress(name, namespace)
          assert_resource_name!(ingress, name)
        when "get"
          name = seed_ingress(api, namespace: namespace, cleanup: cleanup)
          ingress = api.read_namespaced_ingress(name, namespace)
          assert_resource_name!(ingress, name)
        when "list"
          name = seed_ingress(api, namespace: namespace, cleanup: cleanup)
          list = api.list_namespaced_ingress(namespace)
          assert_list_includes!(list, name)
        when "patch"
          name = seed_ingress(api, namespace: namespace, cleanup: cleanup)
          api.patch_namespaced_ingress(name, namespace, [
                                          {
                                            op: "add",
                                            path: "/metadata/labels/e2e-patched",
                                            value: "true"
                                          }
                                        ])
          ingress = api.read_namespaced_ingress(name, namespace)
          labels = resource_labels(ingress)
          raise "patch verification failed for ingress #{name}" unless labels["e2e-patched"] == "true"
        when "update"
          name = seed_ingress(api, namespace: namespace, cleanup: cleanup)
          with_conflict_retry do
            ingress = api.read_namespaced_ingress(name, namespace)
            api.replace_namespaced_ingress(
              name,
              namespace,
              with_updated_label(ingress, key: "e2e-updated", value: "true")
            )
          end
          ingress = api.read_namespaced_ingress(name, namespace)
          labels = resource_labels(ingress)
          raise "update verification failed for ingress #{name}" unless labels["e2e-updated"] == "true"
        when "delete"
          name = seed_ingress(api, namespace: namespace, cleanup: cleanup)
          api.delete_namespaced_ingress(name, namespace)
          wait_for_resource_absence!("ingress #{namespace}/#{name}") do
            resource_present? { api.read_namespaced_ingress(name, namespace) }
          end
        else
          raise UnsupportedTargetError, "operation '#{operation}' is not implemented for networking.k8s.io/v1/ingresses"
        end
      end

      def execute_network_policy_operation(operation, namespace:, cleanup:)
        api = Kubernetes::NetworkingV1Api.new(build_api_client)

        case operation
        when "create"
          name = seed_network_policy(api, namespace: namespace, cleanup: cleanup)
          policy = api.read_namespaced_network_policy(name, namespace)
          assert_resource_name!(policy, name)
        when "get"
          name = seed_network_policy(api, namespace: namespace, cleanup: cleanup)
          policy = api.read_namespaced_network_policy(name, namespace)
          assert_resource_name!(policy, name)
        when "list"
          name = seed_network_policy(api, namespace: namespace, cleanup: cleanup)
          list = api.list_namespaced_network_policy(namespace)
          assert_list_includes!(list, name)
        when "patch"
          name = seed_network_policy(api, namespace: namespace, cleanup: cleanup)
          api.patch_namespaced_network_policy(name, namespace, [
                                                  {
                                                    op: "add",
                                                    path: "/metadata/labels/e2e-patched",
                                                    value: "true"
                                                  }
                                                ])
          policy = api.read_namespaced_network_policy(name, namespace)
          labels = resource_labels(policy)
          raise "patch verification failed for networkpolicy #{name}" unless labels["e2e-patched"] == "true"
        when "update"
          name = seed_network_policy(api, namespace: namespace, cleanup: cleanup)
          with_conflict_retry do
            policy = api.read_namespaced_network_policy(name, namespace)
            api.replace_namespaced_network_policy(
              name,
              namespace,
              with_updated_label(policy, key: "e2e-updated", value: "true")
            )
          end
          policy = api.read_namespaced_network_policy(name, namespace)
          labels = resource_labels(policy)
          raise "update verification failed for networkpolicy #{name}" unless labels["e2e-updated"] == "true"
        when "delete"
          name = seed_network_policy(api, namespace: namespace, cleanup: cleanup)
          api.delete_namespaced_network_policy(name, namespace)
          wait_for_resource_absence!("networkpolicy #{namespace}/#{name}") do
            resource_present? { api.read_namespaced_network_policy(name, namespace) }
          end
        else
          raise UnsupportedTargetError, "operation '#{operation}' is not implemented for networking.k8s.io/v1/networkpolicies"
        end
      end

      def execute_ingress_class_operation(operation, namespace:, cleanup:)
        api = Kubernetes::NetworkingV1Api.new(build_api_client)

        case operation
        when "create"
          name = seed_ingress_class(api, namespace: namespace, cleanup: cleanup)
          ingress_class = api.read_ingress_class(name)
          assert_resource_name!(ingress_class, name)
        when "get"
          name = seed_ingress_class(api, namespace: namespace, cleanup: cleanup)
          ingress_class = api.read_ingress_class(name)
          assert_resource_name!(ingress_class, name)
        when "list"
          name = seed_ingress_class(api, namespace: namespace, cleanup: cleanup)
          list = api.list_ingress_class
          assert_list_includes!(list, name)
        when "patch"
          name = seed_ingress_class(api, namespace: namespace, cleanup: cleanup)
          api.patch_ingress_class(name, [
                                      {
                                        op: "add",
                                        path: "/metadata/labels/e2e-patched",
                                        value: "true"
                                      }
                                    ])
          ingress_class = api.read_ingress_class(name)
          labels = resource_labels(ingress_class)
          raise "patch verification failed for ingressclass #{name}" unless labels["e2e-patched"] == "true"
        when "update"
          name = seed_ingress_class(api, namespace: namespace, cleanup: cleanup)
          with_conflict_retry do
            ingress_class = api.read_ingress_class(name)
            api.replace_ingress_class(
              name,
              with_updated_label(ingress_class, key: "e2e-updated", value: "true")
            )
          end
          ingress_class = api.read_ingress_class(name)
          labels = resource_labels(ingress_class)
          raise "update verification failed for ingressclass #{name}" unless labels["e2e-updated"] == "true"
        when "delete"
          name = seed_ingress_class(api, namespace: namespace, cleanup: cleanup)
          api.delete_ingress_class(name)
          wait_for_resource_absence!("ingressclass #{name}") do
            resource_present? { api.read_ingress_class(name) }
          end
        else
          raise UnsupportedTargetError, "operation '#{operation}' is not implemented for networking.k8s.io/v1/ingressclasses"
        end
      end

      def execute_config_map_operation(operation, namespace:, cleanup:)
        api = Kubernetes::CoreV1Api.new(build_api_client)

        case operation
        when "create"
          name = seed_config_map(api, namespace: namespace, cleanup: cleanup)
          config_map = api.read_namespaced_config_map(name, namespace)
          assert_resource_name!(config_map, name)
        when "get"
          name = seed_config_map(api, namespace: namespace, cleanup: cleanup)
          config_map = api.read_namespaced_config_map(name, namespace)
          assert_resource_name!(config_map, name)
        when "list"
          name = seed_config_map(api, namespace: namespace, cleanup: cleanup)
          list = api.list_namespaced_config_map(namespace)
          assert_list_includes!(list, name)
        when "patch"
          name = seed_config_map(api, namespace: namespace, cleanup: cleanup)
          api.patch_namespaced_config_map(name, namespace, [
                                              {
                                                op: "add",
                                                path: "/metadata/labels/e2e-patched",
                                                value: "true"
                                              }
                                            ])
          config_map = api.read_namespaced_config_map(name, namespace)
          labels = resource_labels(config_map)
          raise "patch verification failed for configmap #{name}" unless labels["e2e-patched"] == "true"
        when "update"
          name = seed_config_map(api, namespace: namespace, cleanup: cleanup)
          with_conflict_retry do
            config_map = api.read_namespaced_config_map(name, namespace)
            api.replace_namespaced_config_map(
              name,
              namespace,
              with_updated_label(config_map, key: "e2e-updated", value: "true")
            )
          end
          config_map = api.read_namespaced_config_map(name, namespace)
          labels = resource_labels(config_map)
          raise "update verification failed for configmap #{name}" unless labels["e2e-updated"] == "true"
        when "delete"
          name = seed_config_map(api, namespace: namespace, cleanup: cleanup)
          api.delete_namespaced_config_map(name, namespace)
          wait_for_resource_absence!("configmap #{namespace}/#{name}") do
            resource_present? { api.read_namespaced_config_map(name, namespace) }
          end
        when "delete_collection"
          name = seed_config_map(api, namespace: namespace, cleanup: cleanup)
          api.delete_collection_namespaced_config_map(
            namespace,
            label_selector: "app.kubernetes.io/instance=#{name}"
          )
          wait_for_resource_absence!("configmap collection #{namespace}/#{name}") do
            resource_present? { api.read_namespaced_config_map(name, namespace) }
          end
        else
          raise UnsupportedTargetError, "operation '#{operation}' is not implemented for core/v1/config-maps"
        end
      end

      def execute_secret_operation(operation, namespace:, cleanup:)
        api = Kubernetes::CoreV1Api.new(build_api_client)

        case operation
        when "create"
          name = seed_secret(api, namespace: namespace, cleanup: cleanup)
          secret = api.read_namespaced_secret(name, namespace)
          assert_resource_name!(secret, name)
        when "get"
          name = seed_secret(api, namespace: namespace, cleanup: cleanup)
          secret = api.read_namespaced_secret(name, namespace)
          assert_resource_name!(secret, name)
        when "list"
          name = seed_secret(api, namespace: namespace, cleanup: cleanup)
          list = api.list_namespaced_secret(namespace)
          assert_list_includes!(list, name)
        when "patch"
          name = seed_secret(api, namespace: namespace, cleanup: cleanup)
          api.patch_namespaced_secret(name, namespace, [
                                             {
                                               op: "add",
                                               path: "/metadata/labels/e2e-patched",
                                               value: "true"
                                             }
                                           ])
          secret = api.read_namespaced_secret(name, namespace)
          labels = resource_labels(secret)
          raise "patch verification failed for secret #{name}" unless labels["e2e-patched"] == "true"
        when "update"
          name = seed_secret(api, namespace: namespace, cleanup: cleanup)
          with_conflict_retry do
            secret = api.read_namespaced_secret(name, namespace)
            api.replace_namespaced_secret(
              name,
              namespace,
              with_updated_label(secret, key: "e2e-updated", value: "true")
            )
          end
          secret = api.read_namespaced_secret(name, namespace)
          labels = resource_labels(secret)
          raise "update verification failed for secret #{name}" unless labels["e2e-updated"] == "true"
        when "delete"
          name = seed_secret(api, namespace: namespace, cleanup: cleanup)
          api.delete_namespaced_secret(name, namespace)
          wait_for_resource_absence!("secret #{namespace}/#{name}") do
            resource_present? { api.read_namespaced_secret(name, namespace) }
          end
        else
          raise UnsupportedTargetError, "operation '#{operation}' is not implemented for core/v1/secrets"
        end
      end

      def execute_namespace_operation(operation, namespace:, cleanup:)
        api = Kubernetes::CoreV1Api.new(build_api_client)

        case operation
        when "create"
          name = seed_namespace(api, cleanup: cleanup)
          ns = api.read_namespace(name)
          assert_resource_name!(ns, name)
        when "get"
          name = seed_namespace(api, cleanup: cleanup)
          ns = api.read_namespace(name)
          assert_resource_name!(ns, name)
        when "list"
          name = seed_namespace(api, cleanup: cleanup)
          list = api.list_namespace
          assert_list_includes!(list, name)
        when "patch"
          name = seed_namespace(api, cleanup: cleanup)
          api.patch_namespace(name, [
                                   {
                                     op: "add",
                                     path: "/metadata/labels/e2e-patched",
                                     value: "true"
                                   }
                                 ])
          ns = api.read_namespace(name)
          labels = resource_labels(ns)
          raise "patch verification failed for namespace #{name}" unless labels["e2e-patched"] == "true"
        when "update"
          name = seed_namespace(api, cleanup: cleanup)
          with_conflict_retry do
            ns = api.read_namespace(name)
            api.replace_namespace(
              name,
              with_updated_label(ns, key: "e2e-updated", value: "true")
            )
          end
          ns = api.read_namespace(name)
          labels = resource_labels(ns)
          raise "update verification failed for namespace #{name}" unless labels["e2e-updated"] == "true"
        when "delete"
          name = seed_namespace(api, cleanup: cleanup)
          api.delete_namespace(name)
          wait_for_resource_absence!("namespace #{name}") do
            resource_present? { api.read_namespace(name) }
          end
        else
          raise UnsupportedTargetError, "operation '#{operation}' is not implemented for core/v1/namespaces"
        end
      end

      def seed_ingress(api, namespace:, cleanup:)
        name = resource_name("ingresses")
        api.create_namespaced_ingress(namespace, Factories.ingress(name: name, labels: base_labels(name)))
        cleanup.track_resource(namespace: namespace, resource_type: "ingresses", name: name)
        name
      end

      def seed_network_policy(api, namespace:, cleanup:)
        name = resource_name("netpol")
        api.create_namespaced_network_policy(namespace, Factories.network_policy(name: name, labels: base_labels(name)))
        cleanup.track_resource(namespace: namespace, resource_type: "networkpolicy", name: name)
        name
      end

      def seed_ingress_class(api, namespace:, cleanup:)
        name = resource_name("ingressclass")
        api.create_ingress_class(Factories.ingress_class(name: name, labels: base_labels(name)))
        cleanup.register { api.delete_ingress_class(name) rescue nil }
        name
      end

      def seed_config_map(api, namespace:, cleanup:)
        name = resource_name("cm")
        api.create_namespaced_config_map(namespace, Factories.config_map(name: name, labels: base_labels(name)))
        cleanup.track_resource(namespace: namespace, resource_type: "configmap", name: name)
        name
      end

      def seed_secret(api, namespace:, cleanup:)
        name = resource_name("secret")
        api.create_namespaced_secret(namespace, Factories.secret(name: name, labels: base_labels(name)))
        cleanup.track_resource(namespace: namespace, resource_type: "secret", name: name)
        name
      end

      def seed_namespace(api, cleanup:)
        name = resource_name("ns")
        api.create_namespace(Factories.namespace(name: name, labels: base_labels(name)))
        cleanup.track_resource(namespace: nil, resource_type: "namespace", name: name)
        name
      end

      # CustomObjectsApi E2E: requires a test CRD. We install a minimal CRD via
      # ApiextensionsV1Api, then exercise CRUD through CustomObjectsApi.
      TEST_CRD_GROUP = "kruby-e2e.cyberagent.co.jp"
      TEST_CRD_VERSION = "v1"
      TEST_CRD_NAMESPACED_PLURAL = "samplecrs"
      TEST_CRD_CLUSTER_PLURAL = "clustersamplecrs"

      def execute_custom_object_operation(operation, namespace:, cleanup:, cluster_scoped:)
        api = Kubernetes::CustomObjectsApi.new(build_api_client)
        crd_api = Kubernetes::ApiextensionsV1Api.new(build_api_client)

        # Ensure CRD exists (lazy one-time setup)
        ensure_test_crd(crd_api, cleanup: cleanup, cluster_scoped: cluster_scoped)

        case operation
        when "create"
          name = seed_custom_object(api, namespace: namespace, cleanup: cleanup, cluster_scoped: cluster_scoped)
          obj = read_custom_object(api, name, namespace: namespace, cluster_scoped: cluster_scoped)
          assert_resource_name!(obj, name)
        when "get"
          name = seed_custom_object(api, namespace: namespace, cleanup: cleanup, cluster_scoped: cluster_scoped)
          obj = read_custom_object(api, name, namespace: namespace, cluster_scoped: cluster_scoped)
          assert_resource_name!(obj, name)
        when "list"
          name = seed_custom_object(api, namespace: namespace, cleanup: cleanup, cluster_scoped: cluster_scoped)
          list = list_custom_objects(api, namespace: namespace, cluster_scoped: cluster_scoped)
          assert_list_includes!(list, name)
        when "patch"
          name = seed_custom_object(api, namespace: namespace, cleanup: cleanup, cluster_scoped: cluster_scoped)
          patch_custom_object(api, name, namespace: namespace, cluster_scoped: cluster_scoped)
          obj = read_custom_object(api, name, namespace: namespace, cluster_scoped: cluster_scoped)
          labels = resource_labels(obj)
          raise "patch verification failed for custom object #{name}" unless labels["e2e-patched"] == "true"
        when "update"
          name = seed_custom_object(api, namespace: namespace, cleanup: cleanup, cluster_scoped: cluster_scoped)
          with_conflict_retry do
            obj = read_custom_object(api, name, namespace: namespace, cluster_scoped: cluster_scoped)
            replace_custom_object(api, name, with_updated_label(obj, key: "e2e-updated", value: "true"), namespace: namespace, cluster_scoped: cluster_scoped)
          end
          obj = read_custom_object(api, name, namespace: namespace, cluster_scoped: cluster_scoped)
          labels = resource_labels(obj)
          raise "update verification failed for custom object #{name}" unless labels["e2e-updated"] == "true"
        when "delete"
          name = seed_custom_object(api, namespace: namespace, cleanup: cleanup, cluster_scoped: cluster_scoped)
          delete_custom_object(api, name, namespace: namespace, cluster_scoped: cluster_scoped)
          wait_for_resource_absence!("custom object #{name}") do
            resource_present? { read_custom_object(api, name, namespace: namespace, cluster_scoped: cluster_scoped) }
          end
        when "watch"
          seed_custom_object(api, namespace: namespace, cleanup: cleanup, cluster_scoped: cluster_scoped)
          watch_custom_objects(api, namespace: namespace, cluster_scoped: cluster_scoped)
        else
          raise UnsupportedTargetError, "operation '#{operation}' is not implemented for custom/v1/customobjects"
        end
      end

      def ensure_test_crd(crd_api, cleanup:, cluster_scoped:)
        plural = test_crd_plural(cluster_scoped: cluster_scoped)
        kind = test_crd_kind(cluster_scoped: cluster_scoped)
        crd_name = "#{plural}.#{TEST_CRD_GROUP}"
        crd_body = {
          "apiVersion" => "apiextensions.k8s.io/v1",
          "kind" => "CustomResourceDefinition",
          "metadata" => { "name" => crd_name },
          "spec" => {
            "group" => TEST_CRD_GROUP,
            "versions" => [{
              "name" => TEST_CRD_VERSION,
              "served" => true,
              "storage" => true,
              "schema" => {
                "openAPIV3Schema" => {
                  "type" => "object",
                  "properties" => {
                    "spec" => { "type" => "object" }
                  }
                }
              }
            }],
            "scope" => cluster_scoped ? "Cluster" : "Namespaced",
            "names" => {
              "plural" => plural,
              "singular" => cluster_scoped ? "clustersamplecr" : "samplecr",
              "kind" => kind,
              "shortNames" => [cluster_scoped ? "cscr" : "scr"]
            }
          }
        }

        begin
          crd = crd_api.read_custom_resource_definition(crd_name)
          return if crd_established?(crd)

          wait_for_crd_established!(crd_api, crd_name)
          return
        rescue StandardError => e
          raise unless not_found_error?(e)
        end

        crd_api.create_custom_resource_definition(crd_body)
        cleanup.register do
          begin
            crd_api.delete_custom_resource_definition(crd_name)
          rescue StandardError
          end
        end
        wait_for_crd_established!(crd_api, crd_name)
      end

      def seed_custom_object(api, namespace:, cleanup:, cluster_scoped:)
        name = resource_name("scr")
        body = custom_object_body(name: name, labels: base_labels(name), cluster_scoped: cluster_scoped)
        plural = test_crd_plural(cluster_scoped: cluster_scoped)

        if cluster_scoped
          api.create_cluster_custom_object(TEST_CRD_GROUP, TEST_CRD_VERSION, plural, body)
          cleanup.register do
            api.delete_cluster_custom_object(TEST_CRD_GROUP, TEST_CRD_VERSION, plural, name) rescue nil
          end
        else
          api.create_namespaced_custom_object(TEST_CRD_GROUP, TEST_CRD_VERSION, namespace, plural, body)
          cleanup.track_resource(namespace: namespace, resource_type: "custom", name: name)
        end

        name
      end

      def read_custom_object(api, name, namespace:, cluster_scoped:)
        plural = test_crd_plural(cluster_scoped: cluster_scoped)
        if cluster_scoped
          api.get_cluster_custom_object(TEST_CRD_GROUP, TEST_CRD_VERSION, plural, name)
        else
          api.get_namespaced_custom_object(TEST_CRD_GROUP, TEST_CRD_VERSION, namespace, plural, name)
        end
      end

      def list_custom_objects(api, namespace:, cluster_scoped:)
        plural = test_crd_plural(cluster_scoped: cluster_scoped)
        if cluster_scoped
          api.list_cluster_custom_object(TEST_CRD_GROUP, TEST_CRD_VERSION, plural)
        else
          api.list_namespaced_custom_object(TEST_CRD_GROUP, TEST_CRD_VERSION, namespace, plural)
        end
      end

      def patch_custom_object(api, name, namespace:, cluster_scoped:)
        patch_body = [{ "op" => "add", "path" => "/metadata/labels/e2e-patched", "value" => "true" }]
        plural = test_crd_plural(cluster_scoped: cluster_scoped)
        if cluster_scoped
          api.patch_cluster_custom_object(TEST_CRD_GROUP, TEST_CRD_VERSION, plural, name, patch_body)
        else
          api.patch_namespaced_custom_object(TEST_CRD_GROUP, TEST_CRD_VERSION, namespace, plural, name, patch_body)
        end
      end

      def replace_custom_object(api, name, body, namespace:, cluster_scoped:)
        plural = test_crd_plural(cluster_scoped: cluster_scoped)
        if cluster_scoped
          api.replace_cluster_custom_object(TEST_CRD_GROUP, TEST_CRD_VERSION, plural, name, body)
        else
          api.replace_namespaced_custom_object(TEST_CRD_GROUP, TEST_CRD_VERSION, namespace, plural, name, body)
        end
      end

      def delete_custom_object(api, name, namespace:, cluster_scoped:)
        plural = test_crd_plural(cluster_scoped: cluster_scoped)
        if cluster_scoped
          api.delete_cluster_custom_object(TEST_CRD_GROUP, TEST_CRD_VERSION, plural, name)
        else
          api.delete_namespaced_custom_object(TEST_CRD_GROUP, TEST_CRD_VERSION, namespace, plural, name)
        end
      end

      def watch_custom_objects(api, namespace:, cluster_scoped:)
        opts = { watch: true, timeout_seconds: 1, debug_return_type: "String" }
        plural = test_crd_plural(cluster_scoped: cluster_scoped)
        if cluster_scoped
          api.list_cluster_custom_object(TEST_CRD_GROUP, TEST_CRD_VERSION, plural, opts)
        else
          api.list_namespaced_custom_object(TEST_CRD_GROUP, TEST_CRD_VERSION, namespace, plural, opts)
        end
      end

      def custom_object_body(name:, labels:, cluster_scoped:)
        {
          "apiVersion" => "#{TEST_CRD_GROUP}/#{TEST_CRD_VERSION}",
          "kind" => test_crd_kind(cluster_scoped: cluster_scoped),
          "metadata" => { "name" => name, "labels" => labels },
          "spec" => { "testKey" => "testValue" }
        }
      end

      def test_crd_plural(cluster_scoped:)
        cluster_scoped ? TEST_CRD_CLUSTER_PLURAL : TEST_CRD_NAMESPACED_PLURAL
      end

      def test_crd_kind(cluster_scoped:)
        cluster_scoped ? "ClusterSampleCR" : "SampleCR"
      end

      def wait_for_crd_established!(crd_api, crd_name, timeout_seconds: CRD_ESTABLISH_TIMEOUT_SECONDS)
        deadline = monotonic_time + timeout_seconds
        loop do
          crd = crd_api.read_custom_resource_definition(crd_name)
          return if crd_established?(crd)

          break if monotonic_time >= deadline

          sleep CRD_ESTABLISH_INTERVAL_SECONDS
        end

        raise "timed out waiting for CRD #{crd_name} to become Established after #{timeout_seconds}s"
      end

      def crd_established?(crd)
        crd_conditions(crd).any? do |condition|
          condition_value(condition, "type") == "Established" &&
            condition_value(condition, "status") == "True"
        end
      end

      def crd_conditions(crd)
        if crd.is_a?(Hash)
          status = crd["status"] || crd[:status] || {}
          return status["conditions"] || status[:conditions] || []
        end

        return Array(crd.status.conditions) if crd.respond_to?(:status) && crd.status&.respond_to?(:conditions)

        []
      end

      def condition_value(condition, key)
        return condition[key] if condition.is_a?(Hash) && condition.key?(key)
        return condition[key.to_sym] if condition.is_a?(Hash) && condition.key?(key.to_sym)
        return condition.public_send(key) if condition.respond_to?(key)

        nil
      end

      def base_labels(name)
        {
          "app.kubernetes.io/name" => "kruby-e2e",
          "app.kubernetes.io/instance" => name
        }
      end

      def resource_name(prefix)
        "kruby-e2e-#{prefix}-#{SecureRandom.hex(4)}"
      end

      def nested_value(resource, *path)
        current = resource

        path.each do |key|
          if current.is_a?(Hash)
            if current.key?(key)
              current = current[key]
            elsif current.key?(key.to_s)
              current = current[key.to_s]
            elsif current.key?(key.to_sym)
              current = current[key.to_sym]
            else
              return nil
            end
          elsif current.respond_to?(key)
            current = current.public_send(key)
          else
            return nil
          end
        end

        current
      end

      def assert_subject_access_review_response!(review, kind)
        actual_kind = nested_value(review, :kind)
        raise "expected #{kind} response, got #{actual_kind.inspect}" unless actual_kind == kind

        allowed = nested_value(review, :status, :allowed)
        denied = nested_value(review, :status, :denied)
        return if allowed == true || allowed == false
        return if denied == true || denied == false

        raise "expected #{kind} response to include status.allowed or status.denied"
      end

      def assert_resource_name!(resource, expected_name)
        actual_name = resource_name_from(resource)
        raise "expected resource name #{expected_name}, got #{actual_name.inspect}" unless actual_name == expected_name
      end

      def assert_list_includes!(list_response, expected_name)
        names = resource_items(list_response).map { |item| resource_name_from(item) }
        return if names.include?(expected_name)

        raise "expected #{expected_name} to be present in list; got #{names.inspect}"
      end

      def resource_items(list_response)
        return Array(list_response["items"] || list_response[:items]) if list_response.is_a?(Hash)
        return Array(list_response.items) if list_response.respond_to?(:items)

        []
      end

      def resource_name_from(resource)
        if resource.is_a?(Hash)
          metadata = resource["metadata"] || resource[:metadata] || {}
          return metadata["name"] || metadata[:name]
        end

        return resource.metadata.name if resource.respond_to?(:metadata) && resource.metadata

        nil
      end

      def resource_labels(resource)
        if resource.is_a?(Hash)
          metadata = resource["metadata"] || resource[:metadata] || {}
          labels = metadata["labels"] || metadata[:labels] || {}
          return normalize_hash_keys(labels)
        end

        return normalize_hash_keys(resource.metadata.labels || {}) if resource.respond_to?(:metadata) && resource.metadata

        {}
      end

      def normalize_hash_keys(hash)
        hash.each_with_object({}) { |(k, v), out| out[k.to_s] = v }
      end

      def with_updated_label(resource, key:, value:)
        if resource.is_a?(Hash)
          metadata_key = resource.key?("metadata") ? "metadata" : :metadata
          resource[metadata_key] ||= {}
          labels_key = resource[metadata_key].key?("labels") ? "labels" : :labels
          resource[metadata_key][labels_key] ||= {}
          resource[metadata_key][labels_key][key] = value
          return resource
        end

        if resource.respond_to?(:metadata) && resource.metadata
          resource.metadata.labels ||= {}
          resource.metadata.labels[key] = value
        end

        resource
      end

      def run_failure_repro_command(context:, selection:)
        @repro_command_builder.build(
          mode: context.mode,
          targets: selection.mode == "targeted" ? selection.requested_targets : nil,
          base_ref: selection.mode == "changed" ? context.base_ref : nil,
          fallback_strategy: context.fallback_strategy,
          kubernetes_version: context.kubernetes_version
        )
      end

      def wait_for_resource_absence!(resource_label, timeout_seconds: DELETE_WAIT_TIMEOUT_SECONDS)
        deadline = monotonic_time + timeout_seconds
        loop do
          return unless yield

          break if monotonic_time >= deadline

          sleep DELETE_WAIT_INTERVAL_SECONDS
        end

        raise "timed out waiting for #{resource_label} deletion after #{timeout_seconds}s"
      end

      def resource_present?
        yield
        true
      rescue StandardError => e
        return false if not_found_error?(e)

        raise
      end

      def not_found_error?(error)
        error.respond_to?(:code) && error.code.to_i == 404
      end

      def conflict_error?(error)
        error.respond_to?(:code) && error.code.to_i == 409
      end

      def unprocessable_entity_error?(error)
        error.respond_to?(:code) && error.code.to_i == 422
      end

      def with_conflict_retry(attempts: CONFLICT_RETRY_ATTEMPTS)
        current_attempt = 0

        begin
          current_attempt += 1
          yield
        rescue StandardError => e
          raise unless conflict_error?(e)
          raise if current_attempt >= attempts

          sleep CONFLICT_RETRY_INTERVAL_SECONDS
          retry
        end
      end

      def api_method_name(parsed_target)
        api_group = parsed_target.fetch(:api_group)
        version = parsed_target.fetch(:version)
        resource = parsed_target.fetch(:resource)
        operation = parsed_target.fetch(:operation)
        catalog_method_name = api_method_name_for_catalog_target(
          [api_group, version, resource],
          operation
        )
        return catalog_method_name if catalog_method_name

        case [api_group, resource, operation]
        when ["core", "pods", "create"] then "CoreV1Api#create_namespaced_pod"
        when ["core", "pods", "get"] then "CoreV1Api#read_namespaced_pod"
        when ["core", "pods", "list"] then "CoreV1Api#list_namespaced_pod"
        when ["core", "pods", "update"] then "CoreV1Api#replace_namespaced_pod"
        when ["core", "pods", "patch"] then "CoreV1Api#patch_namespaced_pod"
        when ["core", "pods", "delete"] then "CoreV1Api#delete_namespaced_pod"
        when ["core", "pods", "watch"] then "CoreV1Api#watch_namespaced_pod"
        when ["core", "services", "create"] then "CoreV1Api#create_namespaced_service"
        when ["core", "services", "get"] then "CoreV1Api#read_namespaced_service"
        when ["core", "services", "list"] then "CoreV1Api#list_namespaced_service"
        when ["core", "services", "update"] then "CoreV1Api#replace_namespaced_service"
        when ["core", "services", "patch"] then "CoreV1Api#patch_namespaced_service"
        when ["core", "services", "delete"] then "CoreV1Api#delete_namespaced_service"
        when ["core", "services", "watch"] then "CoreV1Api#watch_namespaced_service"
        when ["apps", "deployments", "create"] then "AppsV1Api#create_namespaced_deployment"
        when ["apps", "deployments", "get"] then "AppsV1Api#read_namespaced_deployment"
        when ["apps", "deployments", "list"] then "AppsV1Api#list_namespaced_deployment"
        when ["apps", "deployments", "update"] then "AppsV1Api#replace_namespaced_deployment"
        when ["apps", "deployments", "patch"] then "AppsV1Api#patch_namespaced_deployment"
        when ["apps", "deployments", "delete"] then "AppsV1Api#delete_namespaced_deployment"
        when ["apps", "deployments", "watch"] then "AppsV1Api#watch_namespaced_deployment"
        when ["batch", "jobs", "create"] then "BatchV1Api#create_namespaced_job"
        when ["batch", "jobs", "get"] then "BatchV1Api#read_namespaced_job"
        when ["batch", "jobs", "list"] then "BatchV1Api#list_namespaced_job"
        when ["batch", "jobs", "update"] then "BatchV1Api#replace_namespaced_job"
        when ["batch", "jobs", "patch"] then "BatchV1Api#patch_namespaced_job"
        when ["batch", "jobs", "delete"] then "BatchV1Api#delete_namespaced_job"
        when ["batch", "jobs", "watch"] then "BatchV1Api#watch_namespaced_job"
        when ["rbac.authorization.k8s.io", "roles", "create"] then "RbacAuthorizationV1Api#create_namespaced_role"
        when ["rbac.authorization.k8s.io", "roles", "get"] then "RbacAuthorizationV1Api#read_namespaced_role"
        when ["rbac.authorization.k8s.io", "roles", "list"] then "RbacAuthorizationV1Api#list_namespaced_role"
        when ["rbac.authorization.k8s.io", "roles", "update"] then "RbacAuthorizationV1Api#replace_namespaced_role"
        when ["rbac.authorization.k8s.io", "roles", "patch"] then "RbacAuthorizationV1Api#patch_namespaced_role"
        when ["rbac.authorization.k8s.io", "roles", "delete"] then "RbacAuthorizationV1Api#delete_namespaced_role"
        when ["rbac.authorization.k8s.io", "clusterroles", "create"] then "RbacAuthorizationV1Api#create_cluster_role"
        when ["rbac.authorization.k8s.io", "clusterroles", "get"] then "RbacAuthorizationV1Api#read_cluster_role"
        when ["rbac.authorization.k8s.io", "clusterroles", "list"] then "RbacAuthorizationV1Api#list_cluster_role"
        when ["rbac.authorization.k8s.io", "clusterroles", "update"] then "RbacAuthorizationV1Api#replace_cluster_role"
        when ["rbac.authorization.k8s.io", "clusterroles", "patch"] then "RbacAuthorizationV1Api#patch_cluster_role"
        when ["rbac.authorization.k8s.io", "clusterroles", "delete"] then "RbacAuthorizationV1Api#delete_cluster_role"
        when ["rbac.authorization.k8s.io", "rolebindings", "create"] then "RbacAuthorizationV1Api#create_namespaced_role_binding"
        when ["rbac.authorization.k8s.io", "rolebindings", "get"] then "RbacAuthorizationV1Api#read_namespaced_role_binding"
        when ["rbac.authorization.k8s.io", "rolebindings", "list"] then "RbacAuthorizationV1Api#list_namespaced_role_binding"
        when ["rbac.authorization.k8s.io", "rolebindings", "update"] then "RbacAuthorizationV1Api#replace_namespaced_role_binding"
        when ["rbac.authorization.k8s.io", "rolebindings", "patch"] then "RbacAuthorizationV1Api#patch_namespaced_role_binding"
        when ["rbac.authorization.k8s.io", "rolebindings", "delete"] then "RbacAuthorizationV1Api#delete_namespaced_role_binding"
        when ["rbac.authorization.k8s.io", "clusterrolebindings", "create"] then "RbacAuthorizationV1Api#create_cluster_role_binding"
        when ["rbac.authorization.k8s.io", "clusterrolebindings", "get"] then "RbacAuthorizationV1Api#read_cluster_role_binding"
        when ["rbac.authorization.k8s.io", "clusterrolebindings", "list"] then "RbacAuthorizationV1Api#list_cluster_role_binding"
        when ["rbac.authorization.k8s.io", "clusterrolebindings", "update"] then "RbacAuthorizationV1Api#replace_cluster_role_binding"
        when ["rbac.authorization.k8s.io", "clusterrolebindings", "patch"] then "RbacAuthorizationV1Api#patch_cluster_role_binding"
        when ["rbac.authorization.k8s.io", "clusterrolebindings", "delete"] then "RbacAuthorizationV1Api#delete_cluster_role_binding"
        when ["networking.k8s.io", "ingresses", "create"] then "NetworkingV1Api#create_namespaced_ingress"
        when ["networking.k8s.io", "ingresses", "get"] then "NetworkingV1Api#read_namespaced_ingress"
        when ["networking.k8s.io", "ingresses", "list"] then "NetworkingV1Api#list_namespaced_ingress"
        when ["networking.k8s.io", "ingresses", "update"] then "NetworkingV1Api#replace_namespaced_ingress"
        when ["networking.k8s.io", "ingresses", "patch"] then "NetworkingV1Api#patch_namespaced_ingress"
        when ["networking.k8s.io", "ingresses", "delete"] then "NetworkingV1Api#delete_namespaced_ingress"
        when ["networking.k8s.io", "networkpolicies", "create"] then "NetworkingV1Api#create_namespaced_network_policy"
        when ["networking.k8s.io", "networkpolicies", "get"] then "NetworkingV1Api#read_namespaced_network_policy"
        when ["networking.k8s.io", "networkpolicies", "list"] then "NetworkingV1Api#list_namespaced_network_policy"
        when ["networking.k8s.io", "networkpolicies", "update"] then "NetworkingV1Api#replace_namespaced_network_policy"
        when ["networking.k8s.io", "networkpolicies", "patch"] then "NetworkingV1Api#patch_namespaced_network_policy"
        when ["networking.k8s.io", "networkpolicies", "delete"] then "NetworkingV1Api#delete_namespaced_network_policy"
        when ["networking.k8s.io", "ingressclasses", "create"] then "NetworkingV1Api#create_ingress_class"
        when ["networking.k8s.io", "ingressclasses", "get"] then "NetworkingV1Api#read_ingress_class"
        when ["networking.k8s.io", "ingressclasses", "list"] then "NetworkingV1Api#list_ingress_class"
        when ["networking.k8s.io", "ingressclasses", "update"] then "NetworkingV1Api#replace_ingress_class"
        when ["networking.k8s.io", "ingressclasses", "patch"] then "NetworkingV1Api#patch_ingress_class"
        when ["networking.k8s.io", "ingressclasses", "delete"] then "NetworkingV1Api#delete_ingress_class"
        when ["core", "config-maps", "create"] then "CoreV1Api#create_namespaced_config_map"
        when ["core", "config-maps", "get"] then "CoreV1Api#read_namespaced_config_map"
        when ["core", "config-maps", "list"] then "CoreV1Api#list_namespaced_config_map"
        when ["core", "config-maps", "update"] then "CoreV1Api#replace_namespaced_config_map"
        when ["core", "config-maps", "patch"] then "CoreV1Api#patch_namespaced_config_map"
        when ["core", "config-maps", "delete"] then "CoreV1Api#delete_namespaced_config_map"
        when ["core", "config-maps", "delete_collection"] then "CoreV1Api#delete_collection_namespaced_config_map"
        when ["core", "secrets", "create"] then "CoreV1Api#create_namespaced_secret"
        when ["core", "secrets", "get"] then "CoreV1Api#read_namespaced_secret"
        when ["core", "secrets", "list"] then "CoreV1Api#list_namespaced_secret"
        when ["core", "secrets", "update"] then "CoreV1Api#replace_namespaced_secret"
        when ["core", "secrets", "patch"] then "CoreV1Api#patch_namespaced_secret"
        when ["core", "secrets", "delete"] then "CoreV1Api#delete_namespaced_secret"
        when ["core", "namespaces", "create"] then "CoreV1Api#create_namespace"
        when ["core", "namespaces", "get"] then "CoreV1Api#read_namespace"
        when ["core", "namespaces", "list"] then "CoreV1Api#list_namespace"
        when ["core", "namespaces", "update"] then "CoreV1Api#replace_namespace"
        when ["core", "namespaces", "patch"] then "CoreV1Api#patch_namespace"
        when ["core", "namespaces", "delete"] then "CoreV1Api#delete_namespace"
        when ["storage.k8s.io", "volumeattachments", "get"] then "StorageV1Api#read_volume_attachment"
        when ["storage.k8s.io", "volumeattachments", "list"] then "StorageV1Api#list_volume_attachment"
        when ["storage.k8s.io", "volumeattachments", "patch"] then "StorageV1Api#patch_volume_attachment"
        when ["storage.k8s.io", "csinodes", "get"] then "StorageV1Api#read_csi_node"
        when ["storage.k8s.io", "csinodes", "list"] then "StorageV1Api#list_csi_node"
        when ["storage.k8s.io", "csinodes", "patch"] then "StorageV1Api#patch_csi_node"
        when ["storage.k8s.io", "volumeattributesclasses", "create"] then "StorageV1Api#create_volume_attributes_class"
        when ["storage.k8s.io", "volumeattributesclasses", "get"] then "StorageV1Api#read_volume_attributes_class"
        when ["storage.k8s.io", "volumeattributesclasses", "list"] then "StorageV1Api#list_volume_attributes_class"
        when ["storage.k8s.io", "volumeattributesclasses", "update"] then "StorageV1Api#replace_volume_attributes_class"
        when ["storage.k8s.io", "volumeattributesclasses", "patch"] then "StorageV1Api#patch_volume_attributes_class"
        when ["storage.k8s.io", "volumeattributesclasses", "delete"] then "StorageV1Api#delete_volume_attributes_class"
        when ["networking.k8s.io", "ipaddresses", "create"] then "NetworkingV1Api#create_ip_address"
        when ["networking.k8s.io", "ipaddresses", "get"] then "NetworkingV1Api#read_ip_address"
        when ["networking.k8s.io", "ipaddresses", "list"] then "NetworkingV1Api#list_ip_address"
        when ["networking.k8s.io", "ipaddresses", "update"] then "NetworkingV1Api#replace_ip_address"
        when ["networking.k8s.io", "ipaddresses", "patch"] then "NetworkingV1Api#patch_ip_address"
        when ["networking.k8s.io", "ipaddresses", "delete"] then "NetworkingV1Api#delete_ip_address"
        when ["networking.k8s.io", "servicecidrs", "create"] then "NetworkingV1Api#create_service_cidr"
        when ["networking.k8s.io", "servicecidrs", "get"] then "NetworkingV1Api#read_service_cidr"
        when ["networking.k8s.io", "servicecidrs", "list"] then "NetworkingV1Api#list_service_cidr"
        when ["networking.k8s.io", "servicecidrs", "update"] then "NetworkingV1Api#replace_service_cidr"
        when ["networking.k8s.io", "servicecidrs", "patch"] then "NetworkingV1Api#patch_service_cidr"
        when ["networking.k8s.io", "servicecidrs", "delete"] then "NetworkingV1Api#delete_service_cidr"
        when ["custom", "customobjects", "create"] then "CustomObjectsApi#create_namespaced_custom_object"
        when ["custom", "customobjects", "get"] then "CustomObjectsApi#get_namespaced_custom_object"
        when ["custom", "customobjects", "list"] then "CustomObjectsApi#list_namespaced_custom_object"
        when ["custom", "customobjects", "update"] then "CustomObjectsApi#replace_namespaced_custom_object"
        when ["custom", "customobjects", "patch"] then "CustomObjectsApi#patch_namespaced_custom_object"
        when ["custom", "customobjects", "delete"] then "CustomObjectsApi#delete_namespaced_custom_object"
        when ["custom", "customobjects", "watch"] then "CustomObjectsApi#list_namespaced_custom_object (watch)"
        when ["custom", "customobjects-cluster", "create"] then "CustomObjectsApi#create_cluster_custom_object"
        when ["custom", "customobjects-cluster", "get"] then "CustomObjectsApi#get_cluster_custom_object"
        when ["custom", "customobjects-cluster", "list"] then "CustomObjectsApi#list_cluster_custom_object"
        when ["custom", "customobjects-cluster", "update"] then "CustomObjectsApi#replace_cluster_custom_object"
        when ["custom", "customobjects-cluster", "patch"] then "CustomObjectsApi#patch_cluster_custom_object"
        when ["custom", "customobjects-cluster", "delete"] then "CustomObjectsApi#delete_cluster_custom_object"
        when ["custom", "customobjects-cluster", "watch"] then "CustomObjectsApi#list_cluster_custom_object (watch)"
        when ["authentication.k8s.io", "selfsubjectreviews", "create"] then "AuthenticationV1Api#create_self_subject_review"
        when ["authentication.k8s.io", "tokenreviews", "create"] then "AuthenticationV1Api#create_token_review"
        when ["authorization.k8s.io", "localsubjectaccessreviews", "create"] then "AuthorizationV1Api#create_namespaced_local_subject_access_review"
        when ["authorization.k8s.io", "selfsubjectaccessreviews", "create"] then "AuthorizationV1Api#create_self_subject_access_review"
        when ["authorization.k8s.io", "selfsubjectrulesreviews", "create"] then "AuthorizationV1Api#create_self_subject_rules_review"
        when ["authorization.k8s.io", "subjectaccessreviews", "create"] then "AuthorizationV1Api#create_subject_access_review"
        else
          nil
        end
      end

      def api_method_name_for_catalog_target(key, operation)
        definition = CATALOG_RESOURCE_EXECUTIONS[key]
        definition ||= WATCH_ONLY_EXECUTIONS[key] if operation == "watch"
        return nil unless definition

        method_key = OPERATION_METHOD_KEYS.fetch(operation, nil)
        method_name = method_key && definition[method_key]
        return nil unless method_name

        suffix = operation == "watch" ? "(watch: true)" : ""
        "#{definition.fetch(:api_class)}##{method_name}#{suffix}"
      end

      def monotonic_time
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      def elapsed_ms(started_at)
        ((monotonic_time - started_at) * 1000.0).round(2)
      end

      def api_discovery
        @api_discovery ||= ApiDiscovery.new(build_api_client)
      end

      def build_api_client
        Kubernetes.new_client_from_config
      end

      def default_run_id
        version_slug = KindVersionResolver.version_slug(ENV.fetch("E2E_KUBERNETES_VERSION", KindVersionResolver.default_kubernetes_version))
        "run-#{Time.now.utc.strftime('%Y%m%d%H%M%S')}-#{version_slug}-p#{Process.pid}"
      end
    end
  end
end

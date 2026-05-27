# frozen_string_literal: true

require "kubernetes"
require "securerandom"

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

      attr_reader :run_id

      def initialize(mode_dispatcher: ModeDispatcher.new,
                     run_id: nil,
                     cluster_manager: nil,
                     failure_reporter: nil,
                     coverage_output_path: ENV["E2E_COVERAGE_REPORT"])
        @mode_dispatcher = mode_dispatcher
        @run_id = run_id || default_run_id
        @cluster_manager = cluster_manager
        @failure_reporter = failure_reporter || FailureReporter.new(run_id: @run_id)
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

        failed = result.fetch("coverage").fetch("summary").fetch("failed")
        raise ExecutionError.new("real API execution had #{failed} failures", result) if failed.positive?

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

      def execute_target(parsed_target, namespace:, cleanup:)
        key = [
          parsed_target.fetch(:api_group),
          parsed_target.fetch(:version),
          parsed_target.fetch(:resource)
        ]

        operation = parsed_target.fetch(:operation)

        case key
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
        else
          raise UnsupportedTargetError, "no executor registered for #{parsed_target.fetch(:id)}"
        end
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

      def base_labels(name)
        {
          "app.kubernetes.io/name" => "kruby-e2e",
          "app.kubernetes.io/instance" => name
        }
      end

      def resource_name(prefix)
        "kruby-e2e-#{prefix}-#{SecureRandom.hex(4)}"
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
        return Array(list_response["items"]) if list_response.is_a?(Hash)
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
          resource["metadata"] ||= {}
          resource["metadata"]["labels"] ||= {}
          resource["metadata"]["labels"][key] = value
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
        resource = parsed_target.fetch(:resource)
        operation = parsed_target.fetch(:operation)

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
        else
          nil
        end
      end

      def monotonic_time
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      def elapsed_ms(started_at)
        ((monotonic_time - started_at) * 1000.0).round(2)
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

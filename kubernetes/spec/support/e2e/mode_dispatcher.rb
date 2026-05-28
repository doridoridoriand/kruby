# frozen_string_literal: true

require_relative "change_resolver"
require_relative "run_context"
require_relative "target_catalog"
require_relative "targets/networking_v1_ingresses"
require_relative "targets/networking_v1_networkpolicies"
require_relative "targets/networking_v1_ingressclasses"
require_relative "targets/core_v1_namespaces"
require_relative "targets/apps_v1_deployments"
require_relative "targets/apps_v1_daemonsets"
require_relative "targets/apps_v1_replicasets"
require_relative "targets/apps_v1_statefulsets"
require_relative "targets/batch_v1_jobs"
require_relative "targets/core_v1_config_maps"
require_relative "targets/core_v1_pods"
require_relative "targets/core_v1_endpoints"
require_relative "targets/core_v1_nodes"
require_relative "targets/core_v1_secrets"
require_relative "targets/core_v1_persistentvolumeclaims"
require_relative "targets/core_v1_services"
require_relative "targets/rbac_authorization_k8s_io_v1_roles"
require_relative "targets/rbac_authorization_k8s_io_v1_clusterroles"
require_relative "targets/rbac_authorization_k8s_io_v1_rolebindings"
require_relative "targets/rbac_authorization_k8s_io_v1_clusterrolebindings"

module SpecSupport
  module E2E
    class ModeDispatcher
      Selection = Struct.new(
        :mode,
        :requested_targets,
        :resolved_targets,
        :fallback_used,
        :reason,
        keyword_init: true
      )

      OPERATION_ORDER = {
        "create" => 10,
        "get" => 20,
        "list" => 30,
        "update" => 40,
        "patch" => 50,
        "delete" => 60,
        "watch" => 70
      }.freeze

      API_GROUP_ORDER = {
        "core" => 10,
        "apps" => 20,
        "batch" => 30,
        "rbac.authorization.k8s.io" => 40,
        "networking.k8s.io" => 50
      }.freeze

      attr_reader :target_catalog

      def initialize(target_catalog: nil, change_resolver: nil)
        @target_catalog = target_catalog || self.class.build_default_catalog
        @change_resolver = change_resolver
      end

      def self.build_default_catalog
        catalog = TargetCatalog.new
        Targets::CoreV1ConfigMaps.register!(catalog)
        Targets::CoreV1Namespaces.register!(catalog)
        Targets::CoreV1Pods.register!(catalog)
        Targets::CoreV1Endpoints.register!(catalog)
        Targets::CoreV1Nodes.register!(catalog)
        Targets::CoreV1Secrets.register!(catalog)
        Targets::CoreV1PersistentVolumeClaims.register!(catalog)
        Targets::CoreV1Services.register!(catalog)
        Targets::AppsV1DaemonSets.register!(catalog)
        Targets::AppsV1Deployments.register!(catalog)
        Targets::AppsV1ReplicaSets.register!(catalog)
        Targets::AppsV1StatefulSets.register!(catalog)
        Targets::BatchV1Jobs.register!(catalog)
        Targets::RbacAuthorizationV1Roles.register!(catalog)
        Targets::RbacAuthorizationV1Clusterroles.register!(catalog)
        Targets::RbacAuthorizationV1Rolebindings.register!(catalog)
        Targets::RbacAuthorizationV1Clusterrolebindings.register!(catalog)
        Targets::NetworkingV1Ingresses.register!(catalog)
        Targets::NetworkingV1Networkpolicies.register!(catalog)
        Targets::NetworkingV1Ingressclasses.register!(catalog)
        catalog
      end

      def dispatch(context = RunContext.from_env)
        run_context = context.is_a?(RunContext) ? context : RunContext.from_env(context)

        case run_context.mode
        when "targeted"
          dispatch_targeted(run_context)
        when "changed"
          dispatch_changed(run_context)
        when "full"
          Selection.new(
            mode: "full",
            requested_targets: [],
            resolved_targets: full_execution_targets,
            fallback_used: false,
            reason: nil
          )
        else
          raise ArgumentError, "unsupported mode: #{run_context.mode}"
        end
      end

      private

      def dispatch_targeted(context)
        resolved = context.requested_targets.map { |selector| target_catalog.fetch(selector).id }

        Selection.new(
          mode: "targeted",
          requested_targets: context.requested_targets,
          resolved_targets: resolved,
          fallback_used: false,
          reason: nil
        )
      end

      def dispatch_changed(context)
        resolver = @change_resolver || ChangeResolver.new(
          target_catalog: target_catalog,
          fallback_strategy: context.fallback_strategy
        )
        change_set = resolver.resolve(base_ref: context.base_ref, changed_files: context.changed_files)

        resolved = change_set.mapped_targets
                             .select { |selector| target_catalog.include?(selector) }
                             .uniq

        Selection.new(
          mode: "changed",
          requested_targets: [],
          resolved_targets: resolved,
          fallback_used: change_set.fallback_used,
          reason: change_set.reason
        )
      end

      def full_execution_targets
        target_catalog
          .all
          .sort_by do |target|
            [
              API_GROUP_ORDER.fetch(target.api_group, 100),
              target.api_group,
              target.version,
              target.resource,
              OPERATION_ORDER.fetch(target.operation, 100),
              target.operation
            ]
          end
          .map(&:id)
      end
    end
  end
end

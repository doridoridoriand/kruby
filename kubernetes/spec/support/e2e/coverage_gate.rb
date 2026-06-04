# frozen_string_literal: true

# CoverageGate compares generated API candidate methods (from coverage_inventory.json)
# against the registered E2E target catalog and produces a deterministic report.
#
# A candidate is "covered" when a target catalog entry maps to the same canonical
# API method name. Candidates not covered by any target must be explicitly excluded
# in the coverage policy file; otherwise the gate fails.
#
# Usage:
#   result = SpecSupport::E2E::CoverageGate.new.check
#   puts result.report

require "json"
require "yaml"

module SpecSupport
  module E2E
    class CoverageGate
      # Immutable result of a coverage gate evaluation.
      class GateResult
        attr_reader :total_candidates, :covered, :excluded, :missing, :missing_methods, :passing

        def initialize(total_candidates:, covered:, excluded:, missing:, missing_methods:)
          @total_candidates = total_candidates
          @covered = covered
          @excluded = excluded
          @missing = missing
          @missing_methods = missing_methods
          @passing = missing.zero?
        end

        def summary
          {
            "totalCandidates" => total_candidates,
            "covered" => covered,
            "excludedByPolicy" => excluded,
            "missing" => missing,
            "passing" => passing
          }
        end

        def to_s
          lines = [
            "=== E2E Coverage Gate ===",
            "Total candidates : #{total_candidates}",
            "Covered          : #{covered}",
            "Excluded         : #{excluded}",
            "Missing          : #{missing}",
            "Passing          : #{passing}"
          ]

          lines << ""
          lines << "Missing candidates (not covered, not excluded):"
          missing_methods.each { |m| lines << "  - #{m}" }

          lines.join("\n")
        end
      end

      attr_reader :inventory_path, :policy_path

      def initialize(inventory_path: nil, policy_path: nil)
        @inventory_path = inventory_path || default_inventory_path
        @policy_path = policy_path || default_policy_path
      end

      # Evaluate the coverage gate and return a GateResult.
      def check
        candidates = load_candidates

        candidate_set = candidates.map { |c| canonicalize(c["api"], c["method"]) }.to_set
        covered_set = load_covered_methods
        excluded_set = apply_exclusions(candidates)

        missing = (candidate_set - covered_set - excluded_set).sort

        GateResult.new(
          total_candidates: candidate_set.size,
          covered: (candidate_set & covered_set).size,
          excluded: (candidate_set & excluded_set).size,
          missing: missing.size,
          missing_methods: missing
        )
      end

      # Persist a JSON report next to the inventory file.
      def write_report(result = nil)
        result ||= check
        dir = File.dirname(inventory_path)
        path = File.join(dir, "coverage_gate_report.json")

        File.write(path, JSON.pretty_generate({
          "generatedAt" => Time.now.utc.iso8601,
          "inventory" => inventory_path,
          "policy" => policy_path,
          "result" => result.summary,
          "missing" => result.missing_methods
        }))
        path
      end

      private

      # ---------------------------------------------------------------------------
      # Path helpers
      # ---------------------------------------------------------------------------

      def default_inventory_path
        File.expand_path("../../../../specs/002-real-api-e2e-coverage/coverage_inventory.json", __dir__)
      end

      def default_policy_path
        File.expand_path("coverage_policy.yml", __dir__)
      end

      # ---------------------------------------------------------------------------
      # Data loading
      # ---------------------------------------------------------------------------

      def load_candidates
        return [] unless File.exist?(inventory_path)
        data = JSON.parse(File.read(inventory_path))
        data.fetch("candidates", [])
      end

      def load_policy
        return {} unless File.exist?(policy_path)
        YAML.safe_load(File.read(policy_path), permitted_classes: [], aliases: false) || {}
      end

      # ---------------------------------------------------------------------------
      # Canonicalization
      # ---------------------------------------------------------------------------

      # Convert inventory api + method to canonical form.
      #   "admissionregistration_v1_api" + "create_mutating_webhook_configuration"
      # => "AdmissionregistrationV1Api#create_mutating_webhook_configuration"
      def canonicalize(api, method)
        api_class = api.split("_").map(&:capitalize).join("")
        "#{api_class}##{method}"
      end

      # ---------------------------------------------------------------------------
      # Covered methods (from target catalog → API method names)
      # ---------------------------------------------------------------------------

      def load_covered_methods
        # Always use the self-contained method set so this file is testable
        # without loading the full Executor (which requires the Kubernetes gem).
        COVERED_METHODS.to_set
      end

      # ---------------------------------------------------------------------------
      # Exclusions (from policy file)
      # ---------------------------------------------------------------------------

      # Apply two kinds of exclusions from the policy file:
      #
      # 1. exclude_method_patterns  – regex patterns matched against method names
      # 2. explicitly_excluded_apis – API class prefixes to exclude entirely
      def apply_exclusions(candidates)
        policy = load_policy

        method_patterns = policy.fetch("exclude_method_patterns", []).map do |rule|
          rule.is_a?(Hash) ? rule.fetch("pattern", "") : rule.to_s
        end.reject(&:empty?)

        api_exclusions = policy.fetch("explicitly_excluded_apis", []).map do |rule|
          rule.is_a?(Hash) ? rule.fetch("api", "") : rule.to_s
        end.reject(&:empty?)

        candidates.each_with_object(Set.new) do |c, excluded|
          method = c.fetch("method")
          canon = canonicalize(c.fetch("api"), method)

          # Method-level regex patterns
          match = method_patterns.any? { |p| Regexp.new(p).match?(method) }
          if match
            excluded << canon
            next
          end

          # API-level exclusions (prefix match on canonical api class)
          api_class = c.fetch("api").split("_").map(&:capitalize).join("")
          api_match = api_exclusions.any? { |a| api_class.start_with?(a) }
          if api_match
            excluded << canon
            next
          end
        end
      end

      # ---------------------------------------------------------------------------
      # Covered method names — mirrors Executor#api_method_name mapping
      # ---------------------------------------------------------------------------

      # Derived from:
      #   CATALOG_RESOURCE_EXECUTIONS  (executor.rb:46)
      #   WATCH_ONLY_EXECUTIONS        (executor.rb:221)
      #   api_method_name case         (executor.rb:1573-1661)
      #
      # Each entry is "ApiClass#method_name" exactly as Executor#api_method_name
      # would return it for a given target.
      COVERED_METHODS = [
        # CoreV1Api — namespaces
        "CoreV1Api#create_namespace",
        "CoreV1Api#read_namespace",
        "CoreV1Api#list_namespace",
        "CoreV1Api#replace_namespace",
        "CoreV1Api#patch_namespace",
        "CoreV1Api#delete_namespace",
        # CoreV1Api — pods
        "CoreV1Api#create_namespaced_pod",
        "CoreV1Api#read_namespaced_pod",
        "CoreV1Api#list_namespaced_pod",
        "CoreV1Api#replace_namespaced_pod",
        "CoreV1Api#patch_namespaced_pod",
        "CoreV1Api#delete_namespaced_pod",
        "CoreV1Api#watch_namespaced_pod",
        # CoreV1Api — services
        "CoreV1Api#create_namespaced_service",
        "CoreV1Api#read_namespaced_service",
        "CoreV1Api#list_namespaced_service",
        "CoreV1Api#replace_namespaced_service",
        "CoreV1Api#patch_namespaced_service",
        "CoreV1Api#delete_namespaced_service",
        "CoreV1Api#watch_namespaced_service",
        # CoreV1Api — config-maps
        "CoreV1Api#create_namespaced_config_map",
        "CoreV1Api#read_namespaced_config_map",
        "CoreV1Api#list_namespaced_config_map",
        "CoreV1Api#replace_namespaced_config_map",
        "CoreV1Api#patch_namespaced_config_map",
        "CoreV1Api#delete_namespaced_config_map",
        "CoreV1Api#delete_collection_namespaced_config_map",
        # CoreV1Api — secrets
        "CoreV1Api#create_namespaced_secret",
        "CoreV1Api#read_namespaced_secret",
        "CoreV1Api#list_namespaced_secret",
        "CoreV1Api#replace_namespaced_secret",
        "CoreV1Api#patch_namespaced_secret",
        "CoreV1Api#delete_namespaced_secret",
        # CoreV1Api — endpoints
        "CoreV1Api#create_namespaced_endpoints",
        "CoreV1Api#read_namespaced_endpoints",
        "CoreV1Api#list_namespaced_endpoints",
        "CoreV1Api#replace_namespaced_endpoints",
        "CoreV1Api#patch_namespaced_endpoints",
        "CoreV1Api#delete_namespaced_endpoints",
        # CoreV1Api — nodes
        "CoreV1Api#read_node",
        "CoreV1Api#list_node",
        "CoreV1Api#patch_node",
        # CoreV1Api — persistent volumes
        "CoreV1Api#create_persistent_volume",
        "CoreV1Api#read_persistent_volume",
        "CoreV1Api#list_persistent_volume",
        "CoreV1Api#replace_persistent_volume",
        "CoreV1Api#patch_persistent_volume",
        "CoreV1Api#delete_persistent_volume",
        # CoreV1Api — persistent volume claims
        "CoreV1Api#create_namespaced_persistent_volume_claim",
        "CoreV1Api#read_namespaced_persistent_volume_claim",
        "CoreV1Api#list_namespaced_persistent_volume_claim",
        "CoreV1Api#replace_namespaced_persistent_volume_claim",
        "CoreV1Api#patch_namespaced_persistent_volume_claim",
        "CoreV1Api#delete_namespaced_persistent_volume_claim",
        # AppsV1Api — deployments
        "AppsV1Api#create_namespaced_deployment",
        "AppsV1Api#read_namespaced_deployment",
        "AppsV1Api#list_namespaced_deployment",
        "AppsV1Api#replace_namespaced_deployment",
        "AppsV1Api#patch_namespaced_deployment",
        "AppsV1Api#delete_namespaced_deployment",
        "AppsV1Api#watch_namespaced_deployment",
        # AppsV1Api — daemon sets
        "AppsV1Api#create_namespaced_daemon_set",
        "AppsV1Api#read_namespaced_daemon_set",
        "AppsV1Api#list_namespaced_daemon_set",
        "AppsV1Api#replace_namespaced_daemon_set",
        "AppsV1Api#patch_namespaced_daemon_set",
        "AppsV1Api#delete_namespaced_daemon_set",
        # AppsV1Api — replica sets
        "AppsV1Api#create_namespaced_replica_set",
        "AppsV1Api#read_namespaced_replica_set",
        "AppsV1Api#list_namespaced_replica_set",
        "AppsV1Api#replace_namespaced_replica_set",
        "AppsV1Api#patch_namespaced_replica_set",
        "AppsV1Api#delete_namespaced_replica_set",
        # AppsV1Api — stateful sets
        "AppsV1Api#create_namespaced_stateful_set",
        "AppsV1Api#read_namespaced_stateful_set",
        "AppsV1Api#list_namespaced_stateful_set",
        "AppsV1Api#replace_namespaced_stateful_set",
        "AppsV1Api#patch_namespaced_stateful_set",
        "AppsV1Api#delete_namespaced_stateful_set",
        # BatchV1Api — jobs
        "BatchV1Api#create_namespaced_job",
        "BatchV1Api#read_namespaced_job",
        "BatchV1Api#list_namespaced_job",
        "BatchV1Api#replace_namespaced_job",
        "BatchV1Api#patch_namespaced_job",
        "BatchV1Api#delete_namespaced_job",
        "BatchV1Api#watch_namespaced_job",
        # RbacAuthorizationV1Api — roles
        "RbacAuthorizationV1Api#create_namespaced_role",
        "RbacAuthorizationV1Api#read_namespaced_role",
        "RbacAuthorizationV1Api#list_namespaced_role",
        "RbacAuthorizationV1Api#replace_namespaced_role",
        "RbacAuthorizationV1Api#patch_namespaced_role",
        "RbacAuthorizationV1Api#delete_namespaced_role",
        # RbacAuthorizationV1Api — cluster roles
        "RbacAuthorizationV1Api#create_cluster_role",
        "RbacAuthorizationV1Api#read_cluster_role",
        "RbacAuthorizationV1Api#list_cluster_role",
        "RbacAuthorizationV1Api#replace_cluster_role",
        "RbacAuthorizationV1Api#patch_cluster_role",
        "RbacAuthorizationV1Api#delete_cluster_role",
        # RbacAuthorizationV1Api — role bindings
        "RbacAuthorizationV1Api#create_namespaced_role_binding",
        "RbacAuthorizationV1Api#read_namespaced_role_binding",
        "RbacAuthorizationV1Api#list_namespaced_role_binding",
        "RbacAuthorizationV1Api#replace_namespaced_role_binding",
        "RbacAuthorizationV1Api#patch_namespaced_role_binding",
        "RbacAuthorizationV1Api#delete_namespaced_role_binding",
        # RbacAuthorizationV1Api — cluster role bindings
        "RbacAuthorizationV1Api#create_cluster_role_binding",
        "RbacAuthorizationV1Api#read_cluster_role_binding",
        "RbacAuthorizationV1Api#list_cluster_role_binding",
        "RbacAuthorizationV1Api#replace_cluster_role_binding",
        "RbacAuthorizationV1Api#patch_cluster_role_binding",
        "RbacAuthorizationV1Api#delete_cluster_role_binding",
        # NetworkingV1Api — ingresses
        "NetworkingV1Api#create_namespaced_ingress",
        "NetworkingV1Api#read_namespaced_ingress",
        "NetworkingV1Api#list_namespaced_ingress",
        "NetworkingV1Api#replace_namespaced_ingress",
        "NetworkingV1Api#patch_namespaced_ingress",
        "NetworkingV1Api#delete_namespaced_ingress",
        # NetworkingV1Api — network policies
        "NetworkingV1Api#create_namespaced_network_policy",
        "NetworkingV1Api#read_namespaced_network_policy",
        "NetworkingV1Api#list_namespaced_network_policy",
        "NetworkingV1Api#replace_namespaced_network_policy",
        "NetworkingV1Api#patch_namespaced_network_policy",
        "NetworkingV1Api#delete_namespaced_network_policy",
        # NetworkingV1Api — ingress classes
        "NetworkingV1Api#create_ingress_class",
        "NetworkingV1Api#read_ingress_class",
        "NetworkingV1Api#list_ingress_class",
        "NetworkingV1Api#replace_ingress_class",
        "NetworkingV1Api#patch_ingress_class",
        "NetworkingV1Api#delete_ingress_class",
        # StorageV1Api — CSI drivers
        "StorageV1Api#create_csi_driver",
        "StorageV1Api#read_csi_driver",
        "StorageV1Api#list_csi_driver",
        "StorageV1Api#replace_csi_driver",
        "StorageV1Api#patch_csi_driver",
        "StorageV1Api#delete_csi_driver",
        # StorageV1Api — CSI storage capacities
        "StorageV1Api#create_namespaced_csi_storage_capacity",
        "StorageV1Api#read_namespaced_csi_storage_capacity",
        "StorageV1Api#list_namespaced_csi_storage_capacity",
        "StorageV1Api#replace_namespaced_csi_storage_capacity",
        "StorageV1Api#patch_namespaced_csi_storage_capacity",
        "StorageV1Api#delete_namespaced_csi_storage_capacity",
        # StorageV1Api — storage classes
        "StorageV1Api#create_storage_class",
        "StorageV1Api#read_storage_class",
        "StorageV1Api#list_storage_class",
        "StorageV1Api#replace_storage_class",
        "StorageV1Api#patch_storage_class",
        "StorageV1Api#delete_storage_class",
        # AutoscalingV2Api — HPA
        "AutoscalingV2Api#create_namespaced_horizontal_pod_autoscaler",
        "AutoscalingV2Api#read_namespaced_horizontal_pod_autoscaler",
        "AutoscalingV2Api#list_namespaced_horizontal_pod_autoscaler",
        "AutoscalingV2Api#replace_namespaced_horizontal_pod_autoscaler",
        "AutoscalingV2Api#patch_namespaced_horizontal_pod_autoscaler",
        "AutoscalingV2Api#delete_namespaced_horizontal_pod_autoscaler",
        "AutoscalingV2Api#watch_namespaced_horizontal_pod_autoscaler",
        # PolicyV1Api — PDB
        "PolicyV1Api#create_namespaced_pod_disruption_budget",
        "PolicyV1Api#read_namespaced_pod_disruption_budget",
        "PolicyV1Api#list_namespaced_pod_disruption_budget",
        "PolicyV1Api#replace_namespaced_pod_disruption_budget",
        "PolicyV1Api#patch_namespaced_pod_disruption_budget",
        "PolicyV1Api#delete_namespaced_pod_disruption_budget",
        # CoordinationV1Api — leases
        "CoordinationV1Api#create_namespaced_lease",
        "CoordinationV1Api#read_namespaced_lease",
        "CoordinationV1Api#list_namespaced_lease",
        "CoordinationV1Api#replace_namespaced_lease",
        "CoordinationV1Api#patch_namespaced_lease",
        "CoordinationV1Api#delete_namespaced_lease",
        "CoordinationV1Api#watch_namespaced_lease",
        # SchedulingV1Api — priority classes
        "SchedulingV1Api#create_priority_class",
        "SchedulingV1Api#read_priority_class",
        "SchedulingV1Api#list_priority_class",
        "SchedulingV1Api#replace_priority_class",
        "SchedulingV1Api#patch_priority_class",
        "SchedulingV1Api#delete_priority_class"
      ].freeze
    end
  end
end

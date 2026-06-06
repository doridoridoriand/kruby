# frozen_string_literal: true

# ApiDiscovery provides helpers to check whether a Kubernetes resource kind is
# served by the current cluster's API server, so that tests can gracefully skip
# operations for resources that don't exist in the target cluster version.
#
# Usage:
#   discovery = SpecSupport::E2E::ApiDiscovery.new(api_client)
#   skip_unless_resource_served!("storage.k8s.io", "v1", "VolumeAttributesClass")
#
# Or as a module included in specs:
#   include SpecSupport::E2E::ApiDiscoveryMatchers::Matchers
#
module SpecSupport
  module E2E
    class ApiDiscovery
      attr_reader :api_client

      def initialize(api_client)
        @api_client = api_client
      end

      # Check if a resource is served by the cluster
      # Returns true if the resource exists and is namespaced
      def namespaced_resource_served?(group, version, kind)
        validate_params(group, version, kind)

        resources = discover_resources(group, version)
        resource = resources.find { |r| r["kind"] == kind }
        resource && resource["namespaced"]
      rescue StandardError
        false
      end

      # Check if a cluster-scoped resource is served by the cluster
      def cluster_resource_served?(group, version, kind)
        validate_params(group, version, kind)

        resources = discover_resources(group, version)
        resource = resources.find { |r| r["kind"] == kind }
        resource && !resource["namespaced"]
      rescue StandardError
        false
      end

      # Check if any resource of the given kind is served (regardless of scope)
      def resource_served?(group, version, kind)
        namespaced_resource_served?(group, version, kind) || cluster_resource_served?(group, version, kind)
      rescue StandardError
        false
      end

      # Predefined kind-incompatible resources that need discovery gating
      # These resources have method names that don't follow the standard pattern:
      # - "namespaced_<resource>" pattern (e.g., create_namespaced_pod)
      # - Instead use: "create_<resource>" (e.g., create_volume_attachment)
      KIND_INCOMPATIBLE_RESOURCES = {
        "storage.k8s.io/v1/volumeattachments" => ["storage.k8s.io", "v1", "VolumeAttachment"],
        "storage.k8s.io/v1/csinodes" => ["storage.k8s.io", "v1", "CSINode"],
        "storage.k8s.io/v1/volumeattributesclasses" => ["storage.k8s.io", "v1", "VolumeAttributesClass"],
        "networking.k8s.io/v1/ipaddresses" => ["networking.k8s.io", "v1", "IPAddress"],
        "networking.k8s.io/v1/servicecidrs" => ["networking.k8s.io", "v1", "ServiceCIDR"]
      }.freeze

      # Check if a kind-incompatible resource is served
      def kind_incompatible_resource_served?(selector)
        raise ArgumentError, "selector required" if selector.nil? || selector.empty?

        resource_info = KIND_INCOMPATIBLE_RESOURCES[selector]
        return false unless resource_info

        group, version, kind = resource_info
        resource_served?(group, version, kind)
      end

      # Discover resources for a given API group/version
      # Returns array of resource info hashes (from JSON response)
      def discover_resources(group, version)
        raise ArgumentError, "group required" if group.nil? || group.empty?
        raise ArgumentError, "version required" if version.nil? || version.empty?

        response = if group.empty? || group == "core"
          # Core API group
          api_client.call_api(:GET, "/api/#{version}", {}, {}, {})
        else
          # Named API group
          api_client.call_api(:GET, "/apis/#{group}/#{version}", {}, {}, {})
        end

        return [] unless response&.body
        response.body["resources"] || []
      rescue StandardError => e
        raise "Failed to discover resources for #{group}/#{version}: #{e.message}"
      end

      private

      def validate_params(group, version, kind)
        raise ArgumentError, "group required" if group.nil? || group.empty?
        raise ArgumentError, "version required" if version.nil? || version.empty?
        raise ArgumentError, "kind required" if kind.nil? || kind.empty?
      end
    end

    # NOTE: Named ApiDiscoveryMatchers (not nested under ApiDiscovery class) to avoid
    # Ruby's "X is not a module" error when the same name is used for both class and module.
    module ApiDiscoveryMatchers
      module Matchers
        def skip_unless_resource_served!(group, version, kind, message: nil)
          raise ArgumentError, "group required" if group.nil? || group.empty?
          raise ArgumentError, "version required" if version.nil? || version.empty?
          raise ArgumentError, "kind required" if kind.nil? || kind.empty?

          discovery = api_discovery
          unless discovery.resource_served?(group, version, kind)
            message ||= "Resource #{group}/#{version}/#{kind} not served by cluster"
            skip(message)
          end
        end

        def skip_unless_kind_incompatible_served!(selector, message: nil)
          raise ArgumentError, "selector required" if selector.nil? || selector.empty?

          discovery = api_discovery
          unless discovery.kind_incompatible_resource_served?(selector)
            message ||= "Kind-incompatible resource #{selector} not served by cluster"
            skip(message)
          end
        end

        def api_discovery
          @api_discovery ||= begin
            api_client = Kubernetes::ApiClient.default
            ApiDiscovery.new(api_client)
          end
        end
      end
    end
  end
end
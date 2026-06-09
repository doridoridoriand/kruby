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
require "json"
require_relative "target_selector"

module SpecSupport
  module E2E
    class ApiDiscovery
      TargetAvailability = Struct.new(:served, :reason, keyword_init: true) do
        def served?
          !!served
        end
      end

      attr_reader :api_client

      def initialize(api_client)
        @api_client = api_client
        @resource_cache = {}
      end

      # Check if a resource is served by the cluster
      # Returns true if the resource exists and is namespaced
      def namespaced_resource_served?(group, version, kind)
        validate_params(group, version, kind)

        resources = discover_resources(group, version)
        resource = resources.find { |r| resource_value(r, "kind") == kind }
        resource && resource_value(resource, "namespaced")
      rescue StandardError
        false
      end

      # Check if a cluster-scoped resource is served by the cluster
      def cluster_resource_served?(group, version, kind)
        validate_params(group, version, kind)

        resources = discover_resources(group, version)
        resource = resources.find { |r| resource_value(r, "kind") == kind }
        resource && !resource_value(resource, "namespaced")
      rescue StandardError
        false
      end

      # Check if any resource of the given kind is served (regardless of scope)
      def resource_served?(group, version, kind)
        validate_params(group, version, kind)

        resource_served_strict?(group, version, kind)
      rescue StandardError
        false
      end

      # Resources whose availability varies by Kubernetes minor or feature gate.
      # These are resolved dynamically because the generated kruby client may
      # expose methods before an older target cluster serves the resource.
      DISCOVERY_GATED_RESOURCES = {
        "storage.k8s.io/v1/volumeattachments" => ["storage.k8s.io", "v1", "VolumeAttachment"],
        "storage.k8s.io/v1/csinodes" => ["storage.k8s.io", "v1", "CSINode"],
        "storage.k8s.io/v1/volumeattributesclasses" => ["storage.k8s.io", "v1", "VolumeAttributesClass"],
        "networking.k8s.io/v1/ipaddresses" => ["networking.k8s.io", "v1", "IPAddress"],
        "networking.k8s.io/v1/servicecidrs" => ["networking.k8s.io", "v1", "ServiceCIDR"]
      }.freeze
      KIND_INCOMPATIBLE_RESOURCES = DISCOVERY_GATED_RESOURCES

      # Check if a kind-incompatible resource is served
      def kind_incompatible_resource_served?(selector)
        raise ArgumentError, "selector required" if selector.nil? || selector.empty?

        return false unless discovery_gated_resource?(selector)

        target_availability(selector).served?
      end

      def discovery_gated_resource?(selector)
        raise ArgumentError, "selector required" if selector.nil? || selector.empty?

        DISCOVERY_GATED_RESOURCES.key?(resource_key_from_selector(selector))
      end

      def target_availability(selector)
        raise ArgumentError, "selector required" if selector.nil? || selector.empty?

        resource_key = resource_key_from_selector(selector)
        resource_info = DISCOVERY_GATED_RESOURCES[resource_key]
        return TargetAvailability.new(served: true) unless resource_info

        group, version, kind = resource_info
        return TargetAvailability.new(served: true) if resource_served_strict?(group, version, kind)

        TargetAvailability.new(
          served: false,
          reason: "Resource #{group}/#{version}/#{kind} not served by cluster"
        )
      rescue StandardError => e
        raise unless not_found_error?(e)

        TargetAvailability.new(
          served: false,
          reason: "Resource #{group}/#{version}/#{kind} not served by cluster"
        )
      end

      # Discover resources for a given API group/version
      # Returns array of resource info hashes (from JSON response)
      def discover_resources(group, version)
        raise ArgumentError, "group required" if group.nil? || group.empty?
        raise ArgumentError, "version required" if version.nil? || version.empty?

        cache_key = [group, version]
        return @resource_cache.fetch(cache_key) if @resource_cache.key?(cache_key)

        path = if group.empty? || group == "core"
          "/api/#{version}"
        else
          "/apis/#{group}/#{version}"
        end

        body, = api_client.call_api(:get, path, return_type: "String", auth_names: ["BearerToken"])
        return [] if body.nil? || body.empty?

        payload = body.is_a?(String) ? JSON.parse(body) : body
        @resource_cache[cache_key] = resource_value(payload, "resources") || []
      rescue StandardError => e
        raise e if e.respond_to?(:code)

        raise "Failed to discover resources for #{group}/#{version}: #{e.message}"
      end

      private

      def resource_served_strict?(group, version, kind)
        resources = discover_resources(group, version)
        resources.any? { |resource| resource_value(resource, "kind") == kind }
      end

      def not_found_error?(error)
        error.respond_to?(:code) && error.code.to_i == 404
      end

      def resource_key_from_selector(selector)
        text = selector.to_s
        return text if text.count("/") == 2 && !text.include?(":")

        parsed = TargetSelector.parse(selector)
        "#{parsed.fetch(:api_group)}/#{parsed.fetch(:version)}/#{parsed.fetch(:resource)}"
      end

      def resource_value(resource, key)
        return nil unless resource.respond_to?(:key?)

        return resource[key] if resource.key?(key)
        return resource[key.to_sym] if resource.key?(key.to_sym)

        nil
      end

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

# frozen_string_literal: true

require "securerandom"

module SpecSupport
  module E2E
    class ResourceCleanup
      class CleanupError < StandardError; end

      def initialize(cluster_manager:, namespace_prefix: "kruby-e2e", keep_namespaces: ENV["E2E_KEEP_NAMESPACES"] == "1")
        @cluster_manager = cluster_manager
        @namespace_prefix = namespace_prefix
        @keep_namespaces = keep_namespaces
        @cleanup_actions = []
      end

      def with_namespace(namespace = build_namespace)
        create_namespace(namespace)
        yield namespace
      ensure
        cleanup
      end

      def create_namespace(namespace)
        @cluster_manager.kubectl("create", "namespace", namespace, allow_failure: true)
        register { delete_namespace(namespace) } unless @keep_namespaces
        namespace
      end

      def delete_namespace(namespace)
        @cluster_manager.kubectl(
          "delete",
          "namespace",
          namespace,
          "--ignore-not-found=true",
          "--wait=false",
          allow_failure: true
        )
      end

      def track_resource(namespace:, resource_type:, name:)
        register do
          @cluster_manager.kubectl(
            "-n",
            namespace,
            "delete",
            resource_type,
            name,
            "--ignore-not-found=true",
            allow_failure: true
          )
        end
      end

      def register(&block)
        raise ArgumentError, "cleanup block is required" unless block

        @cleanup_actions << block
      end

      def cleanup
        if @keep_namespaces
          @cleanup_actions.clear
          return
        end

        errors = []
        @cleanup_actions.reverse_each do |action|
          action.call
        rescue StandardError => e
          errors << e
        end
        @cleanup_actions.clear

        return if errors.empty?

        messages = errors.map(&:message).join("; ")
        raise CleanupError, "one or more cleanup actions failed: #{messages}"
      end

      private

      def build_namespace
        "#{@namespace_prefix}-#{SecureRandom.hex(4)}"
      end
    end
  end
end

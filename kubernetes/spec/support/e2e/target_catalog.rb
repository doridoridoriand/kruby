# frozen_string_literal: true

require_relative "target_selector"

module SpecSupport
  module E2E
    class TargetCatalog
      class DuplicateTargetError < StandardError; end
      class UnknownTargetError < StandardError; end

      class TestTarget
        attr_reader :id, :api_group, :version, :resource, :operation, :namespace_scoped, :metadata

        def initialize(id: nil, api_group:, version:, resource:, operation:, namespace_scoped: true, metadata: {})
          selector_id = id || "#{api_group}/#{version}/#{resource}:#{operation}"
          parsed = TargetSelector.parse(selector_id)

          if api_group != parsed[:api_group] ||
             version != parsed[:version] ||
             resource != parsed[:resource] ||
             operation != parsed[:operation]
            raise ArgumentError, "target fields do not match selector id: #{selector_id}"
          end

          @id = selector_id
          @api_group = api_group
          @version = version
          @resource = resource
          @operation = operation
          @namespace_scoped = !!namespace_scoped
          @metadata = metadata || {}
        end

        def to_h
          {
            id: id,
            api_group: api_group,
            version: version,
            resource: resource,
            operation: operation,
            namespace_scoped: namespace_scoped,
            metadata: metadata
          }
        end
      end

      def initialize
        @targets = {}
      end

      def register(target = nil, **kwargs)
        candidate = build_target(target, **kwargs)
        raise DuplicateTargetError, "duplicate target id: #{candidate.id}" if @targets.key?(candidate.id)

        @targets[candidate.id] = candidate
      end

      def register_many(targets)
        Array(targets).each { |target| register(target) }
        self
      end

      def fetch(selector_or_id)
        id = normalize_selector_id(selector_or_id)
        @targets.fetch(id) { raise UnknownTargetError, "unknown target id: #{id}" }
      end

      def include?(selector_or_id)
        @targets.key?(normalize_selector_id(selector_or_id))
      rescue ArgumentError
        false
      end

      def ids
        @targets.keys.sort
      end

      def all
        ids.map { |id| @targets[id] }
      end

      def empty?
        @targets.empty?
      end

      def size
        @targets.size
      end

      def filter(api_group: nil, version: nil, resource: nil, operation: nil)
        all.select do |target|
          (api_group.nil? || target.api_group == api_group) &&
            (version.nil? || target.version == version) &&
            (resource.nil? || target.resource == resource) &&
            (operation.nil? || target.operation == operation)
        end
      end

      def resolve(selectors)
        Array(selectors).flat_map do |item|
          case item
          when String
            [fetch(item)]
          when Hash
            [fetch(item.fetch(:id))]
          else
            raise ArgumentError, "unsupported selector type: #{item.class}"
          end
        end
      end

      private

      def build_target(target, **kwargs)
        if target.nil?
          TestTarget.new(**kwargs)
        elsif target.is_a?(Hash)
          TestTarget.new(**target, **kwargs)
        elsif target.is_a?(TestTarget)
          target
        else
          raise ArgumentError, "unsupported target type: #{target.class}"
        end
      end

      def normalize_selector_id(selector_or_id)
        case selector_or_id
        when Hash
          selector_or_id.fetch(:id).to_s
        else
          TargetSelector.parse(selector_or_id)[:id]
        end
      end
    end
  end
end

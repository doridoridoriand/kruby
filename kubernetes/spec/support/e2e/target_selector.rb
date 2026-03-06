# frozen_string_literal: true

module SpecSupport
  module E2E
    class TargetSelector
      OPERATIONS = %w[create get list update patch delete watch].freeze
      SELECTOR_PATTERN = %r{\A(?<api_group>[a-z0-9][a-z0-9.-]*)/(?<version>[a-z0-9][a-z0-9.-]*)/(?<resource>[a-z0-9][a-z0-9.-]*):(?<operation>[a-z]+)\z}.freeze

      def self.parse(selector)
        raw = selector.to_s.strip
        raise ArgumentError, "selector must not be empty" if raw.empty?

        match = SELECTOR_PATTERN.match(raw)
        raise ArgumentError, "invalid selector format: #{selector}" unless match

        operation = match[:operation]
        raise ArgumentError, "unsupported operation: #{operation}" unless OPERATIONS.include?(operation)

        {
          id: raw,
          api_group: match[:api_group],
          version: match[:version],
          resource: match[:resource],
          operation: operation
        }
      end

      def self.parse_csv(selectors)
        selectors
          .to_s
          .split(",")
          .map(&:strip)
          .reject(&:empty?)
          .map { |selector| parse(selector) }
      end

      def self.valid?(selector)
        parse(selector)
        true
      rescue ArgumentError
        false
      end
    end
  end
end

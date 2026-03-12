# frozen_string_literal: true

require "shellwords"

require_relative "kind_version_resolver"

module SpecSupport
  module E2E
    class ReproCommandBuilder
      SUPPORTED_MODES = %w[full targeted changed].freeze
      DEFAULT_SCRIPT_PATH = "scripts/e2e/run-e2e"
      DEFAULT_BASE_REF = "origin/HEAD"

      def initialize(script_path: DEFAULT_SCRIPT_PATH)
        @script_path = script_path
      end

      def build(mode:, targets: nil, base_ref: nil, fallback_strategy: nil, rspec_args: [], kubernetes_version: nil)
        normalized_mode = mode.to_s
        validate_mode!(normalized_mode)

        command = [@script_path, "--mode", normalized_mode]
        command.concat(mode_specific_args(normalized_mode, targets: targets, base_ref: base_ref))
        command.concat(["--fallback", fallback_strategy.to_s]) unless fallback_strategy.to_s.empty?
        unless kubernetes_version.to_s.empty?
          command.concat(["--kubernetes-version", KindVersionResolver.resolve_kubernetes_version(kubernetes_version)])
        end

        extra_args = Array(rspec_args).map(&:to_s).reject(&:empty?)
        unless extra_args.empty?
          command << "--"
          command.concat(extra_args)
        end

        Shellwords.join(command)
      end

      private

      def mode_specific_args(mode, targets:, base_ref:)
        case mode
        when "targeted"
          selector = Array(targets).map(&:to_s).reject(&:empty?).join(",")
          raise ArgumentError, "targets are required for targeted mode" if selector.empty?

          ["--targets", selector]
        when "changed"
          ["--base-ref", base_ref.to_s.empty? ? DEFAULT_BASE_REF : base_ref.to_s]
        else
          []
        end
      end

      def validate_mode!(mode)
        return if SUPPORTED_MODES.include?(mode)

        raise ArgumentError, "unsupported mode for repro command: #{mode}"
      end
    end
  end
end

# frozen_string_literal: true

require_relative "target_selector"

module SpecSupport
  module E2E
    class RunContext
      SUPPORTED_MODES = %w[full targeted changed].freeze
      SUPPORTED_FALLBACK_STRATEGIES = %w[minimal-smoke full].freeze

      attr_reader :mode, :targets_raw, :base_ref, :fallback_strategy, :changed_files

      def self.from_env(env = ENV)
        new(
          mode: env.fetch("E2E_MODE", "full"),
          targets_raw: env.fetch("E2E_TARGETS", ""),
          base_ref: env.fetch("BASE_REF", "origin/HEAD"),
          fallback_strategy: env.fetch("E2E_FALLBACK_STRATEGY", "minimal-smoke")
        )
      end

      def initialize(mode:, targets_raw: "", base_ref: "origin/HEAD", fallback_strategy: "minimal-smoke", changed_files: nil)
        @mode = mode.to_s
        @targets_raw = targets_raw.to_s
        @base_ref = base_ref.to_s
        @fallback_strategy = fallback_strategy.to_s
        @changed_files = changed_files.nil? ? nil : Array(changed_files)

        validate!
      end

      def requested_targets
        return [] unless mode == "targeted"

        TargetSelector.parse_csv(targets_raw).map { |selector| selector.fetch(:id) }
      end

      def with_changed_files(files)
        self.class.new(
          mode: mode,
          targets_raw: targets_raw,
          base_ref: base_ref,
          fallback_strategy: fallback_strategy,
          changed_files: Array(files)
        )
      end

      def to_h
        {
          mode: mode,
          requested_targets: requested_targets,
          base_ref: base_ref,
          fallback_strategy: fallback_strategy,
          changed_files: changed_files
        }
      end

      private

        def validate!
          validate_mode!
          validate_fallback_strategy!
          validate_targets!
        end

        def validate_mode!
          return if SUPPORTED_MODES.include?(mode)

          raise ArgumentError, "unsupported E2E mode: #{mode}"
        end

        def validate_fallback_strategy!
          return if SUPPORTED_FALLBACK_STRATEGIES.include?(fallback_strategy)

          raise ArgumentError, "unsupported fallback strategy: #{fallback_strategy}"
        end

        def validate_targets!
          return unless mode == "targeted"

          targets = TargetSelector.parse_csv(targets_raw)
          raise ArgumentError, "E2E_TARGETS is required in targeted mode" if targets.empty?
        end
    end
  end
end

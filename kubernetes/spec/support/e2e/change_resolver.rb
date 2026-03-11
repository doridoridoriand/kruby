# frozen_string_literal: true

require "open3"
require "yaml"

require_relative "target_selector"

module SpecSupport
  module E2E
    class ChangeResolver
      SUPPORTED_FALLBACK_STRATEGIES = %w[minimal-smoke full].freeze
      DEFAULT_BASE_REF = "origin/HEAD"
      DEFAULT_HEAD_REF = "HEAD"
      DEFAULT_FALLBACK_STRATEGY = "minimal-smoke"
      DEFAULT_SMOKE_TARGETS_PATH = File.expand_path("smoke_targets.yml", __dir__)

      ChangeSet = Struct.new(
        :base_ref,
        :head_ref,
        :changed_files,
        :mapped_targets,
        :fallback_strategy,
        :fallback_used,
        :reason,
        keyword_init: true
      ) do
        def to_h
          {
            base_ref: base_ref,
            head_ref: head_ref,
            changed_files: changed_files,
            mapped_targets: mapped_targets,
            fallback_strategy: fallback_strategy,
            fallback_used: fallback_used,
            reason: reason
          }
        end
      end

      def initialize(target_catalog:,
                     repo_root: File.expand_path("../../../..", __dir__),
                     fallback_strategy: ENV.fetch("E2E_FALLBACK_STRATEGY", DEFAULT_FALLBACK_STRATEGY),
                     smoke_targets_path: DEFAULT_SMOKE_TARGETS_PATH)
        @target_catalog = target_catalog
        @repo_root = repo_root
        @fallback_strategy = fallback_strategy
        @smoke_targets_path = smoke_targets_path
        validate_fallback_strategy!(@fallback_strategy)
      end

      def resolve(base_ref: ENV["BASE_REF"], head_ref: DEFAULT_HEAD_REF, changed_files: nil)
        resolved_base_ref = base_ref.to_s.strip.empty? ? DEFAULT_BASE_REF : base_ref
        files = Array(changed_files || git_changed_files(base_ref: resolved_base_ref, head_ref: head_ref))
                .map { |file| normalize_path(file) }
                .reject(&:empty?)
                .uniq

        mapped_targets = map_files_to_targets(files)
        fallback_used = mapped_targets.empty?
        reason = nil

        if fallback_used
          mapped_targets = fallback_targets
          reason = files.empty? ? "No changed files detected" : "No targets could be mapped from changed files"
        end

        ChangeSet.new(
          base_ref: resolved_base_ref,
          head_ref: head_ref,
          changed_files: files,
          mapped_targets: mapped_targets,
          fallback_strategy: @fallback_strategy,
          fallback_used: fallback_used,
          reason: reason
        )
      end

      def git_changed_files(base_ref:, head_ref: DEFAULT_HEAD_REF)
        range = "#{base_ref}...#{head_ref}"
        stdout, stderr, status = Open3.capture3("git", "diff", "--name-only", range, chdir: @repo_root)
        unless status.success?
          raise ArgumentError, "failed to resolve changed files with git diff #{range}: #{stderr.strip}"
        end

        stdout.split("\n").map(&:strip).reject(&:empty?)
      end

      private

        def map_files_to_targets(files)
          selector_ids = files.flat_map { |file| selectors_for_file(file) }.uniq
          return selector_ids if @target_catalog.empty?

          selector_ids.select { |selector| @target_catalog.include?(selector) }
        end

        def selectors_for_file(path)
          normalized = normalize_path(path)
          from_target_definition(normalized) ||
            from_api_client_file(normalized) ||
            from_e2e_spec_file(normalized) ||
            []
        end

        def from_target_definition(path)
          match = %r{\A(?:kubernetes/)?spec/support/e2e/targets/(?<compound>[a-z0-9_]+)\.rb\z}.match(path)
          return nil unless match

          triplet = parse_triplet(match[:compound])
          return [] unless triplet

          @target_catalog.filter(**triplet).map(&:id)
        end

        def from_api_client_file(path)
          match = %r{\A(?:kubernetes/)?lib/kubernetes/api/(?<compound>[a-z0-9_]+)_api\.rb\z}.match(path)
          return nil unless match

          group_version = parse_group_version(match[:compound])
          return [] unless group_version

          @target_catalog
            .filter(api_group: group_version[:api_group], version: group_version[:version])
            .map(&:id)
        end

        def from_e2e_spec_file(path)
          match = %r{\A(?:kubernetes/)?spec/e2e/(?<compound>[a-z0-9_]+)_spec\.rb\z}.match(path)
          return nil unless match

          compound = match[:compound].sub(/_(targeted|full|selection|regression)\z/, "")
          triplet = parse_triplet(compound)
          return [] unless triplet

          @target_catalog.filter(**triplet).map(&:id)
        end

        def parse_group_version(compound)
          parts = compound.split("_")
          version_index = parts.index { |part| part.match?(/\Av\d+(?:alpha\d+|beta\d+)?\z/) }
          return nil if version_index.nil? || version_index.zero?

          {
            api_group: normalize_group(parts[0...version_index].join("_")),
            version: parts[version_index]
          }
        end

        def parse_triplet(compound)
          parts = compound.split("_")
          version_index = parts.index { |part| part.match?(/\Av\d+(?:alpha\d+|beta\d+)?\z/) }
          return nil if version_index.nil? || version_index.zero? || version_index >= parts.length - 1

          {
            api_group: normalize_group(parts[0...version_index].join("_")),
            version: parts[version_index],
            resource: normalize_resource(parts.drop(version_index + 1).join("_"))
          }
        end

        def normalize_group(value)
          value.tr("_", ".")
        end

        def normalize_resource(value)
          value.tr("_", "-")
        end

        def fallback_targets
          case @fallback_strategy
          when "full"
            @target_catalog.ids
          when "minimal-smoke"
            smoke_selectors = load_smoke_targets
            return smoke_selectors if @target_catalog.empty?

            known_selectors = smoke_selectors.select { |selector| @target_catalog.include?(selector) }
            return known_selectors unless known_selectors.empty?

            @target_catalog.ids
          else
            []
          end
        end

        def load_smoke_targets
          return [] unless File.exist?(@smoke_targets_path)

          config = YAML.safe_load(File.read(@smoke_targets_path), permitted_classes: [], aliases: false) || {}
          Array(config["minimal_smoke"]).map { |selector| TargetSelector.parse(selector)[:id] }
        end

        def normalize_path(path)
          path.to_s.strip.sub(%r{\A\./}, "")
        end

        def validate_fallback_strategy!(strategy)
          return if SUPPORTED_FALLBACK_STRATEGIES.include?(strategy)

          raise ArgumentError, "unsupported fallback strategy: #{strategy}"
        end
    end
  end
end

# frozen_string_literal: true

require "open3"

module SpecSupport
  class ChangedSpecSelector
    DEFAULT_BASE_REF = "origin/HEAD"
    DEFAULT_HEAD_REF = "HEAD"
    DEFAULT_SMOKE_SPECS = %w[
      spec/version_spec.rb
      spec/config/kube_config_spec.rb
      spec/api_client_spec.rb
      spec/watch_spec.rb
      spec/models/serialization_spec.rb
      spec/models/smoke_spec.rb
      spec/support/e2e/coverage_inventory_spec.rb
      spec/e2e/changed_mode_selection_spec.rb
      spec/release/publish_guard_spec.rb
    ].freeze

    DIRECT_SPEC_MAP = {
      "kubernetes/lib/kubernetes/api_client.rb" => %w[spec/api_client_spec.rb],
      "kubernetes/lib/kubernetes/api_error.rb" => %w[spec/api_error_spec.rb],
      "kubernetes/lib/kubernetes/config/error.rb" => %w[spec/config/config_error_spec.rb],
      "kubernetes/lib/kubernetes/config/incluster_config.rb" => %w[spec/config/incluster_config_spec.rb],
      "kubernetes/lib/kubernetes/config/kube_config.rb" => %w[spec/config/kube_config_spec.rb],
      "kubernetes/lib/kubernetes/configuration.rb" => %w[
        spec/configuration_spec.rb
        spec/config/kube_config_spec.rb
        spec/config/incluster_config_spec.rb
      ],
      "kubernetes/lib/kubernetes/loader.rb" => %w[spec/loader_spec.rb],
      "kubernetes/lib/kubernetes/utils.rb" => %w[spec/utils_spec.rb],
      "kubernetes/lib/kubernetes/version.rb" => %w[spec/version_spec.rb spec/version_api_spec.rb],
      "kubernetes/lib/kubernetes/watch.rb" => %w[spec/watch_spec.rb],
      "kubernetes/lib/kubernetes/release/changelog.rb" => %w[spec/release/changelog_spec.rb],
      "kubernetes/lib/kubernetes/release/publish_guard.rb" => %w[
        spec/release/publish_guard_spec.rb
        spec/release/publish_script_spec.rb
      ],
      "kubernetes/spec/support/changed_spec_selector.rb" => %w[spec/changed_spec_selector_spec.rb],
      "kubernetes/lib/kubernetes.rb" => %w[spec/loader_spec.rb spec/version_spec.rb],
      "kubernetes/lib/kruby.rb" => %w[spec/loader_spec.rb spec/version_spec.rb],
      "scripts/release/check" => %w[spec/release/changelog_spec.rb spec/release/publish_script_spec.rb],
      "scripts/release/notes" => %w[spec/release/changelog_spec.rb spec/release/publish_script_spec.rb],
      "scripts/release/publish" => %w[spec/release/publish_guard_spec.rb spec/release/publish_script_spec.rb],
      "scripts/release/tag" => %w[spec/release/changelog_spec.rb spec/release/publish_script_spec.rb]
    }.freeze

    Selection = Struct.new(
      :base_ref,
      :head_ref,
      :changed_files,
      :selected_specs,
      :fallback_used,
      :reason,
      keyword_init: true
    )

    def initialize(repo_root: File.expand_path("../../..", __dir__),
                   kubernetes_root: File.expand_path("../..", __dir__),
                   smoke_specs: DEFAULT_SMOKE_SPECS)
      @repo_root = repo_root
      @kubernetes_root = kubernetes_root
      @smoke_specs = smoke_specs
    end

    def resolve(base_ref: DEFAULT_BASE_REF, head_ref: DEFAULT_HEAD_REF, changed_files: nil)
      files = Array(changed_files || git_changed_files(base_ref: base_ref, head_ref: head_ref))
              .map { |path| normalize_path(path) }
              .reject(&:empty?)
              .uniq
      selected_specs = files.flat_map { |path| specs_for_file(path) }.uniq.sort
      fallback_used = selected_specs.empty?
      reason = nil

      if fallback_used
        selected_specs = existing_specs(@smoke_specs) || []
        reason = files.empty? ? "No changed files detected" : "No focused specs could be mapped from changed files"
      end

      Selection.new(
        base_ref: base_ref,
        head_ref: head_ref,
        changed_files: files,
        selected_specs: selected_specs,
        fallback_used: fallback_used,
        reason: reason
      )
    end

    def git_changed_files(base_ref:, head_ref: DEFAULT_HEAD_REF)
      range = "#{base_ref}...#{head_ref}"
      changed_files = capture_git_paths("diff", "--name-only", range)

      if head_ref == DEFAULT_HEAD_REF
        changed_files.concat(capture_git_paths("diff", "--name-only"))
        changed_files.concat(capture_git_paths("diff", "--name-only", "--cached"))
        changed_files.concat(capture_git_paths("ls-files", "--others", "--exclude-standard"))
      end

      changed_files.uniq
    end

    private

      def specs_for_file(path)
        direct_spec_for(path) ||
          spec_file_for(path) ||
          support_spec_for(path) ||
          model_specs_for(path) ||
          api_specs_for(path) ||
          e2e_specs_for(path) ||
          []
      end

      def direct_spec_for(path)
        existing_specs(DIRECT_SPEC_MAP.fetch(path, []))
      end

      def spec_file_for(path)
        match = %r{\A(?:kubernetes/)?(?<relative>spec/.+_spec\.rb)\z}.match(path)
        return nil unless match

        existing_specs([match[:relative]])
      end

      def support_spec_for(path)
        match = %r{\A(?:kubernetes/)?spec/support/e2e/(?<name>[a-z0-9_]+)\.rb\z}.match(path)
        return nil unless match

        exact_spec = "spec/support/e2e/#{match[:name]}_spec.rb"
        return existing_specs([exact_spec]) if spec_exists?(exact_spec)

        case match[:name]
        when "change_resolver", "mode_dispatcher", "target_catalog", "target_selector", "run_context"
          existing_specs(%w[spec/e2e/changed_mode_selection_spec.rb spec/e2e/full_mode_regression_spec.rb])
        when "executor"
          existing_specs(%w[spec/e2e/executor_mapping_spec.rb spec/e2e/executor_retry_spec.rb])
        when "coverage_reporter"
          existing_specs(%w[spec/e2e/coverage_reporter_spec.rb])
        when "failure_reporter"
          existing_specs(%w[spec/e2e/failure_artifact_spec.rb])
        when "cluster_manager"
          existing_specs(%w[spec/e2e/cluster_manager_spec.rb])
        when "resource_cleanup"
          existing_specs(%w[spec/e2e/resource_cleanup_spec.rb])
        when "factories"
          existing_specs(%w[spec/e2e/factories_spec.rb])
        when "kind_version_resolver"
          existing_specs(%w[spec/e2e/kind_version_resolver_spec.rb])
        when "repro_command_builder"
          existing_specs(%w[spec/e2e/repro_command_builder_spec.rb])
        else
          nil
        end
      end

      def model_specs_for(path)
        return nil unless path.match?(%r{\A(?:kubernetes/)?lib/kubernetes/models/.+\.rb\z})

        existing_specs(%w[spec/models/serialization_spec.rb spec/models/smoke_spec.rb])
      end

      def api_specs_for(path)
        return nil unless path.match?(%r{\A(?:kubernetes/)?lib/kubernetes/api/.+\.rb\z})

        case path
        when %r{/custom_objects_api\.rb\z}
          existing_specs(%w[spec/custom_objects_api_spec.rb])
        when %r{/discovery(?:_v1)?_api\.rb\z}
          existing_specs(%w[spec/discovery_api_spec.rb])
        when %r{/logs_api\.rb\z}
          existing_specs(%w[spec/logs_api_spec.rb])
        when %r{/version_api\.rb\z}
          existing_specs(%w[spec/version_api_spec.rb])
        else
          existing_specs(%w[spec/api_client_spec.rb spec/well_known_api_spec.rb])
        end
      end

      def e2e_specs_for(path)
        return nil unless path.match?(%r{\A(?:kubernetes/)?(?:spec/support/e2e/targets/|scripts/e2e/|docs/e2e-kind-testing\.md)})

        existing_specs(
          %w[
            spec/e2e/changed_mode_selection_spec.rb
            spec/e2e/executor_mapping_spec.rb
            spec/e2e/full_mode_regression_spec.rb
            spec/e2e/packaging_safety_spec.rb
            spec/e2e/run_e2e_matrix_spec.rb
            spec/support/e2e/coverage_gate_spec.rb
            spec/support/e2e/coverage_inventory_spec.rb
          ]
        )
      end

      def existing_specs(specs)
        resolved_specs = Array(specs).select { |spec| spec_exists?(spec) }
        resolved_specs.empty? ? nil : resolved_specs
      end

      def spec_exists?(relative_path)
        File.exist?(File.join(@kubernetes_root, relative_path))
      end

      def capture_git_paths(*args)
        stdout, stderr, status = Open3.capture3("git", *args, chdir: @repo_root)
        raise ArgumentError, "failed to run git #{args.join(' ')}: #{stderr.strip}" unless status.success?

        stdout.split("\n").map(&:strip).reject(&:empty?)
      end

      def normalize_path(path)
        path.to_s.strip.sub(%r{\A\./}, "")
      end
  end
end

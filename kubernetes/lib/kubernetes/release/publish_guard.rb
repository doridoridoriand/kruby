# frozen_string_literal: true

require "open3"
require "rubygems/specification"
require "shellwords"
require "kubernetes/release/changelog"

module Kubernetes
  module Release
    module PublishGuard
      module_function

      def gemspec_files(gemspec_path)
        spec = Gem::Specification.load(gemspec_path)
        raise Changelog::Error, "failed to load gemspec #{gemspec_path}" unless spec

        spec.files
      rescue Gem::InvalidSpecificationException => e
        raise Changelog::Error, e.message
      end

      def untracked_package_files(repo_root:, package_root:, package_files:)
        repo_paths = package_files.map do |path|
          package_file_repo_path(repo_root: repo_root, package_root: package_root, package_path: path)
        end.uniq.sort
        return [] if repo_paths.empty?

        tracked_paths = capture_command("git", "-C", repo_root, "ls-files", "--", *repo_paths).lines.map(&:chomp)
        repo_paths - tracked_paths
      end

      def untracked_gemspec_files(repo_root:, package_root:, gemspec_path:)
        untracked_package_files(
          repo_root: repo_root,
          package_root: package_root,
          package_files: gemspec_files(gemspec_path)
        )
      end

      def package_file_repo_path(repo_root:, package_root:, package_path:)
        repo_root = File.expand_path(repo_root)
        repo_prefix = "#{repo_root}#{File::SEPARATOR}"
        full_path = File.expand_path(package_path, package_root)

        unless full_path.start_with?(repo_prefix)
          raise Changelog::Error, "gem package file #{package_path} resolves outside #{repo_root}"
        end

        full_path.delete_prefix(repo_prefix)
      end

      def capture_command(*command)
        output, status = Open3.capture2e(*command)
        return output if status.success?

        message = "command failed: #{Shellwords.join(command)}"
        details = output.strip
        message = "#{message}\n#{details}" unless details.empty?
        raise Changelog::Error, message
      end
    end
  end
end

# frozen_string_literal: true

require "fileutils"
require "open3"
require "securerandom"

require_relative "kind_version_resolver"

module SpecSupport
  module E2E
    class ClusterManager
      DEFAULT_KUBECONFIG_DIR = File.expand_path("../../../tmp/e2e/kubeconfig", __dir__)

      class CommandError < StandardError
        attr_reader :result

        def initialize(message, result)
          super(message)
          @result = result
        end
      end

      CommandResult = Struct.new(:command, :status, :stdout, :stderr, keyword_init: true) do
        def success?
          status.zero?
        end
      end

      attr_reader :cluster_name, :kubeconfig_path, :kubernetes_version, :kind_node_image
      attr_reader :mode, :reuse_cluster

      def initialize(mode: ENV.fetch("E2E_MODE", "full"),
                     kubernetes_version: ENV.fetch("E2E_KUBERNETES_VERSION", KindVersionResolver.default_kubernetes_version),
                     cluster_name: nil,
                     kind_bin: ENV.fetch("KIND_BIN", "kind"),
                     kubectl_bin: ENV.fetch("KUBECTL_BIN", "kubectl"),
                     kubeconfig_path: ENV["E2E_KUBECONFIG"],
                     kind_node_image: ENV["E2E_KIND_NODE_IMAGE"],
                     kind_config_path: ENV["E2E_KIND_CONFIG"],
                     reuse_cluster: nil,
                     keep_cluster: ENV["E2E_KEEP_CLUSTER"] == "1")
        @mode = mode.to_s
        @kubernetes_version = KindVersionResolver.resolve_kubernetes_version(kubernetes_version)
        @cluster_name = cluster_name || self.class.default_cluster_name(mode: @mode, kubernetes_version: @kubernetes_version)
        @kind_bin = kind_bin
        @kubectl_bin = kubectl_bin
        @kubeconfig_path, @managed_kubeconfig_path = resolve_kubeconfig_path(kubeconfig_path)
        @kind_node_image = KindVersionResolver.resolve_node_image(
          kubernetes_version: @kubernetes_version,
          explicit_image: kind_node_image
        )
        @kind_config_path = kind_config_path
        @reuse_cluster = resolve_reuse_cluster(reuse_cluster)
        @keep_cluster = keep_cluster
        @created = false
        @reused_existing_cluster = false
      end

      def self.default_cluster_name(mode: ENV.fetch("E2E_MODE", "full"),
                                    kubernetes_version: ENV.fetch("E2E_KUBERNETES_VERSION", KindVersionResolver.default_kubernetes_version))
        version_slug = KindVersionResolver.version_slug(kubernetes_version)
        return "kruby-e2e-full-#{version_slug}" if mode.to_s == "full"

        "kruby-e2e-#{version_slug}-#{Process.pid}-#{SecureRandom.hex(3)}"
      end

      def self.default_kubeconfig_path(cluster_name:, base_dir: DEFAULT_KUBECONFIG_DIR)
        File.join(base_dir, "#{cluster_name}.kubeconfig")
      end

      def create
        if reuse_cluster && cluster_exists?
          ensure_managed_kubeconfig!
          @created = true
          @reused_existing_cluster = true
          return self
        end

        command = [@kind_bin, "create", "cluster", "--name", cluster_name]
        command += ["--image", kind_node_image] unless kind_node_image.to_s.empty?
        command += ["--kubeconfig", kubeconfig_path] if kubeconfig_path && !kubeconfig_path.empty?
        command += ["--config", @kind_config_path] if @kind_config_path && !@kind_config_path.empty?

        FileUtils.mkdir_p(File.dirname(kubeconfig_path)) if kubeconfig_path && !kubeconfig_path.empty?
        run_command(command)
        @created = true
        @reused_existing_cluster = false
        self
      end

      def delete
        result = run_command([@kind_bin, "delete", "cluster", "--name", cluster_name], allow_failure: true)
        if result.success? && @managed_kubeconfig_path && kubeconfig_path && !kubeconfig_path.empty?
          FileUtils.rm_f(kubeconfig_path)
        end
        @created = false
      end

      def with_cluster
        create unless @created
        yield self
      ensure
        delete unless preserve_cluster_after_run?
      end

      def kind(*args, allow_failure: false, stdin_data: nil)
        run_command([@kind_bin, *args], allow_failure: allow_failure, stdin_data: stdin_data)
      end

      def kubectl(*args, allow_failure: false, stdin_data: nil)
        command = [@kubectl_bin]
        command += ["--kubeconfig", kubeconfig_path] if kubeconfig_path && !kubeconfig_path.empty?
        command.concat(args)
        run_command(command, allow_failure: allow_failure, stdin_data: stdin_data)
      end

      private

      def preserve_cluster_after_run?
        @keep_cluster || (mode == "full" && reuse_cluster)
      end

      def cluster_exists?
        result = run_command([@kind_bin, "get", "clusters"], allow_failure: true)
        return false unless result.success?

        result.stdout.split("\n").map(&:strip).include?(cluster_name)
      end

      def resolve_reuse_cluster(explicit_value)
        return !!explicit_value unless explicit_value.nil?

        env_value = ENV["E2E_REUSE_CLUSTER"]
        return env_value == "1" unless env_value.nil?

        mode == "full"
      end

      def resolve_kubeconfig_path(explicit_path)
        path = explicit_path.to_s.strip
        return [File.expand_path(path), false] unless path.empty?

        [self.class.default_kubeconfig_path(cluster_name: cluster_name), true]
      end

      def ensure_managed_kubeconfig!
        return unless @managed_kubeconfig_path && kubeconfig_path && !kubeconfig_path.empty?
        return if File.file?(kubeconfig_path) && File.readable?(kubeconfig_path)

        FileUtils.mkdir_p(File.dirname(kubeconfig_path))
        result = kind("get", "kubeconfig", "--name", cluster_name)
        File.write(kubeconfig_path, result.stdout)
      end

      def run_command(command, allow_failure: false, stdin_data: nil)
        stdout, stderr, status = Open3.capture3(*command, stdin_data: stdin_data.to_s)
        result = CommandResult.new(
          command: command.join(" "),
          status: status.exitstatus || 1,
          stdout: stdout,
          stderr: stderr
        )

        return result if allow_failure || result.success?

        raise CommandError.new("command failed: #{result.command}\n#{stderr}", result)
      end
    end
  end
end

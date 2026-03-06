# frozen_string_literal: true

require "open3"
require "securerandom"

module SpecSupport
  module E2E
    class ClusterManager
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

      attr_reader :cluster_name, :kubeconfig_path

      def initialize(cluster_name: self.class.default_cluster_name,
                     kind_bin: ENV.fetch("KIND_BIN", "kind"),
                     kubectl_bin: ENV.fetch("KUBECTL_BIN", "kubectl"),
                     kubeconfig_path: ENV["E2E_KUBECONFIG"],
                     kind_config_path: ENV["E2E_KIND_CONFIG"],
                     keep_cluster: ENV["E2E_KEEP_CLUSTER"] == "1")
        @cluster_name = cluster_name
        @kind_bin = kind_bin
        @kubectl_bin = kubectl_bin
        @kubeconfig_path = kubeconfig_path
        @kind_config_path = kind_config_path
        @keep_cluster = keep_cluster
        @created = false
      end

      def self.default_cluster_name
        "kruby-e2e-#{Process.pid}-#{SecureRandom.hex(3)}"
      end

      def create
        command = [@kind_bin, "create", "cluster", "--name", cluster_name]
        command += ["--kubeconfig", kubeconfig_path] if kubeconfig_path && !kubeconfig_path.empty?
        command += ["--config", @kind_config_path] if @kind_config_path && !@kind_config_path.empty?

        run_command(command)
        @created = true
        self
      end

      def delete
        run_command([@kind_bin, "delete", "cluster", "--name", cluster_name], allow_failure: true)
        @created = false
      end

      def with_cluster
        create unless @created
        yield self
      ensure
        delete unless @keep_cluster
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

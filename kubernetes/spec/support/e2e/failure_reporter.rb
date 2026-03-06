# frozen_string_literal: true

require "fileutils"
require "json"
require "securerandom"
require "time"

module SpecSupport
  module E2E
    class FailureReporter
      DEFAULT_OUTPUT_DIR = File.expand_path("../../reports/e2e", __dir__)
      MAX_RESPONSE_EXCERPT_BYTES = 8 * 1024

      attr_reader :run_id, :output_dir

      def initialize(run_id: nil, output_dir: ENV.fetch("E2E_REPORT_DIR", DEFAULT_OUTPUT_DIR))
        @run_id = run_id || default_run_id
        @output_dir = output_dir
        @artifacts = []
      end

      def record(target_id:, error:, repro_command:, http_status: nil, response_excerpt: nil, log_path: nil)
        artifact = build_artifact(
          target_id: target_id,
          error: error,
          repro_command: repro_command,
          http_status: http_status,
          response_excerpt: response_excerpt,
          log_path: log_path
        )

        path = write_single_artifact(artifact)
        @artifacts << artifact

        $stderr.puts("E2E failure artifact written to #{path}")
        $stderr.puts(JSON.generate(artifact))

        artifact
      end

      def artifacts
        @artifacts.dup
      end

      def write_summary
        return nil if @artifacts.empty?

        FileUtils.mkdir_p(output_dir)
        path = File.join(output_dir, "run-#{run_id}-failures.json")
        File.write(path, JSON.pretty_generate(@artifacts))
        path
      end

      private

      def build_artifact(target_id:, error:, repro_command:, http_status:, response_excerpt:, log_path:)
        {
          "runId" => run_id,
          "targetId" => target_id,
          "errorType" => error_type(error),
          "httpStatus" => http_status,
          "responseExcerpt" => truncate_excerpt(response_excerpt || extract_error_excerpt(error)),
          "reproCommand" => repro_command,
          "logPath" => log_path
        }.compact
      end

      def write_single_artifact(artifact)
        FileUtils.mkdir_p(output_dir)
        timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
        target = artifact.fetch("targetId").tr("/", "-").tr(":", "-")
        filename = "failure-#{run_id}-#{target}-#{timestamp}-#{SecureRandom.hex(2)}.json"
        path = File.join(output_dir, filename)
        File.write(path, JSON.pretty_generate(artifact))
        path
      end

      def error_type(error)
        case error
        when nil
          "UnknownError"
        when String
          "RuntimeError"
        else
          error.class.to_s
        end
      end

      def extract_error_excerpt(error)
        return "" if error.nil?
        return error if error.is_a?(String)

        error.message.to_s
      end

      def truncate_excerpt(text)
        safe_text = text.to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
        bytes = safe_text.bytes
        return safe_text if bytes.length <= MAX_RESPONSE_EXCERPT_BYTES

        bytes[0, MAX_RESPONSE_EXCERPT_BYTES].pack("C*")
      end

      def default_run_id
        Time.now.utc.strftime("run-%Y%m%d%H%M%S")
      end
    end
  end
end

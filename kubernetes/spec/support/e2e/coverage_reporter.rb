# frozen_string_literal: true

require "fileutils"
require "json"
require "time"

module SpecSupport
  module E2E
    class CoverageReporter
      DEFAULT_OUTPUT_DIR = File.expand_path("../../reports/e2e", __dir__)

      attr_reader :run_id, :mode, :output_path

      def initialize(run_id:, mode:, output_path: nil, output_dir: ENV.fetch("E2E_REPORT_DIR", DEFAULT_OUTPUT_DIR))
        @run_id = run_id.to_s
        @mode = mode.to_s
        @output_path = output_path.to_s.empty? ? default_output_path(output_dir) : output_path.to_s
        @entries = []
        @resolved_targets = []
      end

      def start!(resolved_targets:)
        @resolved_targets = Array(resolved_targets).map(&:to_s)
      end

      def record(target_id:, status:, api_method: nil, reason: nil, duration_ms: nil)
        entry = {
          "targetId" => target_id.to_s,
          "status" => status.to_s,
          "apiMethod" => api_method,
          "reason" => reason,
          "durationMs" => duration_ms,
          "recordedAt" => Time.now.utc.iso8601
        }
        entry.delete("apiMethod") if entry["apiMethod"].to_s.empty?
        entry.delete("reason") if entry["reason"].to_s.empty?
        entry.delete("durationMs") if entry["durationMs"].nil?

        @entries << entry
        entry
      end

      def payload
        {
          "runId" => run_id,
          "mode" => mode,
          "generatedAt" => Time.now.utc.iso8601,
          "resolvedTargets" => @resolved_targets,
          "summary" => build_summary,
          "targets" => @entries
        }
      end

      def write
        data = payload
        FileUtils.mkdir_p(File.dirname(output_path))
        temp_path = "#{output_path}.tmp"

        File.open(temp_path, "w") do |file|
          file.write(JSON.pretty_generate(data))
          file.flush
          file.fsync
        end

        File.rename(temp_path, output_path)
        output_path
      end

      private

        def default_output_path(output_dir)
          File.join(output_dir, "run-#{run_id}-coverage.json")
        end

        def build_summary
          {
            "resolved" => @resolved_targets.length,
            "recorded" => @entries.length,
            "covered" => count_status("covered"),
            "unsupported" => count_status("unsupported"),
            "failed" => count_status("failed")
          }
        end

        def count_status(status)
          @entries.count { |entry| entry.fetch("status") == status }
        end
    end
  end
end

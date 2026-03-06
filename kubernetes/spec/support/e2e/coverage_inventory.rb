# frozen_string_literal: true

require "fileutils"
require "json"
require "time"
require "yaml"

module SpecSupport
  module E2E
    class CoverageInventory
      DEFAULT_API_GLOB = File.expand_path("../../../lib/kubernetes/api/*_api.rb", __dir__)
      DEFAULT_POLICY_PATH = File.expand_path("coverage_policy.yml", __dir__)
      DEFAULT_REPO_ROOT = File.expand_path("../../../..", __dir__)
      DEFAULT_INCLUDE_PREFIXES = %w[create read list replace patch delete watch].freeze
      METHOD_PATTERN = /^\s*def\s+([a-z0-9_!?]+)/.freeze
      HTTP_INFO_SUFFIX = "_with_http_info"

      def initialize(api_glob: DEFAULT_API_GLOB, policy_path: DEFAULT_POLICY_PATH, repo_root: DEFAULT_REPO_ROOT)
        @api_glob = api_glob
        @policy_path = policy_path
        @repo_root = repo_root
      end

      def generate
        policy = load_policy
        include_prefixes = include_prefixes_from(policy)
        exclude_rules = exclude_rules_from(policy)

        api_entries = Dir[@api_glob].sort.map do |api_file|
          analyze_api_file(api_file, include_prefixes: include_prefixes, exclude_rules: exclude_rules)
        end

        method_entries = api_entries.flat_map { |entry| entry.fetch("methods") }

        {
          "generatedAt" => Time.now.utc.iso8601,
          "policy" => {
            "path" => relative_path(@policy_path),
            "loaded" => File.exist?(@policy_path),
            "includePrefixes" => include_prefixes,
            "excludeRuleCount" => exclude_rules.length
          },
          "totals" => summarize_totals(api_entries: api_entries, method_entries: method_entries),
          "operations" => summarize_operations(method_entries),
          "apis" => api_entries.map { |entry| summarize_api_entry(entry) },
          "candidates" => method_entries.select { |entry| entry.fetch("classification") == "candidate" },
          "exclusions" => method_entries.reject { |entry| entry.fetch("classification") == "candidate" }
        }
      end

      def write_json(path, pretty: true)
        payload = generate
        FileUtils.mkdir_p(File.dirname(path))
        serialized = pretty ? JSON.pretty_generate(payload) : JSON.generate(payload)
        File.write(path, serialized)
        path
      end

      private

      def analyze_api_file(api_file, include_prefixes:, exclude_rules:)
        api_name = File.basename(api_file, ".rb")
        methods = []

        File.foreach(api_file).with_index(1) do |line, line_number|
          match = METHOD_PATTERN.match(line)
          next unless match

          method_name = match[1]
          methods << classify_method(
            api_file: api_file,
            api_name: api_name,
            method_name: method_name,
            line: line_number,
            include_prefixes: include_prefixes,
            exclude_rules: exclude_rules
          )
        end

        {
          "api" => api_name,
          "file" => relative_path(api_file),
          "methods" => methods
        }
      end

      def classify_method(api_file:, api_name:, method_name:, line:, include_prefixes:, exclude_rules:)
        operation = detect_operation(method_name, include_prefixes)

        if method_name.end_with?(HTTP_INFO_SUFFIX)
          build_method_entry(
            api_file: api_file,
            api_name: api_name,
            method_name: method_name,
            line: line,
            operation: operation,
            classification: "http_info_variant",
            reason: "Generated _with_http_info wrapper"
          )
        elsif operation.nil?
          build_method_entry(
            api_file: api_file,
            api_name: api_name,
            method_name: method_name,
            line: line,
            operation: nil,
            classification: "non_target_operation",
            reason: "Method does not match CRUD/watch operation prefixes"
          )
        else
          matched_rule = exclude_rules.find { |rule| rule.fetch(:regex).match?(method_name) }

          if matched_rule
            build_method_entry(
              api_file: api_file,
              api_name: api_name,
              method_name: method_name,
              line: line,
              operation: operation,
              classification: "excluded_by_policy",
              reason: matched_rule.fetch(:reason),
              exclusion_rule: matched_rule.fetch(:pattern)
            )
          else
            build_method_entry(
              api_file: api_file,
              api_name: api_name,
              method_name: method_name,
              line: line,
              operation: operation,
              classification: "candidate"
            )
          end
        end
      end

      def build_method_entry(api_file:, api_name:, method_name:, line:, operation:, classification:, reason: nil, exclusion_rule: nil)
        entry = {
          "api" => api_name,
          "file" => relative_path(api_file),
          "line" => line,
          "method" => method_name,
          "operation" => operation,
          "classification" => classification
        }
        entry["reason"] = reason if reason
        entry["exclusionRule"] = exclusion_rule if exclusion_rule
        entry
      end

      def summarize_totals(api_entries:, method_entries:)
        {
          "apiFiles" => api_entries.length,
          "methodsTotal" => method_entries.length,
          "methodsWithoutHttpInfo" => method_entries.count { |entry| entry.fetch("classification") != "http_info_variant" },
          "methodsWithHttpInfo" => method_entries.count { |entry| entry.fetch("classification") == "http_info_variant" },
          "candidateMethods" => method_entries.count { |entry| entry.fetch("classification") == "candidate" },
          "excludedByPolicy" => method_entries.count { |entry| entry.fetch("classification") == "excluded_by_policy" },
          "nonTargetOperations" => method_entries.count { |entry| entry.fetch("classification") == "non_target_operation" }
        }
      end

      def summarize_operations(method_entries)
        operation_stats = {}

        method_entries.each do |entry|
          operation = entry.fetch("operation")
          next if operation.nil?

          operation_stats[operation] ||= {
            "total" => 0,
            "candidate" => 0,
            "excludedByPolicy" => 0,
            "httpInfoVariant" => 0
          }

          stat = operation_stats.fetch(operation)
          stat["total"] += 1

          case entry.fetch("classification")
          when "candidate"
            stat["candidate"] += 1
          when "excluded_by_policy"
            stat["excludedByPolicy"] += 1
          when "http_info_variant"
            stat["httpInfoVariant"] += 1
          end
        end

        operation_stats.sort.to_h
      end

      def summarize_api_entry(entry)
        methods = entry.fetch("methods")

        {
          "api" => entry.fetch("api"),
          "file" => entry.fetch("file"),
          "counts" => {
            "methodsTotal" => methods.length,
            "candidateMethods" => methods.count { |method| method.fetch("classification") == "candidate" },
            "excludedByPolicy" => methods.count { |method| method.fetch("classification") == "excluded_by_policy" },
            "nonTargetOperations" => methods.count { |method| method.fetch("classification") == "non_target_operation" },
            "httpInfoVariants" => methods.count { |method| method.fetch("classification") == "http_info_variant" }
          }
        }
      end

      def detect_operation(method_name, include_prefixes)
        include_prefixes.find do |prefix|
          method_name.start_with?("#{prefix}_")
        end
      end

      def load_policy
        return {} unless File.exist?(@policy_path)

        YAML.safe_load(File.read(@policy_path), permitted_classes: [], aliases: false) || {}
      end

      def include_prefixes_from(policy)
        prefixes = Array(policy["include_operation_prefixes"]).map(&:to_s).map(&:strip).reject(&:empty?)
        prefixes.empty? ? DEFAULT_INCLUDE_PREFIXES : prefixes
      end

      def exclude_rules_from(policy)
        Array(policy["exclude_method_patterns"]).each_with_object([]) do |rule, rules|
          pattern = rule.is_a?(Hash) ? rule["pattern"].to_s : ""
          next if pattern.empty?

          rules << {
            pattern: pattern,
            regex: Regexp.new(pattern),
            reason: rule["reason"].to_s.empty? ? "Excluded by policy" : rule["reason"].to_s
          }
        end
      end

      def relative_path(path)
        absolute = File.expand_path(path)
        prefix = "#{@repo_root}/"
        absolute.start_with?(prefix) ? absolute.delete_prefix(prefix) : absolute
      end
    end
  end
end

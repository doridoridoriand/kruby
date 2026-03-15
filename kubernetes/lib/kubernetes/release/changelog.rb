# frozen_string_literal: true

module Kubernetes
  module Release
    class Changelog
      Error = Class.new(StandardError)

      SECTION_HEADER = /^## \[(?<name>[^\]]+)\](?: - (?<label>[^\n]+))?$/.freeze
      EMPTY_UNRELEASED_PLACEHOLDER = "- Nothing yet."

      attr_reader :path

      def initialize(path)
        @path = File.expand_path(path)
      end

      def include?(name)
        entries.key?(name)
      end

      def release_notes(name)
        entry(name).fetch(:body)
      end

      def unreleased_empty?
        return false unless include?("Unreleased")

        body = release_notes("Unreleased").strip
        body.empty? || body == EMPTY_UNRELEASED_PLACEHOLDER
      end

      def validate_release!(version:, tag: nil, require_empty_unreleased: false)
        errors = []
        has_unreleased = include?("Unreleased")

        errors << "missing Unreleased section in #{path}" unless has_unreleased
        errors << "missing CHANGELOG entry for #{version} in #{path}" unless include?(version)

        expected_tag = "v#{version}"
        if tag && tag != expected_tag
          errors << "release tag #{tag} does not match version #{version} (expected #{expected_tag})"
        end

        if require_empty_unreleased && has_unreleased && !unreleased_empty?
          errors << "Unreleased section must be empty before cutting #{expected_tag}"
        end

        raise Error, errors.join("\n") unless errors.empty?

        true
      end

      private

      def entry(name)
        entries.fetch(name) do
          raise Error, "missing CHANGELOG entry for #{name} in #{path}"
        end
      end

      def entries
        @entries ||= parse_entries
      end

      def parse_entries
        content = File.read(path)
        matches = content.to_enum(:scan, SECTION_HEADER).map { Regexp.last_match }

        raise Error, "no CHANGELOG sections found in #{path}" if matches.empty?

        matches.each_with_index.each_with_object({}) do |(match, index), parsed|
          name = match[:name]
          raise Error, "duplicate CHANGELOG section #{name} in #{path}" if parsed.key?(name)

          body_start = match.end(0)
          body_end = index + 1 < matches.length ? matches[index + 1].begin(0) : content.length
          parsed[name] = {
            label: match[:label],
            body: content[body_start...body_end].to_s.strip
          }
        end
      rescue Errno::ENOENT => e
        raise Error, e.message
      end
    end
  end
end

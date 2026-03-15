# frozen_string_literal: true

require "spec_helper"
require "tempfile"
require "kubernetes/release/changelog"

RSpec.describe Kubernetes::Release::Changelog do
  subject(:changelog) { described_class.new(file.path) }

  let(:file) { Tempfile.new("kruby-changelog") }

  after do
    file.close
    file.unlink
  end

  describe "#release_notes" do
    before do
      file.write(<<~MARKDOWN)
        # Changelog

        ## [Unreleased]

        ### Added
        - Pending change

        ## [1.2.2]

        ### Changed
        - Historical baseline

        ## [1.2.3] - 2026-03-15

        ### Fixed
        - Important bug
      MARKDOWN
      file.flush
    end

    it "returns the body for a historical version without a date label" do
      expect(changelog.release_notes("1.2.2")).to eq("### Changed\n- Historical baseline")
    end

    it "returns the body for a released version" do
      expect(changelog.release_notes("1.2.3")).to eq("### Fixed\n- Important bug")
    end
  end

  describe "#validate_release!" do
    before do
      file.write(changelog_body)
      file.flush
    end

    context "when the release entry and tag match" do
      let(:changelog_body) do
        <<~MARKDOWN
          # Changelog

          ## [Unreleased]

          - Nothing yet.

          ## [1.2.3] - 2026-03-15

          ### Added
          - Stable release
        MARKDOWN
      end

      it "passes validation" do
        expect(
          changelog.validate_release!(
            version: "1.2.3",
            tag: "v1.2.3",
            require_empty_unreleased: true
          )
        ).to be(true)
      end
    end

    context "when the Unreleased section is not empty" do
      let(:changelog_body) do
        <<~MARKDOWN
          # Changelog

          ## [Unreleased]

          ### Added
          - Still pending

          ## [1.2.3] - 2026-03-15

          ### Added
          - Stable release
        MARKDOWN
      end

      it "raises an error" do
        expect do
          changelog.validate_release!(
            version: "1.2.3",
            tag: "v1.2.3",
            require_empty_unreleased: true
          )
        end.to raise_error(
          described_class::Error,
          "Unreleased section must be empty before cutting v1.2.3"
        )
      end
    end

    context "when the tag does not match the version" do
      let(:changelog_body) do
        <<~MARKDOWN
          # Changelog

          ## [Unreleased]

          - Nothing yet.

          ## [1.2.3] - 2026-03-15

          ### Added
          - Stable release
        MARKDOWN
      end

      it "raises an error" do
        expect do
          changelog.validate_release!(version: "1.2.3", tag: "v1.2.4")
        end.to raise_error(
          described_class::Error,
          "release tag v1.2.4 does not match version 1.2.3 (expected v1.2.3)"
        )
      end
    end

    context "when the Unreleased section is missing" do
      let(:changelog_body) do
        <<~MARKDOWN
          # Changelog

          ## [1.2.3]

          ### Added
          - Historical release
        MARKDOWN
      end

      it "only reports the missing section error" do
        expect do
          changelog.validate_release!(
            version: "1.2.3",
            tag: "v1.2.3",
            require_empty_unreleased: true
          )
        end.to raise_error(
          described_class::Error,
          "missing Unreleased section in #{file.path}"
        )
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe SpecSupport::E2E::KindVersionResolver do
  describe ".resolve_kubernetes_version" do
    it "accepts the README compatibility minors and normalizes patch inputs" do
      expect(described_class.resolve_kubernetes_version("1.31")).to eq("1.31")
      expect(described_class.resolve_kubernetes_version("v1.32.11")).to eq("1.32")
      expect(described_class.resolve_kubernetes_version("1.33.7+build.1")).to eq("1.33")
      expect(described_class.resolve_kubernetes_version("1.34.3")).to eq("1.34")
      expect(described_class.resolve_kubernetes_version("1.35.0")).to eq("1.35")
    end

    it "rejects unsupported Kubernetes minors" do
      expect do
        described_class.resolve_kubernetes_version("1.29")
      end.to raise_error(ArgumentError, /unsupported Kubernetes version/)
    end
  end

  describe ".resolve_node_image" do
    it "returns a pinned kind node image for each supported minor" do
      described_class.supported_versions.each do |version|
        expect(described_class.resolve_node_image(kubernetes_version: version)).to start_with("kindest/node:v#{version}")
      end
    end

    it "honors an explicit node image override" do
      image = described_class.resolve_node_image(
        kubernetes_version: "1.35",
        explicit_image: "kindest/node:v1.35.0"
      )

      expect(image).to eq("kindest/node:v1.35.0")
    end
  end
end

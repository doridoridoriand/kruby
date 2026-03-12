# frozen_string_literal: true

module SpecSupport
  module E2E
    module KindVersionResolver
      DEFAULT_KUBERNETES_VERSION = "1.35"

      # Pinned to the official kind v0.31.0 node images so local E2E coverage
      # is stable across machines and doesn't drift with the installed kind binary.
      NODE_IMAGES = {
        "1.31" => "kindest/node:v1.31.14@sha256:6f86cf509dbb42767b6e79debc3f2c32e4ee01386f0489b3b2be24b0a55aac2b",
        "1.32" => "kindest/node:v1.32.11@sha256:5fc52d52a7b9574015299724bd68f183702956aa4a2116ae75a63cb574b35af8",
        "1.33" => "kindest/node:v1.33.7@sha256:d26ef333bdb2cbe9862a0f7c3803ecc7b4303d8cea8e814b481b09949d353040",
        "1.34" => "kindest/node:v1.34.3@sha256:08497ee19eace7b4b5348db5c6a1591d7752b164530a36f855cb0f2bdcbadd48",
        "1.35" => "kindest/node:v1.35.0@sha256:452d707d4862f52530247495d180205e029056831160e22870e37e3f6c1ac31f"
      }.freeze

      module_function

      def supported_versions
        NODE_IMAGES.keys
      end

      def default_kubernetes_version
        DEFAULT_KUBERNETES_VERSION
      end

      def normalize_kubernetes_version(version)
        raw = version.to_s.strip
        raw = DEFAULT_KUBERNETES_VERSION if raw.empty?

        normalized = raw.sub(/\Av/i, "")
        normalized = normalized.split("+", 2).first
        normalized = normalized.split("-", 2).first

        parts = normalized.split(".")
        return nil if parts.length < 2

        "#{parts[0]}.#{parts[1]}"
      end

      def resolve_kubernetes_version(version)
        normalized = normalize_kubernetes_version(version)
        raise ArgumentError, "unsupported Kubernetes version: #{version}" unless normalized && NODE_IMAGES.key?(normalized)

        normalized
      end

      def resolve_node_image(kubernetes_version:, explicit_image: nil)
        image = explicit_image.to_s.strip
        return image unless image.empty?

        NODE_IMAGES.fetch(resolve_kubernetes_version(kubernetes_version))
      end

      def version_slug(kubernetes_version)
        "v#{resolve_kubernetes_version(kubernetes_version).tr('.', '-')}"
      end
    end
  end
end

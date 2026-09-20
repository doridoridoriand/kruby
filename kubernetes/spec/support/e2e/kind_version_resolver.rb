# frozen_string_literal: true

module SpecSupport
  module E2E
    module KindVersionResolver
      DEFAULT_KUBERNETES_VERSION = "1.35"

      # Pinned to official kind node images so local E2E coverage is stable
      # across machines and doesn't drift with the installed kind binary.
      NODE_IMAGES = {
        "1.31" => "kindest/node:v1.31.14@sha256:6f86cf509dbb42767b6e79debc3f2c32e4ee01386f0489b3b2be24b0a55aac2b",
        "1.32" => "kindest/node:v1.32.11@sha256:5fc52d52a7b9574015299724bd68f183702956aa4a2116ae75a63cb574b35af8",
        "1.33" => "kindest/node:v1.33.12@sha256:3f5c8443c620245e4d355cfe09e96a91ead32ceaa569d3f1ca9edf0cb2fe2ff4",
        "1.34" => "kindest/node:v1.34.11@sha256:44e222ee2132dab25ff87301682f89eb82c7880ea3a1bf543bfe9708fd08d67d",
        "1.35" => "kindest/node:v1.35.8@sha256:07b2536e30b803ed61d1677a79df6115f798ce64c80f9e22f6ed45afd09323c0",
        "1.36" => "kindest/node:v1.36.4@sha256:099e049362a1526b2db71494e1947aae99bd16290d7c895f2b7ea312e3cbfaed"
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

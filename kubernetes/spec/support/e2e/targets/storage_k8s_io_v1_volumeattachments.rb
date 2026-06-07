# frozen_string_literal: true

module SpecSupport
  module E2E
    module Targets
      module StorageK8sIoV1VolumeAttachments
        module_function

        def register!(catalog)
          %w[list].each do |operation|
            catalog.register(
              api_group: "storage.k8s.io",
              version: "v1",
              resource: "volumeattachments",
              operation: operation,
              namespace_scoped: false
            )
          end

          catalog
        end
      end
    end
  end
end

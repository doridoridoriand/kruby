# frozen_string_literal: true

module SpecSupport
  module E2E
    module Targets
      module StorageK8sIoV1CsiStorageCapacities
        module_function

        def register!(catalog)
          %w[create get list update patch delete watch].each do |operation|
            catalog.register(
              api_group: "storage.k8s.io",
              version: "v1",
              resource: "csistoragecapacities",
              operation: operation,
              namespace_scoped: true
            )
          end

          catalog
        end
      end
    end
  end
end

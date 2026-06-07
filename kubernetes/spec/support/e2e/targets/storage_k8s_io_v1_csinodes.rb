# frozen_string_literal: true

module SpecSupport
  module E2E
    module Targets
      module StorageK8sIoV1Csinodes
        module_function

        def register!(catalog)
          %w[get list].each do |operation|
            catalog.register(
              api_group: "storage.k8s.io",
              version: "v1",
              resource: "csinodes",
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

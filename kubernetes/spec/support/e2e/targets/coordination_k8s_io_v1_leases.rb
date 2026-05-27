# frozen_string_literal: true

module SpecSupport
  module E2E
    module Targets
      module CoordinationK8sIoV1Leases
        module_function

        def register!(catalog)
          %w[create get list update patch delete watch].each do |operation|
            catalog.register(
              api_group: "coordination.k8s.io",
              version: "v1",
              resource: "leases",
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

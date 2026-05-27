# frozen_string_literal: true

module SpecSupport
  module E2E
    module Targets
      module PolicyV1PodDisruptionBudgets
        module_function

        def register!(catalog)
          %w[create get list update patch delete watch].each do |operation|
            catalog.register(
              api_group: "policy",
              version: "v1",
              resource: "poddisruptionbudgets",
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

# frozen_string_literal: true

module SpecSupport
  module E2E
    module Targets
      module CoreV1ConfigMaps
        module_function

        def register!(catalog)
          %w[create get list update patch delete].each do |operation|
            catalog.register(
              api_group: "core",
              version: "v1",
              resource: "config-maps",
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

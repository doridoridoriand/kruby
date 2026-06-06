# frozen_string_literal: true

module SpecSupport
  module E2E
    module Targets
      module CustomV1Customobjects
        module_function

        def register!(catalog)
          %w[create get list update patch delete].each do |operation|
            catalog.register(
              api_group: "custom",
              version: "v1",
              resource: "customobjects",
              operation: operation,
              namespace_scoped: true
            )
            catalog.register(
              api_group: "custom",
              version: "v1",
              resource: "customobjects-cluster",
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

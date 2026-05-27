# frozen_string_literal: true

module SpecSupport
  module E2E
    module Targets
      module CoreV1Nodes
        module_function

        def register!(catalog)
          %w[get list patch watch].each do |operation|
            catalog.register(
              api_group: "core",
              version: "v1",
              resource: "nodes",
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

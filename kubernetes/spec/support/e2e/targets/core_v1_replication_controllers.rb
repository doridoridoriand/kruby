# frozen_string_literal: true

module SpecSupport
  module E2E
    module Targets
      module CoreV1ReplicationControllers
        module_function

        def register!(catalog)
          %w[create get list update patch delete].each do |operation|
            catalog.register(
              api_group: "core",
              version: "v1",
              resource: "replication-controllers",
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

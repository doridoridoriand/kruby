# frozen_string_literal: true

module SpecSupport
  module E2E
    module Targets
      module CoreV1PersistentVolumes
        module_function

        def register!(catalog)
          %w[create get list update patch delete watch].each do |operation|
            catalog.register(
              api_group: "core",
              version: "v1",
              resource: "persistentvolumes",
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

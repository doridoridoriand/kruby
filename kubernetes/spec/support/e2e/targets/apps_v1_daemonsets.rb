# frozen_string_literal: true

module SpecSupport
  module E2E
    module Targets
      module AppsV1DaemonSets
        module_function

        def register!(catalog)
          %w[create get list update patch delete watch].each do |operation|
            catalog.register(
              api_group: "apps",
              version: "v1",
              resource: "daemonsets",
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

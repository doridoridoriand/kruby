# frozen_string_literal: true

module SpecSupport
  module E2E
    module Targets
      module AppsV1ControllerRevisions
        module_function

        def register!(catalog)
          %w[create get list update patch delete].each do |operation|
            catalog.register(
              api_group: "apps",
              version: "v1",
              resource: "controller-revisions",
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

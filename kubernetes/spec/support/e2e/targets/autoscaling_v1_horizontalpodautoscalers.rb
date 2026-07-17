# frozen_string_literal: true

module SpecSupport
  module E2E
    module Targets
      module AutoscalingV1Horizontalpodautoscalers
        module_function

        def register!(catalog)
          %w[create get list update patch delete].each do |operation|
            catalog.register(
              api_group: "autoscaling",
              version: "v1",
              resource: "horizontalpodautoscalers",
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

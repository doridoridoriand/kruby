# frozen_string_literal: true

module SpecSupport
  module E2E
    module Targets
      module SchedulingK8sIoV1PriorityClasses
        module_function

        def register!(catalog)
          %w[create get list update patch delete watch].each do |operation|
            catalog.register(
              api_group: "scheduling.k8s.io",
              version: "v1",
              resource: "priorityclasses",
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

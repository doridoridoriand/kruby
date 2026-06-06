# frozen_string_literal: true

module SpecSupport
  module E2E
    module Targets
      module NetworkingV1IpAddresses
        module_function

        def register!(catalog)
          %w[create get list update patch delete].each do |operation|
            catalog.register(
              api_group: "networking.k8s.io",
              version: "v1",
              resource: "ipaddresses",
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

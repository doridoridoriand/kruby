# frozen_string_literal: true

module SpecSupport
  module E2E
    module Targets
      module AuthenticationK8sIoV1Tokenreviews
        module_function

        def register!(catalog)
          catalog.register(
            api_group: "authentication.k8s.io",
            version: "v1",
            resource: "tokenreviews",
            operation: "create",
            namespace_scoped: false
          )

          catalog
        end
      end
    end
  end
end

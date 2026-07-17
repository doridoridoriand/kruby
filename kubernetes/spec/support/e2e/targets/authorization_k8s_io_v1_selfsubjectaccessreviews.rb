# frozen_string_literal: true

module SpecSupport
  module E2E
    module Targets
      module AuthorizationK8sIoV1Selfsubjectaccessreviews
        module_function

        def register!(catalog)
          catalog.register(
            api_group: "authorization.k8s.io",
            version: "v1",
            resource: "selfsubjectaccessreviews",
            operation: "create",
            namespace_scoped: false
          )

          catalog
        end
      end
    end
  end
end

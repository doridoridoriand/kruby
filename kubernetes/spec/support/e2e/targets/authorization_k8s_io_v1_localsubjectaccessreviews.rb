# frozen_string_literal: true

module SpecSupport
  module E2E
    module Targets
      module AuthorizationK8sIoV1Localsubjectaccessreviews
        module_function

        def register!(catalog)
          catalog.register(
            api_group: "authorization.k8s.io",
            version: "v1",
            resource: "localsubjectaccessreviews",
            operation: "create",
            namespace_scoped: true
          )

          catalog
        end
      end
    end
  end
end

# frozen_string_literal: true

module SpecSupport
  module E2E
    module Targets
      module RbacAuthorizationV1Roles
        module_function

        def register!(catalog)
          %w[create get list update patch delete].each do |operation|
            catalog.register(
              api_group: "rbac.authorization.k8s.io",
              version: "v1",
              resource: "roles",
              operation: operation,
              namespace_scoped: true
            )
            catalog.register(
              api_group: "rbac.authorization.k8s.io",
              version: "v1",
              resource: "clusterroles",
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

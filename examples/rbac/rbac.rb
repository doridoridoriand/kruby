require "kruby"
require "pp"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
core_client = Kubernetes::CoreV1Api.new(Kubernetes::ApiClient.new(config))
rbac_client = Kubernetes::RbacAuthorizationV1Api.new(Kubernetes::ApiClient.new(config))

namespace = "default"

# 1. Create ServiceAccount
puts "Creating ServiceAccount..."
sa = Kubernetes::V1ServiceAccount.new({
  metadata: {
    name: "app-sa",
    namespace: namespace,
  },
})
pp core_client.create_namespaced_service_account(namespace, sa)

# 2. Create Role (namespace-scoped permissions)
puts "\nCreating Role..."
role = Kubernetes::V1Role.new({
  metadata: {
    name: "app-role",
    namespace: namespace,
  },
  rules: [
    {
      api_groups: [""],
      resources: ["pods", "services", "configmaps"],
      verbs: ["get", "list", "watch"],
    },
    {
      api_groups: ["apps"],
      resources: ["deployments"],
      verbs: ["get", "list", "watch", "create", "update"],
    },
  ],
})
pp rbac_client.create_namespaced_role(namespace, role)

# 3. Create RoleBinding (bind ServiceAccount to Role)
puts "\nCreating RoleBinding..."
role_binding = Kubernetes::V1RoleBinding.new({
  metadata: {
    name: "app-role-binding",
    namespace: namespace,
  },
  subjects: [
    {
      kind: "ServiceAccount",
      name: "app-sa",
      namespace: namespace,
    },
  ],
  role_ref: {
    api_group: "rbac.authorization.k8s.io",
    kind: "Role",
    name: "app-role",
  },
})
pp rbac_client.create_namespaced_role_binding(namespace, role_binding)

# List Roles
puts "\nListing Roles..."
pp rbac_client.list_namespaced_role(namespace)

# List RoleBindings
puts "\nListing RoleBindings..."
pp rbac_client.list_namespaced_role_binding(namespace)

# Cleanup
puts "\nDeleting RoleBinding..."
pp rbac_client.delete_namespaced_role_binding("app-role-binding", namespace)

puts "\nDeleting Role..."
pp rbac_client.delete_namespaced_role("app-role", namespace)

puts "\nDeleting ServiceAccount..."
pp core_client.delete_namespaced_service_account("app-sa", namespace)

require "kruby"
require "pp"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
core_client = Kubernetes::CoreV1Api.new(Kubernetes::ApiClient.new(config))
rbac_client = Kubernetes::RbacAuthorizationV1Api.new(Kubernetes::ApiClient.new(config))

namespace = "default"

def api_call(description, ignore_codes: [])
  yield
rescue Kubernetes::ApiError => e
  if ignore_codes.include?(e.code.to_i)
    puts "#{description}: #{e.code} (continuing)"
    nil
  else
    warn "#{description} failed: #{e.code} #{e.message}"
    raise
  end
end

# 1. Create ServiceAccount
puts "Creating ServiceAccount..."
sa = Kubernetes::V1ServiceAccount.new({
  metadata: {
    name: "app-sa",
    namespace: namespace,
  },
})
pp api_call("Creating ServiceAccount", ignore_codes: [409]) {
  core_client.create_namespaced_service_account(namespace, sa)
}
sleep 3

# 2. Create Role (namespace-scoped permissions)
puts "\nCreating Role..."
role = Kubernetes::V1Role.new({
  metadata: {
    name: "app-role",
    namespace: namespace,
  },
  rules: [
    {
      "apiGroups" => [""],
      resources: ["pods", "services", "configmaps"],
      verbs: ["get", "list", "watch"],
    },
    # Includes create/update to demonstrate mutating Deployment permissions.
    {
      "apiGroups" => ["apps"],
      resources: ["deployments"],
      verbs: ["get", "list", "watch", "create", "update"],
    },
  ],
})
pp api_call("Creating Role", ignore_codes: [409]) {
  rbac_client.create_namespaced_role(namespace, role)
}
sleep 3

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
    "apiGroup" => "rbac.authorization.k8s.io",
    kind: "Role",
    name: "app-role",
  },
})
pp api_call("Creating RoleBinding", ignore_codes: [409]) {
  rbac_client.create_namespaced_role_binding(namespace, role_binding)
}
sleep 3

# List Roles
puts "\nListing Roles..."
pp api_call("Listing Roles") { rbac_client.list_namespaced_role(namespace) }
sleep 3

# List RoleBindings
puts "\nListing RoleBindings..."
pp api_call("Listing RoleBindings") { rbac_client.list_namespaced_role_binding(namespace) }
sleep 3

# Cleanup
puts "\nDeleting RoleBinding..."
pp api_call("Deleting RoleBinding", ignore_codes: [404]) {
  rbac_client.delete_namespaced_role_binding("app-role-binding", namespace)
}

puts "\nDeleting Role..."
pp api_call("Deleting Role", ignore_codes: [404]) {
  rbac_client.delete_namespaced_role("app-role", namespace)
}

puts "\nDeleting ServiceAccount..."
pp api_call("Deleting ServiceAccount", ignore_codes: [404]) {
  core_client.delete_namespaced_service_account("app-sa", namespace)
}

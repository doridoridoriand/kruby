require "kruby"
require "pp"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
networking_client = Kubernetes::NetworkingV1Api.new(Kubernetes::ApiClient.new(config))

# Create a NetworkPolicy that allows ingress only from pods with label app=frontend
network_policy = Kubernetes::V1NetworkPolicy.new({
  metadata: {
    name: "allow-frontend-ingress",
    namespace: "default",
  },
  spec: {
    pod_selector: {
      match_labels: { "app" => "backend" },
    },
    policy_types: ["Ingress"],
    ingress: [
      {
        from: [
          {
            pod_selector: {
              match_labels: { "app" => "frontend" },
            },
          },
        ],
        ports: [
          {
            protocol: "TCP",
            port: 80,
          },
        ],
      },
    ],
  },
})

puts "Creating NetworkPolicy..."
result = networking_client.create_namespaced_network_policy("default", network_policy)
puts "Created: #{result.metadata.name}"
puts "  policyTypes: #{result.spec.policy_types.join(', ')}"

# Get
puts "\nReading NetworkPolicy..."
pp networking_client.read_namespaced_network_policy("allow-frontend-ingress", "default")

# List
puts "\nListing NetworkPolicies..."
pp networking_client.list_namespaced_network_policy("default")

# Delete
puts "\nDeleting NetworkPolicy..."
pp networking_client.delete_namespaced_network_policy("allow-frontend-ingress", "default")

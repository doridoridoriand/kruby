require "kruby"
require "pp"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
client = Kubernetes::CoreV1Api.new(Kubernetes::ApiClient.new(config))

# ClusterIP Service
cluster_ip_service = Kubernetes::V1Service.new({
  metadata: {
    name: "my-service",
    namespace: "default",
  },
  spec: {
    selector: { "app" => "nginx" },
    ports: [{ port: 80, target_port: 80, protocol: "TCP" }],
    type: "ClusterIP",
  },
})

puts "Creating ClusterIP service..."
result = client.create_namespaced_service("default", cluster_ip_service)
puts "Created: #{result.metadata.name} (clusterIP: #{result.spec.cluster_ip})"
sleep 3

# NodePort Service
node_port_service = Kubernetes::V1Service.new({
  metadata: {
    name: "my-nodeport-service",
    namespace: "default",
  },
  spec: {
    selector: { "app" => "nginx" },
    ports: [{ port: 80, target_port: 80, protocol: "TCP" }],
    type: "NodePort",
  },
})

puts "\nCreating NodePort service..."
result = client.create_namespaced_service("default", node_port_service)
puts "Created: #{result.metadata.name} (nodePort: #{result.spec.ports[0].node_port})"
sleep 3

# List
puts "\nListing services..."
pp client.list_namespaced_service("default")
sleep 3

# Delete
puts "\nDeleting services..."
pp client.delete_namespaced_service("my-service", "default")
pp client.delete_namespaced_service("my-nodeport-service", "default")

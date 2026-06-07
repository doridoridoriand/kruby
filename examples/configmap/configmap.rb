require "kruby"
require "pp"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
client = Kubernetes::CoreV1Api.new(Kubernetes::ApiClient.new(config))

config_map = Kubernetes::V1ConfigMap.new({
  metadata: {
    name: "app-config",
    namespace: "default",
  },
  data: {
    "app.properties" => "database_url=postgres://db:5432/mydb\nlog_level=info",
    "config.yaml" => "key: value\nnested:\n  key2: value2",
  },
  binary_data: {
    "binary-key" => Base64.strict_encode64("binary content"),
  },
})

# Create
puts "Creating ConfigMap..."
result = client.create_namespaced_config_map("default", config_map)
puts "Created: #{result.metadata.name}"
pp result.data

# Get
puts "\nReading ConfigMap..."
pp client.read_namespaced_config_map("app-config", "default")

# Update
puts "\nUpdating ConfigMap..."
config_map.data["new-key"] = "new-value"
pp client.replace_namespaced_config_map("app-config", "default", config_map)

# List
puts "\nListing ConfigMaps..."
pp client.list_namespaced_config_map("default")

# Delete
puts "\nDeleting ConfigMap..."
pp client.delete_namespaced_config_map("app-config", "default")

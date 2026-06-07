require "kruby"
require "pp"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
client = Kubernetes::CoreV1Api.new(Kubernetes::ApiClient.new(config))

# Opaque Secret (using string_data for automatic base64 encoding)
secret = Kubernetes::V1Secret.new({
  metadata: {
    name: "app-secret",
    namespace: "default",
  },
  type: "Opaque",
  string_data: {
    "username" => "admin",
    "password" => "super-secret-password",
  },
})

# Create
puts "Creating Secret..."
result = client.create_namespaced_secret("default", secret)
puts "Created: #{result.metadata.name} (type: #{result.type})"

# Get (note: data is returned base64-encoded)
puts "\nReading Secret..."
read_secret = client.read_namespaced_secret("app-secret", "default")
puts "Username: #{Base64.decode64(read_secret.data["username"])}"
puts "Password: #{Base64.decode64(read_secret.data["password"])}"

# List
puts "\nListing Secrets..."
pp client.list_namespaced_secret("default")

# Delete
puts "\nDeleting Secret..."
pp client.delete_namespaced_secret("app-secret", "default")

require "kruby"
require "pp"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
core_client = Kubernetes::CoreV1Api.new(Kubernetes::ApiClient.new(config))

# Create a ConfigMap using server-side dry-run — validates without persisting
config_map = Kubernetes::V1ConfigMap.new({
  metadata: {
    name: "dry-run-test",
    namespace: "default",
  },
  data: {
    "key" => "value",
  },
})

# Server-side dry run: Kubernetes validates the object but does not create it
puts "Creating ConfigMap with dry-run (server-side)..."
result = core_client.create_namespaced_config_map(
  "default", config_map,
  dry_run: "All"
)
puts "Dry-run result: #{result.metadata.name} (not actually created)"
sleep 3

# Verify it does NOT exist
puts "\nVerifying it was NOT created..."
begin
  core_client.read_namespaced_config_map("dry-run-test", "default")
  puts "ERROR: ConfigMap exists — dry-run did not work correctly"
rescue Kubernetes::ApiError => e
  raise unless e.code.to_i == 404

  puts "Confirmed: #{e.code} - ConfigMap does not exist (as expected)"
end
sleep 3

# Now create for real (no dry_run option)
puts "\nCreating ConfigMap for real..."
core_client.create_namespaced_config_map("default", config_map)
puts "Created successfully"
sleep 3

# Verify it now exists
puts "\nVerifying it exists..."
pp core_client.read_namespaced_config_map("dry-run-test", "default")
sleep 3

# Cleanup
core_client.delete_namespaced_config_map("dry-run-test", "default")
puts "\nDeleted."

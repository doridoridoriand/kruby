require "kruby"
require "pp"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
core_client = Kubernetes::CoreV1Api.new(Kubernetes::ApiClient.new(config))

# Create a PersistentVolumeClaim
pvc = Kubernetes::V1PersistentVolumeClaim.new({
  metadata: {
    name: "app-pvc",
    namespace: "default",
  },
  spec: {
    "accessModes" => ["ReadWriteOnce"],
    resources: {
      requests: { storage: "1Gi" },
    },
    # storageClassName: "standard",  # uncomment to specify a StorageClass
  },
})

puts "Creating PersistentVolumeClaim..."
result = core_client.create_namespaced_persistent_volume_claim("default", pvc)
puts "Created: #{result.metadata.name}"
puts "  accessModes: #{result.spec.access_modes.join(', ')}"
puts "  capacity: #{result.spec.resources.requests['storage']}"
puts "  status.phase: #{result.status&.phase || 'unknown'}"

# Get
puts "\nReading PVC..."
pp core_client.read_namespaced_persistent_volume_claim("app-pvc", "default")

# List
puts "\nListing PVCs..."
pp core_client.list_namespaced_persistent_volume_claim("default")

# Delete
puts "\nDeleting PVC..."
pp core_client.delete_namespaced_persistent_volume_claim("app-pvc", "default")

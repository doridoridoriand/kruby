require "kruby"
require "pp"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
core_client = Kubernetes::CoreV1Api.new(Kubernetes::ApiClient.new(config))
apps_client = Kubernetes::AppsV1Api.new(Kubernetes::ApiClient.new(config))

headless_service = Kubernetes::V1Service.new({
  metadata: {
    name: "nginx-headless",
    namespace: "default",
  },
  spec: {
    cluster_ip: "None",
    selector: { "app" => "nginx-stateful" },
    ports: [
      { name: "web", port: 80, target_port: 80 },
    ],
  },
})

# Create a StatefulSet
stateful_set = Kubernetes::V1StatefulSet.new({
  metadata: {
    name: "web-statefulset",
    namespace: "default",
  },
  spec: {
    service_name: "nginx-headless",
    replicas: 2,
    pod_management_policy: "OrderedReady",
    update_strategy: {
      type: "RollingUpdate",
      rolling_update: {
        partition: 0,
      },
    },
    selector: {
      match_labels: { "app" => "nginx-stateful" },
    },
    template: {
      metadata: {
        labels: { "app" => "nginx-stateful" },
      },
      spec: {
        containers: [
          {
            name: "nginx",
            image: "nginx:1.27",
            ports: [{ container_port: 80, name: "web" }],
            volume_mounts: [
              { name: "data", mount_path: "/usr/share/nginx/html" },
            ],
          },
        ],
      },
    },
    volume_claim_templates: [
      {
        metadata: { name: "data" },
        spec: {
          access_modes: ["ReadWriteOnce"],
          resources: {
            requests: { storage: "1Gi" },
          },
        },
      },
    ],
  },
})

puts "Creating headless Service..."
service = core_client.create_namespaced_service("default", headless_service)
puts "Created: #{service.metadata.name}"

puts "Creating StatefulSet..."
result = apps_client.create_namespaced_stateful_set("default", stateful_set)
puts "Created: #{result.metadata.name} (replicas: #{result.spec.replicas})"

# Get
puts "\nReading StatefulSet..."
pp apps_client.read_namespaced_stateful_set("web-statefulset", "default")

# List
puts "\nListing StatefulSets..."
pp apps_client.list_namespaced_stateful_set("default")

# Delete
puts "\nDeleting StatefulSet..."
pp apps_client.delete_namespaced_stateful_set("web-statefulset", "default")

puts "\nDeleting headless Service..."
pp core_client.delete_namespaced_service("nginx-headless", "default")

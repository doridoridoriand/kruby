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
    "clusterIP" => "None",
    selector: { "app" => "nginx-stateful" },
    ports: [
      { name: "web", port: 80, "targetPort" => 80 },
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
    "serviceName" => "nginx-headless",
    replicas: 2,
    "podManagementPolicy" => "OrderedReady",
    "updateStrategy" => {
      type: "RollingUpdate",
      "rollingUpdate" => {
        partition: 0,
      },
    },
    selector: {
      "matchLabels" => { "app" => "nginx-stateful" },
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
            ports: [{ "containerPort" => 80, name: "web" }],
            "volumeMounts" => [
              { name: "data", "mountPath" => "/usr/share/nginx/html" },
            ],
          },
        ],
      },
    },
    "volumeClaimTemplates" => [
      {
        metadata: { name: "data" },
        spec: {
          "accessModes" => ["ReadWriteOnce"],
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

puts "\nDeleting PVCs created by StatefulSet..."
2.times do |ordinal|
  pvc_name = "data-web-statefulset-#{ordinal}"
  begin
    pp core_client.delete_namespaced_persistent_volume_claim(pvc_name, "default")
  rescue Kubernetes::ApiError => e
    raise unless e.code.to_i == 404

    puts "#{pvc_name}: already deleted"
  end
end

puts "\nDeleting headless Service..."
pp core_client.delete_namespaced_service("nginx-headless", "default")

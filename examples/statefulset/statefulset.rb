require "kruby"
require "pp"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
core_client = Kubernetes::CoreV1Api.new(Kubernetes::ApiClient.new(config))
apps_client = Kubernetes::AppsV1Api.new(Kubernetes::ApiClient.new(config))

def delete_pvc_with_retry(client, name, namespace, timeout: 30)
  deadline = Time.now + timeout

  loop do
    return pp client.delete_namespaced_persistent_volume_claim(name, namespace)
  rescue Kubernetes::ApiError => e
    case e.code.to_i
    when 404
      puts "#{name}: already deleted"
      return
    when 409
      raise if Time.now >= deadline

      puts "#{name}: still in use, retrying..."
      sleep 1
    else
      raise
    end
  end
end

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
sleep 3

puts "Creating StatefulSet..."
result = apps_client.create_namespaced_stateful_set("default", stateful_set)
puts "Created: #{result.metadata.name} (replicas: #{result.spec.replicas})"
sleep 3

# Get
puts "\nReading StatefulSet..."
pp apps_client.read_namespaced_stateful_set("web-statefulset", "default")
sleep 3

# List
puts "\nListing StatefulSets..."
pp apps_client.list_namespaced_stateful_set("default")
sleep 3

# Delete
puts "\nDeleting StatefulSet..."
pp apps_client.delete_namespaced_stateful_set("web-statefulset", "default")

puts "\nDeleting PVCs created by StatefulSet..."
2.times do |ordinal|
  pvc_name = "data-web-statefulset-#{ordinal}"
  delete_pvc_with_retry(core_client, pvc_name, "default")
end

puts "\nDeleting headless Service..."
pp core_client.delete_namespaced_service("nginx-headless", "default")

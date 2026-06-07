require "kruby"
require "pp"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)

apps_client = Kubernetes::AppsV1Api.new(Kubernetes::ApiClient.new(config))
core_client = Kubernetes::CoreV1Api.new(Kubernetes::ApiClient.new(config))

deployment = Kubernetes::V1Deployment.new({
  metadata: {
    name: "nginx-deployment",
    namespace: "default",
    labels: { "app" => "nginx" },
  },
  spec: {
    replicas: 2,
    selector: {
      match_labels: { "app" => "nginx" },
    },
    template: {
      metadata: {
        labels: { "app" => "nginx" },
      },
      spec: {
        containers: [
          {
            name: "nginx",
            image: "nginx:1.27",
            ports: [{ container_port: 80 }],
          },
        ],
      },
    },
  },
})

# Create
puts "Creating deployment..."
result = apps_client.create_namespaced_deployment("default", deployment)
puts "Created: #{result.metadata.name}"
sleep 3

# Get
puts "\nGetting deployment..."
pp apps_client.read_namespaced_deployment("nginx-deployment", "default")
sleep 3

# List
puts "\nListing deployments..."
pp apps_client.list_namespaced_deployment("default")
sleep 3

# Scale (update replicas to 3)
puts "\nScaling to 3 replicas..."
deployment.spec.replicas = 3
pp apps_client.replace_namespaced_deployment("nginx-deployment", "default", deployment)
sleep 3

# Delete
puts "\nDeleting deployment..."
pp apps_client.delete_namespaced_deployment("nginx-deployment", "default")

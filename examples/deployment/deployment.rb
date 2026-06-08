require "kruby"
require "pp"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)

client = Kubernetes::AppsV1Api.new(Kubernetes::ApiClient.new(config))

deployment = Kubernetes::V1Deployment.new({
  metadata: {
    name: "nginx-deployment",
    namespace: "default",
    labels: { "app" => "nginx" },
  },
  spec: {
    replicas: 2,
    selector: {
      "matchLabels" => { "app" => "nginx" },
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
            ports: [{ "containerPort" => 80 }],
          },
        ],
      },
    },
  },
})

# Create
puts "Creating deployment..."
result = client.create_namespaced_deployment("default", deployment)
puts "Created: #{result.metadata.name}"

# Get
puts "\nGetting deployment..."
current = client.read_namespaced_deployment("nginx-deployment", "default")
pp current

# List
puts "\nListing deployments..."
pp client.list_namespaced_deployment("default")

# Scale (update replicas to 3)
puts "\nScaling to 3 replicas..."
patch = [
  { op: "replace", path: "/spec/replicas", value: 3 },
]
pp client.patch_namespaced_deployment("nginx-deployment", "default", patch)

# Delete
puts "\nDeleting deployment..."
pp client.delete_namespaced_deployment("nginx-deployment", "default")

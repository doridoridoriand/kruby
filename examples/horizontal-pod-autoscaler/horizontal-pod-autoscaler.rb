require "kruby"
require "pp"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
autoscaling_client = Kubernetes::AutoscalingV2Api.new(Kubernetes::ApiClient.new(config))

# Create a HorizontalPodAutoscaler targeting a Deployment
hpa = Kubernetes::V2HorizontalPodAutoscaler.new({
  metadata: {
    name: "nginx-hpa",
    namespace: "default",
  },
  spec: {
    scale_target_ref: {
      api_version: "apps/v1",
      kind: "Deployment",
      name: "nginx-deployment",
    },
    min_replicas: 2,
    max_replicas: 10,
    metrics: [
      {
        type: "Resource",
        resource: {
          name: "cpu",
          target: {
            type: "Utilization",
            average_utilization: 80,
          },
        },
      },
    ],
  },
})

puts "Creating HorizontalPodAutoscaler..."
result = autoscaling_client.create_namespaced_horizontal_pod_autoscaler("default", hpa)
puts "Created: #{result.metadata.name}"
puts "  minReplicas: #{result.spec.min_replicas}, maxReplicas: #{result.spec.max_replicas}"
puts "  target CPU utilization: #{result.spec.metrics[0].resource.target.average_utilization}%"

# Get
puts "\nReading HPA..."
pp autoscaling_client.read_namespaced_horizontal_pod_autoscaler("nginx-hpa", "default")

# List
puts "\nListing HPAs..."
pp autoscaling_client.list_namespaced_horizontal_pod_autoscaler("default")

# Delete
puts "\nDeleting HPA..."
pp autoscaling_client.delete_namespaced_horizontal_pod_autoscaler("nginx-hpa", "default")

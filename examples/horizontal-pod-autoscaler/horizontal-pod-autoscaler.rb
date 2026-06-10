require "kruby"
require "pp"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
autoscaling_client = Kubernetes::AutoscalingV2Api.new(Kubernetes::ApiClient.new(config))
namespace = "default"

# Prerequisite: a Deployment named nginx-deployment must exist in the target namespace.
hpa = Kubernetes::V2HorizontalPodAutoscaler.new({
  metadata: {
    name: "nginx-hpa",
    namespace: namespace,
  },
  spec: {
    "scaleTargetRef" => {
      "apiVersion" => "apps/v1",
      kind: "Deployment",
      name: "nginx-deployment",
    },
    "minReplicas" => 2,
    "maxReplicas" => 10,
    metrics: [
      {
        type: "Resource",
        resource: {
          name: "cpu",
          target: {
            type: "Utilization",
            "averageUtilization" => 80,
          },
        },
      },
    ],
  },
})

puts "Creating HorizontalPodAutoscaler..."
result = autoscaling_client.create_namespaced_horizontal_pod_autoscaler_post_apis_autoscaling_v2_namespaces_by_namespace_horizontalpodautoscalers(
  namespace, hpa
)
puts "Created: #{result.metadata.name}"
puts "  minReplicas: #{result.spec.min_replicas}, maxReplicas: #{result.spec.max_replicas}"
puts "  target CPU utilization: #{result.spec.metrics[0].resource.target.average_utilization}%"
sleep 3

# Get
puts "\nReading HPA..."
pp autoscaling_client
  .read_namespaced_horizontal_pod_autoscaler_get_apis_autoscaling_v2_namespaces_by_namespace_horizontalpodautoscalers_by_name(
    "nginx-hpa", namespace
  )
sleep 3

# List
puts "\nListing HPAs..."
pp autoscaling_client
  .list_namespaced_horizontal_pod_autoscaler_get_apis_autoscaling_v2_namespaces_by_namespace_horizontalpodautoscalers(
    namespace
  )
sleep 3

# Delete
puts "\nDeleting HPA..."
pp autoscaling_client
  .delete_namespaced_horizontal_pod_autoscaler_delete_apis_autoscaling_v2_namespaces_by_namespace_horizontalpodautoscalers_by_name(
    "nginx-hpa", namespace
  )

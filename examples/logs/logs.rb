require "kruby"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
logs_client = Kubernetes::LogsApi.new(Kubernetes::ApiClient.new(config))

# Get logs from a running pod
pod_name = ENV["POD_NAME"] || "nginx"
namespace = ENV["NAMESPACE"] || "default"

puts "Getting logs for pod #{namespace}/#{pod_name}..."
logs = logs_client.read_namespaced_pod_log(pod_name, namespace)
puts logs

# Get logs with options
puts "\nGetting recent logs (tail=20, timestamps=true)..."
logs = logs_client.read_namespaced_pod_log(
  pod_name, namespace,
  { tail_lines: 20, timestamps: true }
)
puts logs

# Follow logs (blocks until interrupted with Ctrl+C)
# puts "\nFollowing logs (Ctrl+C to stop)..."
# logs = logs_client.read_namespaced_pod_log(
#   pod_name, namespace,
#   { follow: true, tail_lines: 10 }
# )
# puts logs

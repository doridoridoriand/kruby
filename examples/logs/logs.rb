require "kruby"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
logs_client = Kubernetes::CoreV1Api.new(Kubernetes::ApiClient.new(config))

namespace = ENV["NAMESPACE"] || "default"
pod_name = ENV["POD_NAME"] || "kruby-logs-example"
managed_pod = ENV["POD_NAME"].to_s.empty?

def ignore_not_found
  yield
rescue Kubernetes::ApiError => e
  raise unless e.code.to_i == 404
end

def wait_for_pod_logs(client, name, namespace, timeout: 60)
  deadline = Time.now + timeout

  loop do
    pod = client.read_namespaced_pod(name, namespace)
    phase = pod.status&.phase
    return pod if %w[Running Succeeded Failed].include?(phase)

    raise "Timed out waiting for pod #{namespace}/#{name} to start" if Time.now >= deadline

    sleep 1
  end
end

def wait_for_pod_deleted(client, name, namespace, timeout: 30)
  deadline = Time.now + timeout

  loop do
    client.read_namespaced_pod(name, namespace)
    raise "Timed out waiting for pod #{namespace}/#{name} to be deleted" if Time.now >= deadline

    sleep 1
  rescue Kubernetes::ApiError => e
    raise unless e.code.to_i == 404

    return
  end
end

if managed_pod
  ignore_not_found do
    logs_client.delete_namespaced_pod(pod_name, namespace, grace_period_seconds: 0)
  end
  wait_for_pod_deleted(logs_client, pod_name, namespace)

  pod = Kubernetes::V1Pod.new({
    metadata: {
      name: pod_name,
      namespace: namespace,
      labels: { "app" => "kruby-logs-example" },
    },
    spec: {
      containers: [
        {
          name: "logger",
          image: "busybox:1.36",
          command: ["sh", "-c", "echo hello from kruby logs example; date; sleep 30"],
        },
      ],
      "restartPolicy" => "Never",
    },
  })

  puts "Creating sample pod #{namespace}/#{pod_name}..."
  logs_client.create_namespaced_pod(namespace, pod)
  wait_for_pod_logs(logs_client, pod_name, namespace)
end

begin
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
ensure
  if managed_pod
    puts "\nDeleting sample pod #{namespace}/#{pod_name}..."
    ignore_not_found do
      logs_client.delete_namespaced_pod(pod_name, namespace, grace_period_seconds: 0)
    end
    wait_for_pod_deleted(logs_client, pod_name, namespace)
  end
end

# Follow logs (blocks until interrupted with Ctrl+C)
# puts "\nFollowing logs (Ctrl+C to stop)..."
# logs = logs_client.read_namespaced_pod_log(
#   pod_name, namespace,
#   { follow: true, tail_lines: 10 }
# )
# puts logs

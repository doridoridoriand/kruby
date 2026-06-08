require "kruby"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
client = Kubernetes::ApiClient.new(config)
watch = Kubernetes::Watch.new(client)

# Watch multiple resources simultaneously using threads
namespace = ENV["NAMESPACE"] || "default"

puts "Watching Pods, Services and Events in '#{namespace}' namespace..."
puts "(Press Ctrl+C to stop)\n\n"

threads = []

def watch_resource(watch, label, path)
  Thread.new do
    watch.connect(path) do |event|
      type = event["type"] || "UNKNOWN"
      object = event["object"] || {}
      yield type, object
    end
  rescue StandardError => e
    warn "[ERROR] #{label} watch failed: #{e.class}: #{e.message}"
  end
end

# Watch Pods
threads << watch_resource(watch, "Pod", "/api/v1/namespaces/#{namespace}/pods") do |type, object|
  name = object.dig("metadata", "name") || "unknown"
  puts "[POD] #{type}: #{name}"
end

# Watch Services
threads << watch_resource(watch, "Service", "/api/v1/namespaces/#{namespace}/services") do |type, object|
  name = object.dig("metadata", "name") || "unknown"
  puts "[SERVICE] #{type}: #{name}"
end

# Watch Events
threads << watch_resource(watch, "Event", "/api/v1/namespaces/#{namespace}/events") do |type, object|
  reason = object["reason"] || ""
  message = object["message"] || ""
  puts "[EVENT] #{type}: #{reason} - #{message}"
end

# Wait for all threads (blocks until interrupted)
threads.each(&:join)

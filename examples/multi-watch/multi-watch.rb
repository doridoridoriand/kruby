require "kruby"
require "pp"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
client = Kubernetes::ApiClient.new(config)
watch = Kubernetes::Watch.new(client)

# Watch multiple resources simultaneously using threads
namespace = ENV["NAMESPACE"] || "default"

puts "Watching Pods and Services in '#{namespace}' namespace..."
puts "(Press Ctrl+C to stop)\n\n"

threads = []

# Watch Pods
threads << Thread.new do
  watch.connect("/api/v1/namespaces/#{namespace}/pods") do |type, obj|
    name = obj.dig("metadata", "name") || "unknown"
    puts "[POD] #{type}: #{name}"
  end
end

# Watch Services
threads << Thread.new do
  watch.connect("/api/v1/namespaces/#{namespace}/services") do |type, obj|
    name = obj.dig("metadata", "name") || "unknown"
    puts "[SERVICE] #{type}: #{name}"
  end
end

# Watch Events
threads << Thread.new do
  watch.connect("/api/v1/namespaces/#{namespace}/events") do |type, obj|
    reason = obj.dig("reason") || ""
    message = obj.dig("message") || ""
    puts "[EVENT] #{type}: #{reason} - #{message}"
  end
end

# Wait for all threads (blocks until interrupted)
threads.each(&:join)

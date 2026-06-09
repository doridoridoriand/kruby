require "kruby"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
client = Kubernetes::ApiClient.new(config)
watch = Kubernetes::Watch.new(client)

# Watch multiple resources simultaneously using threads
namespace = ENV["NAMESPACE"] || "default"
watch_timeout_seconds = [Integer(ENV.fetch("WATCH_TIMEOUT_SECONDS", "10")), 1].max

puts "Watching Pods, Services and Events in '#{namespace}' namespace..."
puts "(Stops after #{watch_timeout_seconds} seconds; press Ctrl+C to stop sooner)\n\n"

Signal.trap("INT") { exit!(0) }
Signal.trap("TERM") { exit!(0) }

threads = []

def watch_path(path, timeout_seconds)
  separator = path.include?("?") ? "&" : "?"
  "#{path}#{separator}timeoutSeconds=#{timeout_seconds}"
end

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
threads << watch_resource(
  watch,
  "Pod",
  watch_path("/api/v1/namespaces/#{namespace}/pods", watch_timeout_seconds)
) do |type, object|
  name = object.dig("metadata", "name") || "unknown"
  puts "[POD] #{type}: #{name}"
end

# Watch Services
threads << watch_resource(
  watch,
  "Service",
  watch_path("/api/v1/namespaces/#{namespace}/services", watch_timeout_seconds)
) do |type, object|
  name = object.dig("metadata", "name") || "unknown"
  puts "[SERVICE] #{type}: #{name}"
end

# Watch Events
threads << watch_resource(
  watch,
  "Event",
  watch_path("/api/v1/namespaces/#{namespace}/events", watch_timeout_seconds)
) do |type, object|
  reason = object["reason"] || ""
  message = object["message"] || ""
  puts "[EVENT] #{type}: #{reason} - #{message}"
end

# Wait for all watches to finish or until interrupted.
threads.each(&:join)

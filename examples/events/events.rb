require "kruby"
require "pp"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
events_client = Kubernetes::EventsV1Api.new(Kubernetes::ApiClient.new(config))

namespace = ENV["NAMESPACE"] || "default"

# List events in namespace
puts "Listing events in namespace '#{namespace}'..."
events_list = events_client.list_namespaced_event(namespace)
puts "Found #{events_list.items.length} events"

events_list.items.each do |event|
  puts "\n--- #{event.type} ---"
  puts "Reason: #{event.reason}"
  puts "Message: #{event.message}"
  puts "Involved Object: #{event.involved_object.kind}/#{event.involved_object.name}"
  puts "Count: #{event.count}"
  puts "First Seen: #{event.first_timestamp}"
  puts "Last Seen: #{event.last_timestamp}"
end

# List events with field selector (e.g., only warnings)
puts "\n\nListing only Warning events..."
warning_events = events_client.list_namespaced_event(
  namespace,
  { field_selector: "type=Warning" }
)
puts "Found #{warning_events.items.length} Warning events"
pp warning_events.items[0..4] if warning_events.items.any?

# List cluster-wide events
puts "\n\nListing cluster-wide events..."
cluster_events = events_client.list_event_for_all_namespaces(
  { limit: 5 }
)
puts "Found #{cluster_events.items.length} cluster events (limit 5)"

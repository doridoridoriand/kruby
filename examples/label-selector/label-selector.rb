require "kruby"
require "pp"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
core_client = Kubernetes::CoreV1Api.new(Kubernetes::ApiClient.new(config))

# List all pods in the default namespace
puts "All pods in 'default' namespace:"
all_pods = core_client.list_namespaced_pod("default")
puts "  Total: #{all_pods.items.length}"

# Filter with label selector — only pods with app=nginx
puts "\nPods with label 'app=nginx':"
filtered = core_client.list_namespaced_pod(
  "default",
  label_selector: "app=nginx"
)
puts "  Count: #{filtered.items.length}"
filtered.items.each { |p| puts "    - #{p.metadata.name}" }

# Multiple label selector — app=nginx AND tier=frontend
puts "\nPods with labels 'app=nginx,tier=frontend':"
multi = core_client.list_namespaced_pod(
  "default",
  label_selector: "app=nginx,tier=frontend"
)
puts "  Count: #{multi.items.length}"

# Set-based requirement — pods where env is 'prod' OR 'staging'
puts "\nPods where env in (prod, staging):"
set_based = core_client.list_namespaced_pod(
  "default",
  label_selector: "env in (prod, staging)"
)
puts "  Count: #{set_based.items.length}"

# Negation — pods where env is NOT 'test'
puts "\nPods where env != test:"
negation = core_client.list_namespaced_pod(
  "default",
  label_selector: "env!=test"
)
puts "  Count: #{negation.items.length}"

# Field selector — only Running pods
puts "\nOnly Running pods:"
field = core_client.list_namespaced_pod(
  "default",
  field_selector: "status.phase=Running"
)
puts "  Count: #{field.items.length}"
field.items.each { |p| puts "    - #{p.metadata.name}" }

# Combined label + field selector
puts "\nRunning pods with app=nginx:"
combined = core_client.list_namespaced_pod(
  "default",
  label_selector: "app=nginx",
  field_selector: "status.phase=Running"
)
puts "  Count: #{combined.items.length}"

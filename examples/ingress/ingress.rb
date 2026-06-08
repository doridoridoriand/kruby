require "kruby"
require "pp"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
networking_client = Kubernetes::NetworkingV1Api.new(Kubernetes::ApiClient.new(config))

# Create an Ingress
ingress = Kubernetes::V1Ingress.new({
  metadata: {
    name: "nginx-ingress",
    namespace: "default",
  },
  spec: {
    ingress_class_name: "nginx",
    rules: [
      {
        host: "example.com",
        http: {
          paths: [
            {
              path: "/",
              path_type: "Prefix",
              backend: {
                service: {
                  name: "my-service",
                  port: { number: 80 },
                },
              },
            },
            {
              path: "/api",
              path_type: "Prefix",
              backend: {
                service: {
                  name: "api-service",
                  port: { number: 8080 },
                },
              },
            },
          ],
        },
      },
    ],
  },
})

puts "Creating Ingress..."
result = networking_client.create_namespaced_ingress("default", ingress)
puts "Created: #{result.metadata.name}"

# Get
puts "\nReading Ingress..."
pp networking_client.read_namespaced_ingress("nginx-ingress", "default")

# List
puts "\nListing Ingresses..."
pp networking_client.list_namespaced_ingress("default")

# Delete
puts "\nDeleting Ingress..."
pp networking_client.delete_namespaced_ingress("nginx-ingress", "default")

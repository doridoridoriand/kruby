require "kruby"
require "pp"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
apiextensions_client = Kubernetes::ApiExtensionsV1Api.new(Kubernetes::ApiClient.new(config))
custom_objects_client = Kubernetes::CustomObjectsApi.new(Kubernetes::ApiClient.new(config))

group = "example.com"
version = "v1"
plural = "crontasks"
namespace = "default"

# 1. Create a CRD
crd = Kubernetes::V1CustomResourceDefinition.new({
  metadata: { name: "crontasks.example.com" },
  spec: {
    group: group,
    names: {
      plural: plural,
      singular: "crontask",
      kind: "CronTask",
      short_names: ["ct"],
    },
    scope: "Namespaced",
    versions: [
      {
        name: version,
        served: true,
        storage: true,
        schema: {
          open_api_v3_schema: {
            type: "object",
            properties: {
              spec: {
                type: "object",
                properties: {
                  schedule: { type: "string" },
                  image: { type: "string" },
                },
                required: ["schedule", "image"],
              },
              status: {
                type: "object",
                properties: {
                  last_schedule: { type: "string" },
                },
              },
            },
          },
        },
      },
    ],
  },
})

puts "Creating CRD..."
apiextensions_client.create_custom_resource_definition(crd)
puts "Created CRD: crontasks.example.com"

# Wait for CRD to be ready (the API server needs time to register the new resource)
puts "Waiting for CRD to be established..."
sleep 5

# 2. Create a CustomResource
custom_resource = {
  apiVersion: "#{group}/#{version}",
  kind: "CronTask",
  metadata: {
    name: "my-cron-task",
    namespace: namespace,
  },
  spec: {
    schedule: "*/1 * * * *",
    image: "busybox:1.36",
  },
}

puts "\nCreating CustomResource..."
result = custom_objects_client.create_namespaced_custom_object(
  group, version, namespace, plural, custom_resource, "my-cron-task"
)
pp result

# 3. List CustomResources
puts "\nListing CustomResources..."
pp custom_objects_client.list_namespaced_custom_object(
  group, version, namespace, plural
)

# 4. Delete CustomResource
puts "\nDeleting CustomResource..."
custom_objects_client.delete_namespaced_custom_object(
  group, version, namespace, plural, "my-cron-task"
)

# 5. Delete CRD
puts "\nDeleting CRD..."
apiextensions_client.delete_custom_resource_definition("crontasks.example.com")

require "kruby"
require "pp"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
apiextensions_client = Kubernetes::ApiextensionsV1Api.new(Kubernetes::ApiClient.new(config))
custom_objects_client = Kubernetes::CustomObjectsApi.new(Kubernetes::ApiClient.new(config))

group = "example.com"
version = "v1"
plural = "crontasks"
namespace = "default"
crd_name = "crontasks.example.com"
custom_resource_name = "my-cron-task"

def api_call(description, ignore_codes: [])
  yield
rescue Kubernetes::ApiError => e
  if ignore_codes.include?(e.code.to_i)
    puts "#{description}: #{e.code} (continuing)"
    nil
  else
    warn "#{description} failed: #{e.code} #{e.message}"
    raise
  end
end

def crd_established?(crd)
  Array(crd.status&.conditions).any? do |condition|
    condition.type == "Established" && condition.status == "True"
  end
end

def wait_for_crd_established(client, name, timeout: 60)
  deadline = Time.now + timeout

  loop do
    crd = client.read_custom_resource_definition(name)
    return crd if crd_established?(crd)

    raise "Timed out waiting for #{name} to become Established" if Time.now >= deadline

    sleep 1
  end
end

# 1. Create a CRD
crd = Kubernetes::V1CustomResourceDefinition.new({
  metadata: { name: crd_name },
  spec: {
    group: group,
    names: {
      plural: plural,
      singular: "crontask",
      kind: "CronTask",
      "shortNames" => ["ct"],
    },
    scope: "Namespaced",
    versions: [
      {
        name: version,
        served: true,
        storage: true,
        schema: {
          "openAPIV3Schema" => {
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
                  "lastSchedule" => { type: "string" },
                },
              },
            },
          },
        },
      },
    ],
  },
})

begin
  puts "Creating CRD..."
  api_call("Creating CRD", ignore_codes: [409]) do
    apiextensions_client.create_custom_resource_definition(crd)
  end
  puts "Created CRD: #{crd_name}"

  puts "Waiting for CRD to be established..."
  wait_for_crd_established(apiextensions_client, crd_name)

  # 2. Create a CustomResource
  custom_resource = {
    apiVersion: "#{group}/#{version}",
    kind: "CronTask",
    metadata: {
      name: custom_resource_name,
      namespace: namespace,
    },
    spec: {
      schedule: "*/1 * * * *",
      image: "busybox:1.36",
    },
  }

  puts "\nCreating CustomResource..."
  result = api_call("Creating CustomResource", ignore_codes: [409]) do
    custom_objects_client.create_namespaced_custom_object(
      group, version, namespace, plural, custom_resource, {}
    )
  end
  pp result if result

  # 3. List CustomResources
  puts "\nListing CustomResources..."
  pp api_call("Listing CustomResources") {
    custom_objects_client.list_namespaced_custom_object(
      group, version, namespace, plural
    )
  }

  # 4. Delete CustomResource
  puts "\nDeleting CustomResource..."
  api_call("Deleting CustomResource", ignore_codes: [404]) do
    custom_objects_client.delete_namespaced_custom_object(
      group, version, namespace, plural, custom_resource_name
    )
  end
ensure
  # 5. Delete CRD
  puts "\nDeleting CRD..."
  api_call("Deleting CRD", ignore_codes: [404]) do
    apiextensions_client.delete_custom_resource_definition(crd_name)
  end
end

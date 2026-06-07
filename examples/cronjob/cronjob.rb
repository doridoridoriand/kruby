require "kruby"
require "pp"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
batch_client = Kubernetes::BatchV1Api.new(Kubernetes::ApiClient.new(config))

# Create a CronJob
cron_job = Kubernetes::V1CronJob.new({
  metadata: {
    name: "hello-cron",
    namespace: "default",
  },
  spec: {
    schedule: "*/1 * * * *",  # every minute
    job_template: {
      spec: {
        template: {
          spec: {
            containers: [
              {
                name: "hello",
                image: "busybox:1.36",
                image_pull_policy: "IfNotPresent",
                command: ["sh", "-c", "echo Hello from Kubernetes; date"],
              },
            ],
            restart_policy: "OnFailure",
          },
        },
      },
    },
    concurrency_policy: "Forbid",
  },
})

puts "Creating CronJob..."
result = batch_client.create_namespaced_cron_job("default", cron_job)
puts "Created: #{result.metadata.name} (schedule: #{result.spec.schedule})"
sleep 3

# Get
puts "\nReading CronJob..."
pp batch_client.read_namespaced_cron_job("hello-cron", "default")
sleep 3

# List
puts "\nListing CronJobs..."
pp batch_client.list_namespaced_cron_job("default")
sleep 3

# List Jobs created by the CronJob
puts "\nListing Jobs in namespace..."
jobs = batch_client.list_namespaced_job("default")
owned_jobs = jobs.items.select do |job|
  Array(job.metadata.owner_references).any? do |owner|
    owner.kind == "CronJob" && owner.name == result.metadata.name
  end
end
puts "Found #{owned_jobs.length} jobs created by #{result.metadata.name}"

# Delete
puts "\nDeleting CronJob..."
pp batch_client.delete_namespaced_cron_job("hello-cron", "default")

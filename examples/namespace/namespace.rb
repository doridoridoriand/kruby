
require 'kruby'
require 'pp'

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV['KUBECONFIG'], client_configuration: config)
client = Kubernetes::CoreV1Api.new(Kubernetes::ApiClient.new(config))

name = 'temp'

namespace = Kubernetes::V1Namespace.new({
    kind: 'Namespace',
    metadata: {
        name: name,
    },
})

pp client.create_namespace(namespace)
sleep 3

pp client.list_namespace
sleep 3

pp client.delete_namespace(name)

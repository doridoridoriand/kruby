require 'kruby'
require 'pp'

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV['KUBECONFIG'], client_configuration: config)
client = Kubernetes::CoreV1Api.new(Kubernetes::ApiClient.new(config))

pp client.list_namespaced_pod('default')

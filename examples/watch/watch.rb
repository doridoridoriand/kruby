# Copyright 2019 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "kruby"
require "pp"

config = Kubernetes::Configuration.default_config
Kubernetes.load_kube_config(ENV["KUBECONFIG"], client_configuration: config)
client = Kubernetes::ApiClient.new(config)

watch = Kubernetes::Watch.new(client)
watch_timeout_seconds = [Integer(ENV.fetch("WATCH_TIMEOUT_SECONDS", "10")), 1].max

Signal.trap("INT") { exit!(0) }
Signal.trap("TERM") { exit!(0) }

puts "Watching namespaces for #{watch_timeout_seconds} seconds..."

watch.connect("/api/v1/namespaces?timeoutSeconds=#{watch_timeout_seconds}") do |obj|
  pp obj
end

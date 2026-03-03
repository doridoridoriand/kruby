# Kubernetes::V1ReplicaSetSpec

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **min_ready_seconds** | **Integer** | Minimum number of seconds for which a newly created pod should be ready without any of its container crashing, for it to be considered available. Defaults to 0 (pod will be considered available as soon as it is ready) | [optional] |
| **replicas** | **Integer** | Replicas is the number of desired pods. This is a pointer to distinguish between explicit zero and unspecified. Defaults to 1. More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicaset | [optional] |
| **selector** | [**V1LabelSelector**](V1LabelSelector.md) |  |  |
| **template** | [**V1PodTemplateSpec**](V1PodTemplateSpec.md) |  | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1ReplicaSetSpec.new(
  min_ready_seconds: null,
  replicas: null,
  selector: null,
  template: null
)
```


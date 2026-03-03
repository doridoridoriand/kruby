# Kubernetes::V1alpha1PodGroup

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **name** | **String** | Name is a unique identifier for the PodGroup within the Workload. It must be a DNS label. This field is immutable. |  |
| **policy** | [**V1alpha1PodGroupPolicy**](V1alpha1PodGroupPolicy.md) |  |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1alpha1PodGroup.new(
  name: null,
  policy: null
)
```


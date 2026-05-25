# Kubernetes::V1alpha2PodGroupSchedulingPolicy

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **basic** | **Object** | Basic specifies that the pods in this group should be scheduled using standard Kubernetes scheduling behavior. | [optional] |
| **gang** | [**V1alpha2GangSchedulingPolicy**](V1alpha2GangSchedulingPolicy.md) |  | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1alpha2PodGroupSchedulingPolicy.new(
  basic: null,
  gang: null
)
```


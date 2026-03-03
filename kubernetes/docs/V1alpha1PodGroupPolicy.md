# Kubernetes::V1alpha1PodGroupPolicy

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **basic** | **Object** | Basic specifies that the pods in this group should be scheduled using standard Kubernetes scheduling behavior. | [optional] |
| **gang** | [**V1alpha1GangSchedulingPolicy**](V1alpha1GangSchedulingPolicy.md) |  | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1alpha1PodGroupPolicy.new(
  basic: null,
  gang: null
)
```


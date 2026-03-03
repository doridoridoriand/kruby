# Kubernetes::V1PodFailurePolicyOnPodConditionsPattern

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **status** | **String** | Specifies the required Pod condition status. To match a pod condition it is required that the specified status equals the pod condition status. Defaults to True. | [optional] |
| **type** | **String** | Specifies the required Pod condition type. To match a pod condition it is required that specified type equals the pod condition type. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1PodFailurePolicyOnPodConditionsPattern.new(
  status: null,
  type: null
)
```


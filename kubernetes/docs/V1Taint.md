# Kubernetes::V1Taint

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **effect** | **String** | Required. The effect of the taint on pods that do not tolerate the taint. Valid effects are NoSchedule, PreferNoSchedule and NoExecute. |  |
| **key** | **String** | Required. The taint key to be applied to a node. |  |
| **time_added** | **Time** | TimeAdded represents the time at which the taint was added. | [optional] |
| **value** | **String** | The taint value corresponding to the taint key. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1Taint.new(
  effect: null,
  key: null,
  time_added: null,
  value: null
)
```


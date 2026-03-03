# Kubernetes::V1beta2DeviceCapacity

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **request_policy** | [**V1beta2CapacityRequestPolicy**](V1beta2CapacityRequestPolicy.md) |  | [optional] |
| **value** | **String** | Value defines how much of a certain capacity that device has.  This field reflects the fixed total capacity and does not change. The consumed amount is tracked separately by scheduler and does not affect this value. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1beta2DeviceCapacity.new(
  request_policy: null,
  value: null
)
```


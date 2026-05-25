# Kubernetes::V1beta2DeviceTaintRuleSpec

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **device_selector** | [**V1beta2DeviceTaintSelector**](V1beta2DeviceTaintSelector.md) |  | [optional] |
| **taint** | [**V1beta2DeviceTaint**](V1beta2DeviceTaint.md) |  |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1beta2DeviceTaintRuleSpec.new(
  device_selector: null,
  taint: null
)
```


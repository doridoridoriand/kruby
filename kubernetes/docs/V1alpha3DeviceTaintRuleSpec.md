# Kubernetes::V1alpha3DeviceTaintRuleSpec

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **device_selector** | [**V1alpha3DeviceTaintSelector**](V1alpha3DeviceTaintSelector.md) |  | [optional] |
| **taint** | [**V1alpha3DeviceTaint**](V1alpha3DeviceTaint.md) |  |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1alpha3DeviceTaintRuleSpec.new(
  device_selector: null,
  taint: null
)
```


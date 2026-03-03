# Kubernetes::V1ServiceCIDRStatus

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **conditions** | [**Array&lt;V1Condition&gt;**](V1Condition.md) | conditions holds an array of metav1.Condition that describe the state of the ServiceCIDR. Current service state | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1ServiceCIDRStatus.new(
  conditions: null
)
```


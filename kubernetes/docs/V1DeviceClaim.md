# Kubernetes::V1DeviceClaim

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **config** | [**Array&lt;V1DeviceClaimConfiguration&gt;**](V1DeviceClaimConfiguration.md) | This field holds configuration for multiple potential drivers which could satisfy requests in this claim. It is ignored while allocating the claim. | [optional] |
| **constraints** | [**Array&lt;V1DeviceConstraint&gt;**](V1DeviceConstraint.md) | These constraints must be satisfied by the set of devices that get allocated for the claim. | [optional] |
| **requests** | [**Array&lt;V1DeviceRequest&gt;**](V1DeviceRequest.md) | Requests represent individual requests for distinct devices which must all be satisfied. If empty, nothing needs to be allocated. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1DeviceClaim.new(
  config: null,
  constraints: null,
  requests: null
)
```


# Kubernetes::V1beta1DeviceClaim

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **config** | [**Array&lt;V1beta1DeviceClaimConfiguration&gt;**](V1beta1DeviceClaimConfiguration.md) | This field holds configuration for multiple potential drivers which could satisfy requests in this claim. It is ignored while allocating the claim. | [optional] |
| **constraints** | [**Array&lt;V1beta1DeviceConstraint&gt;**](V1beta1DeviceConstraint.md) | These constraints must be satisfied by the set of devices that get allocated for the claim. | [optional] |
| **requests** | [**Array&lt;V1beta1DeviceRequest&gt;**](V1beta1DeviceRequest.md) | Requests represent individual requests for distinct devices which must all be satisfied. If empty, nothing needs to be allocated. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1beta1DeviceClaim.new(
  config: null,
  constraints: null,
  requests: null
)
```


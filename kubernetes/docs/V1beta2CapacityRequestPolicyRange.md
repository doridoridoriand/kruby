# Kubernetes::V1beta2CapacityRequestPolicyRange

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **max** | **String** | Max defines the upper limit for capacity that can be requested.  Max must be less than or equal to the capacity value. Min and requestPolicy.default must be less than or equal to the maximum. | [optional] |
| **min** | **String** | Min specifies the minimum capacity allowed for a consumption request.  Min must be greater than or equal to zero, and less than or equal to the capacity value. requestPolicy.default must be more than or equal to the minimum. |  |
| **step** | **String** | Step defines the step size between valid capacity amounts within the range.  Max (if set) and requestPolicy.default must be a multiple of Step. Min + Step must be less than or equal to the capacity value. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1beta2CapacityRequestPolicyRange.new(
  max: null,
  min: null,
  step: null
)
```


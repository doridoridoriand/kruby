# Kubernetes::V1beta2AllocationResult

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **allocation_timestamp** | **Time** | AllocationTimestamp stores the time when the resources were allocated. This field is not guaranteed to be set, in which case that time is unknown.  This is an alpha field and requires enabling the DRADeviceBindingConditions and DRAResourceClaimDeviceStatus feature gate. | [optional] |
| **devices** | [**V1beta2DeviceAllocationResult**](V1beta2DeviceAllocationResult.md) |  | [optional] |
| **node_selector** | [**V1NodeSelector**](V1NodeSelector.md) |  | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1beta2AllocationResult.new(
  allocation_timestamp: null,
  devices: null,
  node_selector: null
)
```


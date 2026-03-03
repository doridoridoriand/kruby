# Kubernetes::V1Device

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **all_nodes** | **Boolean** | AllNodes indicates that all nodes have access to the device.  Must only be set if Spec.PerDeviceNodeSelection is set to true. At most one of NodeName, NodeSelector and AllNodes can be set. | [optional] |
| **allow_multiple_allocations** | **Boolean** | AllowMultipleAllocations marks whether the device is allowed to be allocated to multiple DeviceRequests.  If AllowMultipleAllocations is set to true, the device can be allocated more than once, and all of its capacity is consumable, regardless of whether the requestPolicy is defined or not. | [optional] |
| **attributes** | [**Hash&lt;String, V1DeviceAttribute&gt;**](V1DeviceAttribute.md) | Attributes defines the set of attributes for this device. The name of each attribute must be unique in that set.  The maximum number of attributes and capacities combined is 32. | [optional] |
| **binding_conditions** | **Array&lt;String&gt;** | BindingConditions defines the conditions for proceeding with binding. All of these conditions must be set in the per-device status conditions with a value of True to proceed with binding the pod to the node while scheduling the pod.  The maximum number of binding conditions is 4.  The conditions must be a valid condition type string.  This is an alpha field and requires enabling the DRADeviceBindingConditions and DRAResourceClaimDeviceStatus feature gates. | [optional] |
| **binding_failure_conditions** | **Array&lt;String&gt;** | BindingFailureConditions defines the conditions for binding failure. They may be set in the per-device status conditions. If any is set to \&quot;True\&quot;, a binding failure occurred.  The maximum number of binding failure conditions is 4.  The conditions must be a valid condition type string.  This is an alpha field and requires enabling the DRADeviceBindingConditions and DRAResourceClaimDeviceStatus feature gates. | [optional] |
| **binds_to_node** | **Boolean** | BindsToNode indicates if the usage of an allocation involving this device has to be limited to exactly the node that was chosen when allocating the claim. If set to true, the scheduler will set the ResourceClaim.Status.Allocation.NodeSelector to match the node where the allocation was made.  This is an alpha field and requires enabling the DRADeviceBindingConditions and DRAResourceClaimDeviceStatus feature gates. | [optional] |
| **capacity** | [**Hash&lt;String, V1DeviceCapacity&gt;**](V1DeviceCapacity.md) | Capacity defines the set of capacities for this device. The name of each capacity must be unique in that set.  The maximum number of attributes and capacities combined is 32. | [optional] |
| **consumes_counters** | [**Array&lt;V1DeviceCounterConsumption&gt;**](V1DeviceCounterConsumption.md) | ConsumesCounters defines a list of references to sharedCounters and the set of counters that the device will consume from those counter sets.  There can only be a single entry per counterSet.  The maximum number of device counter consumptions per device is 2. | [optional] |
| **name** | **String** | Name is unique identifier among all devices managed by the driver in the pool. It must be a DNS label. |  |
| **node_name** | **String** | NodeName identifies the node where the device is available.  Must only be set if Spec.PerDeviceNodeSelection is set to true. At most one of NodeName, NodeSelector and AllNodes can be set. | [optional] |
| **node_selector** | [**V1NodeSelector**](V1NodeSelector.md) |  | [optional] |
| **taints** | [**Array&lt;V1DeviceTaint&gt;**](V1DeviceTaint.md) | If specified, these are the driver-defined taints.  The maximum number of taints is 16. If taints are set for any device in a ResourceSlice, then the maximum number of allowed devices per ResourceSlice is 64 instead of 128.  This is an alpha field and requires enabling the DRADeviceTaints feature gate. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1Device.new(
  all_nodes: null,
  allow_multiple_allocations: null,
  attributes: null,
  binding_conditions: null,
  binding_failure_conditions: null,
  binds_to_node: null,
  capacity: null,
  consumes_counters: null,
  name: null,
  node_name: null,
  node_selector: null,
  taints: null
)
```


# Kubernetes::V1alpha2PodGroupTemplate

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **disruption_mode** | **String** | DisruptionMode defines the mode in which a given PodGroup can be disrupted. One of Pod, PodGroup. This field is available only when the WorkloadAwarePreemption feature gate is enabled. | [optional] |
| **name** | **String** | Name is a unique identifier for the PodGroupTemplate within the Workload. It must be a DNS label. This field is immutable. |  |
| **priority** | **Integer** | Priority is the value of priority of pod groups created from this template. Various system components use this field to find the priority of the pod group. When Priority Admission Controller is enabled, it prevents users from setting this field. The admission controller populates this field from PriorityClassName. The higher the value, the higher the priority. This field is available only when the WorkloadAwarePreemption feature gate is enabled. | [optional] |
| **priority_class_name** | **String** | PriorityClassName indicates the priority that should be considered when scheduling a pod group created from this template. If no priority class is specified, admission control can set this to the global default priority class if it exists. Otherwise, pod groups created from this template will have the priority set to zero. This field is available only when the WorkloadAwarePreemption feature gate is enabled. | [optional] |
| **resource_claims** | [**Array&lt;V1alpha2PodGroupResourceClaim&gt;**](V1alpha2PodGroupResourceClaim.md) | ResourceClaims defines which ResourceClaims may be shared among Pods in the group. Pods consume the devices allocated to a PodGroup&#39;s claim by defining a claim in its own Spec.ResourceClaims that matches the PodGroup&#39;s claim exactly. The claim must have the same name and refer to the same ResourceClaim or ResourceClaimTemplate.  This is an alpha-level field and requires that the DRAWorkloadResourceClaims feature gate is enabled.  This field is immutable. | [optional] |
| **scheduling_constraints** | [**V1alpha2PodGroupSchedulingConstraints**](V1alpha2PodGroupSchedulingConstraints.md) |  | [optional] |
| **scheduling_policy** | [**V1alpha2PodGroupSchedulingPolicy**](V1alpha2PodGroupSchedulingPolicy.md) |  |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1alpha2PodGroupTemplate.new(
  disruption_mode: null,
  name: null,
  priority: null,
  priority_class_name: null,
  resource_claims: null,
  scheduling_constraints: null,
  scheduling_policy: null
)
```


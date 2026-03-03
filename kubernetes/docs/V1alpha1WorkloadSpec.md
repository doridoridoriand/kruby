# Kubernetes::V1alpha1WorkloadSpec

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **controller_ref** | [**V1alpha1TypedLocalObjectReference**](V1alpha1TypedLocalObjectReference.md) |  | [optional] |
| **pod_groups** | [**Array&lt;V1alpha1PodGroup&gt;**](V1alpha1PodGroup.md) | PodGroups is the list of pod groups that make up the Workload. The maximum number of pod groups is 8. This field is immutable. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1alpha1WorkloadSpec.new(
  controller_ref: null,
  pod_groups: null
)
```


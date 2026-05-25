# Kubernetes::V1alpha2WorkloadSpec

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **controller_ref** | [**V1alpha2TypedLocalObjectReference**](V1alpha2TypedLocalObjectReference.md) |  | [optional] |
| **pod_group_templates** | [**Array&lt;V1alpha2PodGroupTemplate&gt;**](V1alpha2PodGroupTemplate.md) | PodGroupTemplates is the list of templates that make up the Workload. The maximum number of templates is 8. This field is immutable. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1alpha2WorkloadSpec.new(
  controller_ref: null,
  pod_group_templates: null
)
```


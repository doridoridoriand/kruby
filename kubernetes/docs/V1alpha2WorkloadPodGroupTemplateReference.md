# Kubernetes::V1alpha2WorkloadPodGroupTemplateReference

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **pod_group_template_name** | **String** | PodGroupTemplateName defines the PodGroupTemplate name within the Workload object. |  |
| **workload_name** | **String** | WorkloadName defines the name of the Workload object. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1alpha2WorkloadPodGroupTemplateReference.new(
  pod_group_template_name: null,
  workload_name: null
)
```


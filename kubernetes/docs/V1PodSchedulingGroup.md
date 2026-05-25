# Kubernetes::V1PodSchedulingGroup

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **pod_group_name** | **String** | PodGroupName specifies the name of the standalone PodGroup object that represents the runtime instance of this group. Must be a DNS subdomain. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1PodSchedulingGroup.new(
  pod_group_name: null
)
```


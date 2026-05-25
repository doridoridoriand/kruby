# Kubernetes::V1alpha2TopologyConstraint

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **key** | **String** | Key specifies the key of the node label representing the topology domain. All pods within the PodGroup must be colocated within the same domain instance. Different PodGroups can land on different domain instances even if they derive from the same PodGroupTemplate. Examples: \&quot;topology.kubernetes.io/rack\&quot; |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1alpha2TopologyConstraint.new(
  key: null
)
```


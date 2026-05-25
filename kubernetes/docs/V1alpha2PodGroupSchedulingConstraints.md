# Kubernetes::V1alpha2PodGroupSchedulingConstraints

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **topology** | [**Array&lt;V1alpha2TopologyConstraint&gt;**](V1alpha2TopologyConstraint.md) | Topology defines the topology constraints for the pod group. Currently only a single topology constraint can be specified. This may change in the future. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1alpha2PodGroupSchedulingConstraints.new(
  topology: null
)
```


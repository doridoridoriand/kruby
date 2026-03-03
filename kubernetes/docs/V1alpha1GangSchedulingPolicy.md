# Kubernetes::V1alpha1GangSchedulingPolicy

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **min_count** | **Integer** | MinCount is the minimum number of pods that must be schedulable or scheduled at the same time for the scheduler to admit the entire group. It must be a positive integer. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1alpha1GangSchedulingPolicy.new(
  min_count: null
)
```


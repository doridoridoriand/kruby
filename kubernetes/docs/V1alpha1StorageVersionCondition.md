# Kubernetes::V1alpha1StorageVersionCondition

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **last_transition_time** | **Time** | lastTransitionTime is the last time the condition transitioned from one status to another. | [optional] |
| **message** | **String** | message is a human readable string indicating details about the transition. |  |
| **observed_generation** | **Integer** | observedGeneration represents the .metadata.generation that the condition was set based upon, if field is set. | [optional] |
| **reason** | **String** | reason for the condition&#39;s last transition. |  |
| **status** | **String** | status of the condition, one of True, False, Unknown. |  |
| **type** | **String** | type of the condition. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1alpha1StorageVersionCondition.new(
  last_transition_time: null,
  message: null,
  observed_generation: null,
  reason: null,
  status: null,
  type: null
)
```


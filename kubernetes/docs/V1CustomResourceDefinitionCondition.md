# Kubernetes::V1CustomResourceDefinitionCondition

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **last_transition_time** | **Time** | lastTransitionTime last time the condition transitioned from one status to another. | [optional] |
| **message** | **String** | message is a human-readable message indicating details about last transition. | [optional] |
| **observed_generation** | **Integer** | observedGeneration represents the .metadata.generation that the condition was set based upon. For instance, if .metadata.generation is currently 12, but the .status.conditions[x].observedGeneration is 9, the condition is out of date with respect to the current state of the instance. | [optional] |
| **reason** | **String** | reason is a unique, one-word, CamelCase reason for the condition&#39;s last transition. | [optional] |
| **status** | **String** | status is the status of the condition. Can be True, False, Unknown. |  |
| **type** | **String** | type is the type of the condition. Types include Established, NamesAccepted and Terminating. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1CustomResourceDefinitionCondition.new(
  last_transition_time: null,
  message: null,
  observed_generation: null,
  reason: null,
  status: null,
  type: null
)
```


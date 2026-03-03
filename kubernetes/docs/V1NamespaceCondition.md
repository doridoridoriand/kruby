# Kubernetes::V1NamespaceCondition

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **last_transition_time** | **Time** | Last time the condition transitioned from one status to another. | [optional] |
| **message** | **String** | Human-readable message indicating details about last transition. | [optional] |
| **reason** | **String** | Unique, one-word, CamelCase reason for the condition&#39;s last transition. | [optional] |
| **status** | **String** | Status of the condition, one of True, False, Unknown. |  |
| **type** | **String** | Type of namespace controller condition. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1NamespaceCondition.new(
  last_transition_time: null,
  message: null,
  reason: null,
  status: null,
  type: null
)
```


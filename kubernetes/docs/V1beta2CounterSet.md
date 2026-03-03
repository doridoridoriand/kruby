# Kubernetes::V1beta2CounterSet

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **counters** | [**Hash&lt;String, V1beta2Counter&gt;**](V1beta2Counter.md) | Counters defines the set of counters for this CounterSet The name of each counter must be unique in that set and must be a DNS label.  The maximum number of counters is 32. |  |
| **name** | **String** | Name defines the name of the counter set. It must be a DNS label. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1beta2CounterSet.new(
  counters: null,
  name: null
)
```


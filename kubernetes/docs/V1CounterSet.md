# Kubernetes::V1CounterSet

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **counters** | [**Hash&lt;String, V1Counter&gt;**](V1Counter.md) | Counters defines the set of counters for this CounterSet The name of each counter must be unique in that set and must be a DNS label.  The maximum number of counters is 32. |  |
| **name** | **String** | Name defines the name of the counter set. It must be a DNS label. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1CounterSet.new(
  counters: null,
  name: null
)
```


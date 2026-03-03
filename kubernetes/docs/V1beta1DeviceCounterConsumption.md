# Kubernetes::V1beta1DeviceCounterConsumption

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **counter_set** | **String** | CounterSet is the name of the set from which the counters defined will be consumed. |  |
| **counters** | [**Hash&lt;String, V1beta1Counter&gt;**](V1beta1Counter.md) | Counters defines the counters that will be consumed by the device.  The maximum number of counters is 32. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1beta1DeviceCounterConsumption.new(
  counter_set: null,
  counters: null
)
```


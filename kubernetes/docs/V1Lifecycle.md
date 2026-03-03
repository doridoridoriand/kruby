# Kubernetes::V1Lifecycle

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **post_start** | [**V1LifecycleHandler**](V1LifecycleHandler.md) |  | [optional] |
| **pre_stop** | [**V1LifecycleHandler**](V1LifecycleHandler.md) |  | [optional] |
| **stop_signal** | **String** | StopSignal defines which signal will be sent to a container when it is being stopped. If not specified, the default is defined by the container runtime in use. StopSignal can only be set for Pods with a non-empty .spec.os.name | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1Lifecycle.new(
  post_start: null,
  pre_stop: null,
  stop_signal: null
)
```


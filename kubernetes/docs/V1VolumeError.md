# Kubernetes::V1VolumeError

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **error_code** | **Integer** | errorCode is a numeric gRPC code representing the error encountered during Attach or Detach operations.  This is an optional, beta field that requires the MutableCSINodeAllocatableCount feature gate being enabled to be set. | [optional] |
| **message** | **String** | message represents the error encountered during Attach or Detach operation. This string may be logged, so it should not contain sensitive information. | [optional] |
| **time** | **Time** | time represents the time the error was encountered. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1VolumeError.new(
  error_code: null,
  message: null,
  time: null
)
```


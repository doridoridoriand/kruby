# Kubernetes::V1TokenRequestStatus

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **expiration_timestamp** | **Time** | expirationTimestamp is the time of expiration of the returned token. | [optional] |
| **token** | **String** | token is the opaque bearer token. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1TokenRequestStatus.new(
  expiration_timestamp: null,
  token: null
)
```


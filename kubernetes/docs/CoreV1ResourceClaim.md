# Kubernetes::CoreV1ResourceClaim

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **name** | **String** | Name must match the name of one entry in pod.spec.resourceClaims of the Pod where this field is used. It makes that resource available inside a container. |  |
| **request** | **String** | Request is the name chosen for a request in the referenced claim. If empty, everything from the claim is made available, otherwise only the result of this request. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::CoreV1ResourceClaim.new(
  name: null,
  request: null
)
```


# Kubernetes::V1ResourceClaimConsumerReference

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **api_group** | **String** | APIGroup is the group for the resource being referenced. It is empty for the core API. This matches the group in the APIVersion that is used when creating the resources. | [optional] |
| **name** | **String** | Name is the name of resource being referenced. |  |
| **resource** | **String** | Resource is the type of resource being referenced, for example \&quot;pods\&quot;. |  |
| **uid** | **String** | UID identifies exactly one incarnation of the resource. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1ResourceClaimConsumerReference.new(
  api_group: null,
  name: null,
  resource: null,
  uid: null
)
```


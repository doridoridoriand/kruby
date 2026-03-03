# Kubernetes::V1ParentReference

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | Group is the group of the object being referenced. | [optional] |
| **name** | **String** | Name is the name of the object being referenced. |  |
| **namespace** | **String** | Namespace is the namespace of the object being referenced. | [optional] |
| **resource** | **String** | Resource is the resource of the object being referenced. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1ParentReference.new(
  group: null,
  name: null,
  namespace: null,
  resource: null
)
```


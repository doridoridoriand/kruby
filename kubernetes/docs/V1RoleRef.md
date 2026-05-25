# Kubernetes::V1RoleRef

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **api_group** | **String** | APIGroup is the group for the resource being referenced | [optional] |
| **kind** | **String** | Kind is the type of resource being referenced |  |
| **name** | **String** | Name is the name of resource being referenced |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1RoleRef.new(
  api_group: null,
  kind: null,
  name: null
)
```


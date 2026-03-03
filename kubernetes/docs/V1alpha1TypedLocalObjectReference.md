# Kubernetes::V1alpha1TypedLocalObjectReference

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **api_group** | **String** | APIGroup is the group for the resource being referenced. If APIGroup is empty, the specified Kind must be in the core API group. For any other third-party types, setting APIGroup is required. It must be a DNS subdomain. | [optional] |
| **kind** | **String** | Kind is the type of resource being referenced. It must be a path segment name. |  |
| **name** | **String** | Name is the name of resource being referenced. It must be a path segment name. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1alpha1TypedLocalObjectReference.new(
  api_group: null,
  kind: null,
  name: null
)
```


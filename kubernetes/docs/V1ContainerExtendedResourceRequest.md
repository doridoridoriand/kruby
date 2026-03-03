# Kubernetes::V1ContainerExtendedResourceRequest

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **container_name** | **String** | The name of the container requesting resources. |  |
| **request_name** | **String** | The name of the request in the special ResourceClaim which corresponds to the extended resource. |  |
| **resource_name** | **String** | The name of the extended resource in that container which gets backed by DRA. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1ContainerExtendedResourceRequest.new(
  container_name: null,
  request_name: null,
  resource_name: null
)
```


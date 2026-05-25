# Kubernetes::V1NodeAllocatableResourceClaimStatus

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **containers** | **Array&lt;String&gt;** | Containers lists the names of all containers in this pod that reference the claim. | [optional] |
| **resource_claim_name** | **String** | ResourceClaimName is the resource claim referenced by the pod that resulted in this node allocatable resource allocation. |  |
| **resources** | **Hash&lt;String, String&gt;** | Resources is a map of the node-allocatable resource name to the aggregate quantity allocated to the claim. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1NodeAllocatableResourceClaimStatus.new(
  containers: null,
  resource_claim_name: null,
  resources: null
)
```


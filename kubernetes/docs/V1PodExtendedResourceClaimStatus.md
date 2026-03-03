# Kubernetes::V1PodExtendedResourceClaimStatus

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **request_mappings** | [**Array&lt;V1ContainerExtendedResourceRequest&gt;**](V1ContainerExtendedResourceRequest.md) | RequestMappings identifies the mapping of &lt;container, extended resource backed by DRA&gt; to  device request in the generated ResourceClaim. |  |
| **resource_claim_name** | **String** | ResourceClaimName is the name of the ResourceClaim that was generated for the Pod in the namespace of the Pod. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1PodExtendedResourceClaimStatus.new(
  request_mappings: null,
  resource_claim_name: null
)
```


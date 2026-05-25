# Kubernetes::V1alpha2PodGroupResourceClaimStatus

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **name** | **String** | Name uniquely identifies this resource claim inside the PodGroup. This must match the name of an entry in podgroup.spec.resourceClaims, which implies that the string must be a DNS_LABEL. |  |
| **resource_claim_name** | **String** | ResourceClaimName is the name of the ResourceClaim that was generated for the PodGroup in the namespace of the PodGroup. If this is unset, then generating a ResourceClaim was not necessary. The podgroup.spec.resourceClaims entry can be ignored in this case. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1alpha2PodGroupResourceClaimStatus.new(
  name: null,
  resource_claim_name: null
)
```


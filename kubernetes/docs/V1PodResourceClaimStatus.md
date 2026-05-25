# Kubernetes::V1PodResourceClaimStatus

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **name** | **String** | Name uniquely identifies this resource claim inside the pod. This must match the name of an entry in pod.spec.resourceClaims, which implies that the string must be a DNS_LABEL. |  |
| **resource_claim_name** | **String** | ResourceClaimName is the name of the ResourceClaim that was generated for the Pod in the namespace of the Pod.  When the DRAWorkloadResourceClaims feature is enabled and the corresponding PodResourceClaim matches a PodGroupResourceClaim made by the Pod&#39;s PodGroup, then this is the name of the ResourceClaim generated and reserved for the PodGroup.  If this is unset, then generating a ResourceClaim was not necessary. The pod.spec.resourceClaims entry can be ignored in this case. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1PodResourceClaimStatus.new(
  name: null,
  resource_claim_name: null
)
```


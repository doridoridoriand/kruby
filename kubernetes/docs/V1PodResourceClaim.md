# Kubernetes::V1PodResourceClaim

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **name** | **String** | Name uniquely identifies this resource claim inside the pod. This must be a DNS_LABEL. |  |
| **resource_claim_name** | **String** | ResourceClaimName is the name of a ResourceClaim object in the same namespace as this pod.  Exactly one of ResourceClaimName and ResourceClaimTemplateName must be set. | [optional] |
| **resource_claim_template_name** | **String** | ResourceClaimTemplateName is the name of a ResourceClaimTemplate object in the same namespace as this pod.  The template will be used to create a new ResourceClaim, which will be bound to this pod. When this pod is deleted, the ResourceClaim will also be deleted. The pod name and resource name, along with a generated component, will be used to form a unique name for the ResourceClaim, which will be recorded in pod.status.resourceClaimStatuses.  When the DRAWorkloadResourceClaims feature gate is enabled and the pod belongs to a PodGroup that defines a PodGroupResourceClaim with the same Name and ResourceClaimTemplateName, this PodResourceClaim resolves to the ResourceClaim generated for the PodGroup. All pods in the group that define an equivalent PodResourceClaim matching the PodGroupResourceClaim&#39;s Name and ResourceClaimTemplateName share the same generated ResourceClaim. ResourceClaims generated for a PodGroup are owned by the PodGroup and their lifecycles are tied to the PodGroup instead of any individual pod.  This field is immutable and no changes will be made to the corresponding ResourceClaim by the control plane after creating the ResourceClaim.  Exactly one of ResourceClaimName and ResourceClaimTemplateName must be set. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1PodResourceClaim.new(
  name: null,
  resource_claim_name: null,
  resource_claim_template_name: null
)
```


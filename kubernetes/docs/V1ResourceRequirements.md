# Kubernetes::V1ResourceRequirements

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **claims** | [**Array&lt;CoreV1ResourceClaim&gt;**](CoreV1ResourceClaim.md) | Claims lists the names of resources, defined in spec.resourceClaims, that are used by this container.  This field depends on the DynamicResourceAllocation feature gate.  This field is immutable. It can only be set for containers. | [optional] |
| **limits** | **Hash&lt;String, String&gt;** | Limits describes the maximum amount of compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ | [optional] |
| **requests** | **Hash&lt;String, String&gt;** | Requests describes the minimum amount of compute resources required. If Requests is omitted for a container, it defaults to Limits if that is explicitly specified, otherwise to an implementation-defined value. Requests cannot exceed Limits. More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1ResourceRequirements.new(
  claims: null,
  limits: null,
  requests: null
)
```


# Kubernetes::V2APISubresourceDiscovery

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **subresource** | **String** | subresource is the name of the subresource. |  |
| **response_kind** | [**IoK8sApimachineryPkgApisMetaV1GroupVersionKind**](IoK8sApimachineryPkgApisMetaV1GroupVersionKind.md) |  | [optional] |
| **accepted_types** | [**Array&lt;IoK8sApimachineryPkgApisMetaV1GroupVersionKind&gt;**](IoK8sApimachineryPkgApisMetaV1GroupVersionKind.md) |  | [optional] |
| **verbs** | **Array&lt;String&gt;** | verbs is a list of supported API operation types |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V2APISubresourceDiscovery.new(
  subresource: null,
  response_kind: null,
  accepted_types: null,
  verbs: null
)
```


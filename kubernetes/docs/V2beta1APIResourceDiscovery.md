# Kubernetes::V2beta1APIResourceDiscovery

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **resource** | **String** | resource is the plural name of the resource. |  |
| **response_kind** | [**IoK8sApimachineryPkgApisMetaV1GroupVersionKind**](IoK8sApimachineryPkgApisMetaV1GroupVersionKind.md) |  | [optional] |
| **scope** | **String** | scope indicates the scope of a resource, either Cluster or Namespaced |  |
| **singular_resource** | **String** | singularResource is the singular name of the resource. |  |
| **verbs** | **Array&lt;String&gt;** | verbs is a list of supported API operation types |  |
| **short_names** | **Array&lt;String&gt;** | shortNames is a list of suggested short names of the resource. | [optional] |
| **categories** | **Array&lt;String&gt;** | categories is a list of the grouped resources this resource belongs to. | [optional] |
| **subresources** | [**Array&lt;V2beta1APISubresourceDiscovery&gt;**](V2beta1APISubresourceDiscovery.md) |  | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V2beta1APIResourceDiscovery.new(
  resource: null,
  response_kind: null,
  scope: null,
  singular_resource: null,
  verbs: null,
  short_names: null,
  categories: null,
  subresources: null
)
```


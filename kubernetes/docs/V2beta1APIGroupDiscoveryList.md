# Kubernetes::V2beta1APIGroupDiscoveryList

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **api_version** | **String** |  | [optional] |
| **kind** | **String** |  | [optional] |
| **metadata** | [**V1ListMeta**](V1ListMeta.md) |  | [optional] |
| **items** | [**Array&lt;V2beta1APIGroupDiscovery&gt;**](V2beta1APIGroupDiscovery.md) |  |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V2beta1APIGroupDiscoveryList.new(
  api_version: null,
  kind: null,
  metadata: null,
  items: null
)
```


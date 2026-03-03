# Kubernetes::V2APIGroupDiscoveryList

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **api_version** | **String** |  | [optional] |
| **kind** | **String** |  | [optional] |
| **metadata** | [**V1ListMeta**](V1ListMeta.md) |  | [optional] |
| **items** | [**Array&lt;V2APIGroupDiscovery&gt;**](V2APIGroupDiscovery.md) |  |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V2APIGroupDiscoveryList.new(
  api_version: null,
  kind: null,
  metadata: null,
  items: null
)
```


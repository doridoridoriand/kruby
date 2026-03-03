# Kubernetes::V2APIGroupDiscovery

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **api_version** | **String** |  | [optional] |
| **kind** | **String** |  | [optional] |
| **metadata** | [**V1ObjectMeta**](V1ObjectMeta.md) |  | [optional] |
| **versions** | [**Array&lt;V2APIVersionDiscovery&gt;**](V2APIVersionDiscovery.md) |  | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V2APIGroupDiscovery.new(
  api_version: null,
  kind: null,
  metadata: null,
  versions: null
)
```


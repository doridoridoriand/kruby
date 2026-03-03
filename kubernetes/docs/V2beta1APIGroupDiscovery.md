# Kubernetes::V2beta1APIGroupDiscovery

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **api_version** | **String** |  | [optional] |
| **kind** | **String** |  | [optional] |
| **metadata** | [**V1ObjectMeta**](V1ObjectMeta.md) |  | [optional] |
| **versions** | [**Array&lt;V2beta1APIVersionDiscovery&gt;**](V2beta1APIVersionDiscovery.md) |  | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V2beta1APIGroupDiscovery.new(
  api_version: null,
  kind: null,
  metadata: null,
  versions: null
)
```


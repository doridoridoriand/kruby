# Kubernetes::V1EndpointHints

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **for_nodes** | [**Array&lt;V1ForNode&gt;**](V1ForNode.md) | forNodes indicates the node(s) this endpoint should be consumed by when using topology aware routing. May contain a maximum of 8 entries. | [optional] |
| **for_zones** | [**Array&lt;V1ForZone&gt;**](V1ForZone.md) | forZones indicates the zone(s) this endpoint should be consumed by when using topology aware routing. May contain a maximum of 8 entries. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1EndpointHints.new(
  for_nodes: null,
  for_zones: null
)
```


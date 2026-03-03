# Kubernetes::V1beta2ResourceClaimTemplateSpec

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **metadata** | [**V1ObjectMeta**](V1ObjectMeta.md) |  | [optional] |
| **spec** | [**V1beta2ResourceClaimSpec**](V1beta2ResourceClaimSpec.md) |  |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1beta2ResourceClaimTemplateSpec.new(
  metadata: null,
  spec: null
)
```


# Kubernetes::V1ResourceClaimTemplateSpec

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **metadata** | [**V1ObjectMeta**](V1ObjectMeta.md) |  | [optional] |
| **spec** | [**V1ResourceClaimSpec**](V1ResourceClaimSpec.md) |  |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1ResourceClaimTemplateSpec.new(
  metadata: null,
  spec: null
)
```


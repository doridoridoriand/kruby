# Kubernetes::V1beta1ResourceClaimTemplateSpec

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **metadata** | [**V1ObjectMeta**](V1ObjectMeta.md) |  | [optional] |
| **spec** | [**V1beta1ResourceClaimSpec**](V1beta1ResourceClaimSpec.md) |  |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1beta1ResourceClaimTemplateSpec.new(
  metadata: null,
  spec: null
)
```


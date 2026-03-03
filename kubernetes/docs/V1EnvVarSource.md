# Kubernetes::V1EnvVarSource

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **config_map_key_ref** | [**V1ConfigMapKeySelector**](V1ConfigMapKeySelector.md) |  | [optional] |
| **field_ref** | [**V1ObjectFieldSelector**](V1ObjectFieldSelector.md) |  | [optional] |
| **file_key_ref** | [**V1FileKeySelector**](V1FileKeySelector.md) |  | [optional] |
| **resource_field_ref** | [**V1ResourceFieldSelector**](V1ResourceFieldSelector.md) |  | [optional] |
| **secret_key_ref** | [**V1SecretKeySelector**](V1SecretKeySelector.md) |  | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1EnvVarSource.new(
  config_map_key_ref: null,
  field_ref: null,
  file_key_ref: null,
  resource_field_ref: null,
  secret_key_ref: null
)
```


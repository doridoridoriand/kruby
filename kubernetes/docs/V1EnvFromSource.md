# Kubernetes::V1EnvFromSource

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **config_map_ref** | [**V1ConfigMapEnvSource**](V1ConfigMapEnvSource.md) |  | [optional] |
| **prefix** | **String** | Optional text to prepend to the name of each environment variable. May consist of any printable ASCII characters except &#39;&#x3D;&#39;. | [optional] |
| **secret_ref** | [**V1SecretEnvSource**](V1SecretEnvSource.md) |  | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1EnvFromSource.new(
  config_map_ref: null,
  prefix: null,
  secret_ref: null
)
```


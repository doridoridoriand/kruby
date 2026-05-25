# Kubernetes::V1Mutation

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **apply_configuration** | [**V1ApplyConfiguration**](V1ApplyConfiguration.md) |  | [optional] |
| **json_patch** | [**V1JSONPatch**](V1JSONPatch.md) |  | [optional] |
| **patch_type** | **String** | patchType indicates the patch strategy used. Allowed values are \&quot;ApplyConfiguration\&quot; and \&quot;JSONPatch\&quot;. Required. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1Mutation.new(
  apply_configuration: null,
  json_patch: null,
  patch_type: null
)
```


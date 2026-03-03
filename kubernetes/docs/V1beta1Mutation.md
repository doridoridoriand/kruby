# Kubernetes::V1beta1Mutation

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **apply_configuration** | [**V1beta1ApplyConfiguration**](V1beta1ApplyConfiguration.md) |  | [optional] |
| **json_patch** | [**V1beta1JSONPatch**](V1beta1JSONPatch.md) |  | [optional] |
| **patch_type** | **String** | patchType indicates the patch strategy used. Allowed values are \&quot;ApplyConfiguration\&quot; and \&quot;JSONPatch\&quot;. Required. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1beta1Mutation.new(
  apply_configuration: null,
  json_patch: null,
  patch_type: null
)
```


# Kubernetes::V1alpha1Mutation

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **apply_configuration** | [**V1alpha1ApplyConfiguration**](V1alpha1ApplyConfiguration.md) |  | [optional] |
| **json_patch** | [**V1alpha1JSONPatch**](V1alpha1JSONPatch.md) |  | [optional] |
| **patch_type** | **String** | patchType indicates the patch strategy used. Allowed values are \&quot;ApplyConfiguration\&quot; and \&quot;JSONPatch\&quot;. Required. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1alpha1Mutation.new(
  apply_configuration: null,
  json_patch: null,
  patch_type: null
)
```


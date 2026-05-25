# Kubernetes::V1VolumeMountStatus

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **mount_path** | **String** | MountPath corresponds to the original VolumeMount. |  |
| **name** | **String** | Name corresponds to the name of the original VolumeMount. |  |
| **read_only** | **Boolean** | ReadOnly corresponds to the original VolumeMount. | [optional] |
| **recursive_read_only** | **String** | RecursiveReadOnly must be set to Disabled, Enabled, or unspecified (for non-readonly mounts). An IfPossible value in the original VolumeMount must be translated to Disabled or Enabled, depending on the mount result. | [optional] |
| **volume_status** | [**V1VolumeStatus**](V1VolumeStatus.md) |  | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1VolumeMountStatus.new(
  mount_path: null,
  name: null,
  read_only: null,
  recursive_read_only: null,
  volume_status: null
)
```


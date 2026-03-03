# Kubernetes::VersionInfo

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **build_date** | **String** |  |  |
| **compiler** | **String** |  |  |
| **emulation_major** | **String** | EmulationMajor is the major version of the emulation version | [optional] |
| **emulation_minor** | **String** | EmulationMinor is the minor version of the emulation version | [optional] |
| **git_commit** | **String** |  |  |
| **git_tree_state** | **String** |  |  |
| **git_version** | **String** |  |  |
| **go_version** | **String** |  |  |
| **major** | **String** | Major is the major version of the binary version |  |
| **min_compatibility_major** | **String** | MinCompatibilityMajor is the major version of the minimum compatibility version | [optional] |
| **min_compatibility_minor** | **String** | MinCompatibilityMinor is the minor version of the minimum compatibility version | [optional] |
| **minor** | **String** | Minor is the minor version of the binary version |  |
| **platform** | **String** |  |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::VersionInfo.new(
  build_date: null,
  compiler: null,
  emulation_major: null,
  emulation_minor: null,
  git_commit: null,
  git_tree_state: null,
  git_version: null,
  go_version: null,
  major: null,
  min_compatibility_major: null,
  min_compatibility_minor: null,
  minor: null,
  platform: null
)
```


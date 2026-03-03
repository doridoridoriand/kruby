# Kubernetes::V1beta1DeviceAttribute

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **bool** | **Boolean** | BoolValue is a true/false value. | [optional] |
| **int** | **Integer** | IntValue is a number. | [optional] |
| **string** | **String** | StringValue is a string. Must not be longer than 64 characters. | [optional] |
| **version** | **String** | VersionValue is a semantic version according to semver.org spec 2.0.0. Must not be longer than 64 characters. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1beta1DeviceAttribute.new(
  bool: null,
  int: null,
  string: null,
  version: null
)
```


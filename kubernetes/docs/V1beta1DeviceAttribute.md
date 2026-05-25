# Kubernetes::V1beta1DeviceAttribute

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **bool** | **Boolean** | BoolValue is a true/false value. | [optional] |
| **bools** | **Array&lt;Boolean&gt;** | BoolValues is a non-empty list of true/false values. | [optional] |
| **int** | **Integer** | IntValue is a number. | [optional] |
| **ints** | **Array&lt;Integer&gt;** | IntValues is a non-empty list of numbers.  This is an alpha field and requires enabling the DRAListTypeAttributes feature gate. | [optional] |
| **string** | **String** | StringValue is a string. Must not be longer than 64 characters. | [optional] |
| **strings** | **Array&lt;String&gt;** | StringValues is a non-empty list of strings. Each string must not be longer than 64 characters.  This is an alpha field and requires enabling the DRAListTypeAttributes feature gate. | [optional] |
| **version** | **String** | VersionValue is a semantic version according to semver.org spec 2.0.0. Must not be longer than 64 characters. | [optional] |
| **versions** | **Array&lt;String&gt;** | VersionValues is a non-empty list of semantic versions according to semver.org spec 2.0.0. Each version string must not be longer than 64 characters.  This is an alpha field and requires enabling the DRAListTypeAttributes feature gate. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1beta1DeviceAttribute.new(
  bool: null,
  bools: null,
  int: null,
  ints: null,
  string: null,
  strings: null,
  version: null,
  versions: null
)
```


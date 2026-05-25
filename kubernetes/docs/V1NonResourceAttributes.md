# Kubernetes::V1NonResourceAttributes

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **path** | **String** | path is the URL path of the request | [optional] |
| **verb** | **String** | verb is the standard HTTP verb | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1NonResourceAttributes.new(
  path: null,
  verb: null
)
```


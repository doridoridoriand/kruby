# Kubernetes::V1BoundObjectReference

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **api_version** | **String** | apiVersion is API version of the referent. | [optional] |
| **kind** | **String** | kind of the referent. Valid kinds are &#39;Pod&#39; and &#39;Secret&#39;. | [optional] |
| **name** | **String** | name of the referent. | [optional] |
| **uid** | **String** | uid of the referent. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1BoundObjectReference.new(
  api_version: null,
  kind: null,
  name: null,
  uid: null
)
```


# Kubernetes::V1ParamKind

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **api_version** | **String** | apiVersion is the API group version the resources belong to. In format of \&quot;group/version\&quot;. Required. | [optional] |
| **kind** | **String** | kind is the API kind the resources belong to. Required. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1ParamKind.new(
  api_version: null,
  kind: null
)
```


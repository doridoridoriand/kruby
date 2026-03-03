# Kubernetes::V1PodDNSConfigOption

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **name** | **String** | Name is this DNS resolver option&#39;s name. Required. | [optional] |
| **value** | **String** | Value is this DNS resolver option&#39;s value. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1PodDNSConfigOption.new(
  name: null,
  value: null
)
```


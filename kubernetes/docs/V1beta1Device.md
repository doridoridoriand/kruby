# Kubernetes::V1beta1Device

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **basic** | [**V1beta1BasicDevice**](V1beta1BasicDevice.md) |  | [optional] |
| **name** | **String** | Name is unique identifier among all devices managed by the driver in the pool. It must be a DNS label. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1beta1Device.new(
  basic: null,
  name: null
)
```


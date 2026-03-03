# Kubernetes::V1DeviceClaimConfiguration

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **opaque** | [**V1OpaqueDeviceConfiguration**](V1OpaqueDeviceConfiguration.md) |  | [optional] |
| **requests** | **Array&lt;String&gt;** | Requests lists the names of requests where the configuration applies. If empty, it applies to all requests.  References to subrequests must include the name of the main request and may include the subrequest using the format &lt;main request&gt;[/&lt;subrequest&gt;]. If just the main request is given, the configuration applies to all subrequests. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1DeviceClaimConfiguration.new(
  opaque: null,
  requests: null
)
```


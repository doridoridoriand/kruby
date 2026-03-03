# Kubernetes::V1ServiceCIDRSpec

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **cidrs** | **Array&lt;String&gt;** | CIDRs defines the IP blocks in CIDR notation (e.g. \&quot;192.168.0.0/24\&quot; or \&quot;2001:db8::/64\&quot;) from which to assign service cluster IPs. Max of two CIDRs is allowed, one of each IP family. This field is immutable. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1ServiceCIDRSpec.new(
  cidrs: null
)
```


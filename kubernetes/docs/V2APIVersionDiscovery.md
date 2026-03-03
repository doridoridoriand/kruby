# Kubernetes::V2APIVersionDiscovery

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **version** | **String** | version is the name of the version within a group version. |  |
| **resources** | [**Array&lt;V2APIResourceDiscovery&gt;**](V2APIResourceDiscovery.md) |  | [optional] |
| **freshness** | **String** | freshness marks whether a group version&#39;s discovery document is up to date. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V2APIVersionDiscovery.new(
  version: null,
  resources: null,
  freshness: null
)
```


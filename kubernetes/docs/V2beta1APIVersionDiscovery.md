# Kubernetes::V2beta1APIVersionDiscovery

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **version** | **String** | version is the name of the version within a group version. |  |
| **resources** | [**Array&lt;V2beta1APIResourceDiscovery&gt;**](V2beta1APIResourceDiscovery.md) |  | [optional] |
| **freshness** | **String** | freshness marks whether a group version&#39;s discovery document is up to date. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V2beta1APIVersionDiscovery.new(
  version: null,
  resources: null,
  freshness: null
)
```


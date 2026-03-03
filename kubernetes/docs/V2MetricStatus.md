# Kubernetes::V2MetricStatus

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **container_resource** | [**V2ContainerResourceMetricStatus**](V2ContainerResourceMetricStatus.md) |  | [optional] |
| **external** | [**V2ExternalMetricStatus**](V2ExternalMetricStatus.md) |  | [optional] |
| **object** | [**V2ObjectMetricStatus**](V2ObjectMetricStatus.md) |  | [optional] |
| **pods** | [**V2PodsMetricStatus**](V2PodsMetricStatus.md) |  | [optional] |
| **resource** | [**V2ResourceMetricStatus**](V2ResourceMetricStatus.md) |  | [optional] |
| **type** | **String** | type is the type of metric source.  It will be one of \&quot;ContainerResource\&quot;, \&quot;External\&quot;, \&quot;Object\&quot;, \&quot;Pods\&quot; or \&quot;Resource\&quot;, each corresponds to a matching field in the object. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V2MetricStatus.new(
  container_resource: null,
  external: null,
  object: null,
  pods: null,
  resource: null,
  type: null
)
```


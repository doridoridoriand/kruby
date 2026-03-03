# Kubernetes::V2MetricSpec

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **container_resource** | [**V2ContainerResourceMetricSource**](V2ContainerResourceMetricSource.md) |  | [optional] |
| **external** | [**V2ExternalMetricSource**](V2ExternalMetricSource.md) |  | [optional] |
| **object** | [**V2ObjectMetricSource**](V2ObjectMetricSource.md) |  | [optional] |
| **pods** | [**V2PodsMetricSource**](V2PodsMetricSource.md) |  | [optional] |
| **resource** | [**V2ResourceMetricSource**](V2ResourceMetricSource.md) |  | [optional] |
| **type** | **String** | type is the type of metric source.  It should be one of \&quot;ContainerResource\&quot;, \&quot;External\&quot;, \&quot;Object\&quot;, \&quot;Pods\&quot; or \&quot;Resource\&quot;, each mapping to a matching field in the object. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V2MetricSpec.new(
  container_resource: null,
  external: null,
  object: null,
  pods: null,
  resource: null,
  type: null
)
```


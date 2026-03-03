# Kubernetes::V1DeviceToleration

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **effect** | **String** | Effect indicates the taint effect to match. Empty means match all taint effects. When specified, allowed values are NoSchedule and NoExecute. | [optional] |
| **key** | **String** | Key is the taint key that the toleration applies to. Empty means match all taint keys. If the key is empty, operator must be Exists; this combination means to match all values and all keys. Must be a label name. | [optional] |
| **operator** | **String** | Operator represents a key&#39;s relationship to the value. Valid operators are Exists and Equal. Defaults to Equal. Exists is equivalent to wildcard for value, so that a ResourceClaim can tolerate all taints of a particular category. | [optional] |
| **toleration_seconds** | **Integer** | TolerationSeconds represents the period of time the toleration (which must be of effect NoExecute, otherwise this field is ignored) tolerates the taint. By default, it is not set, which means tolerate the taint forever (do not evict). Zero and negative values will be treated as 0 (evict immediately) by the system. If larger than zero, the time when the pod needs to be evicted is calculated as &lt;time when taint was adedd&gt; + &lt;toleration seconds&gt;. | [optional] |
| **value** | **String** | Value is the taint value the toleration matches to. If the operator is Exists, the value must be empty, otherwise just a regular string. Must be a label value. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1DeviceToleration.new(
  effect: null,
  key: null,
  operator: null,
  toleration_seconds: null,
  value: null
)
```


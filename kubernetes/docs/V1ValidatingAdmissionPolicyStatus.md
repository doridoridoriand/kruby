# Kubernetes::V1ValidatingAdmissionPolicyStatus

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **conditions** | [**Array&lt;V1Condition&gt;**](V1Condition.md) | conditions represent the latest available observations of a policy&#39;s current state. | [optional] |
| **observed_generation** | **Integer** | observedGeneration is the generation observed by the controller. | [optional] |
| **type_checking** | [**V1TypeChecking**](V1TypeChecking.md) |  | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1ValidatingAdmissionPolicyStatus.new(
  conditions: null,
  observed_generation: null,
  type_checking: null
)
```


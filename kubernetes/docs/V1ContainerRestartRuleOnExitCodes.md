# Kubernetes::V1ContainerRestartRuleOnExitCodes

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **operator** | **String** | Represents the relationship between the container exit code(s) and the specified values. Possible values are: - In: the requirement is satisfied if the container exit code is in the   set of specified values. - NotIn: the requirement is satisfied if the container exit code is   not in the set of specified values. |  |
| **values** | **Array&lt;Integer&gt;** | Specifies the set of values to check for container exit codes. At most 255 elements are allowed. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1ContainerRestartRuleOnExitCodes.new(
  operator: null,
  values: null
)
```


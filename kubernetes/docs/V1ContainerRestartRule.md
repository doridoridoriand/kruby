# Kubernetes::V1ContainerRestartRule

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **action** | **String** | Specifies the action taken on a container exit if the requirements are satisfied. The only possible value is \&quot;Restart\&quot; to restart the container. |  |
| **exit_codes** | [**V1ContainerRestartRuleOnExitCodes**](V1ContainerRestartRuleOnExitCodes.md) |  | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1ContainerRestartRule.new(
  action: null,
  exit_codes: null
)
```


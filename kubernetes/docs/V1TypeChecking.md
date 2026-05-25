# Kubernetes::V1TypeChecking

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **expression_warnings** | [**Array&lt;V1ExpressionWarning&gt;**](V1ExpressionWarning.md) | expressionWarnings contains the type checking warnings for each expression. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1TypeChecking.new(
  expression_warnings: null
)
```


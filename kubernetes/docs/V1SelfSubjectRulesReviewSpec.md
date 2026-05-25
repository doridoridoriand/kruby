# Kubernetes::V1SelfSubjectRulesReviewSpec

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **namespace** | **String** | namespace to evaluate rules for. Required. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1SelfSubjectRulesReviewSpec.new(
  namespace: null
)
```


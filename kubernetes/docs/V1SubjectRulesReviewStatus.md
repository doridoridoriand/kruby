# Kubernetes::V1SubjectRulesReviewStatus

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **evaluation_error** | **String** | evaluationError can appear in combination with Rules. It indicates an error occurred during rule evaluation, such as an authorizer that doesn&#39;t support rule evaluation, and that ResourceRules and/or NonResourceRules may be incomplete. | [optional] |
| **incomplete** | **Boolean** | incomplete is true when the rules returned by this call are incomplete. This is most commonly encountered when an authorizer, such as an external authorizer, doesn&#39;t support rules evaluation. |  |
| **non_resource_rules** | [**Array&lt;V1NonResourceRule&gt;**](V1NonResourceRule.md) | nonResourceRules is the list of actions the subject is allowed to perform on non-resources. The list ordering isn&#39;t significant, may contain duplicates, and possibly be incomplete. |  |
| **resource_rules** | [**Array&lt;V1ResourceRule&gt;**](V1ResourceRule.md) | resourceRules is the list of actions the subject is allowed to perform on resources. The list ordering isn&#39;t significant, may contain duplicates, and possibly be incomplete. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1SubjectRulesReviewStatus.new(
  evaluation_error: null,
  incomplete: null,
  non_resource_rules: null,
  resource_rules: null
)
```


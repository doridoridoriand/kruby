# Kubernetes::V1MutatingAdmissionPolicyBindingSpec

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **match_resources** | [**V1MatchResources**](V1MatchResources.md) |  | [optional] |
| **param_ref** | [**V1ParamRef**](V1ParamRef.md) |  | [optional] |
| **policy_name** | **String** | policyName references a MutatingAdmissionPolicy name which the MutatingAdmissionPolicyBinding binds to. If the referenced resource does not exist, this binding is considered invalid and will be ignored Required. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1MutatingAdmissionPolicyBindingSpec.new(
  match_resources: null,
  param_ref: null,
  policy_name: null
)
```


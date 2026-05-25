# Kubernetes::V1ResourceAttributes

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **field_selector** | [**V1FieldSelectorAttributes**](V1FieldSelectorAttributes.md) |  | [optional] |
| **group** | **String** | group is the API Group of the Resource.  \&quot;*\&quot; means all. | [optional] |
| **label_selector** | [**V1LabelSelectorAttributes**](V1LabelSelectorAttributes.md) |  | [optional] |
| **name** | **String** | name is the name of the resource being requested for a \&quot;get\&quot; or deleted for a \&quot;delete\&quot;. \&quot;\&quot; (empty) means all. | [optional] |
| **namespace** | **String** | namespace is the namespace of the action being requested.  Currently, there is no distinction between no namespace and all namespaces \&quot;\&quot; (empty) is defaulted for LocalSubjectAccessReviews \&quot;\&quot; (empty) is empty for cluster-scoped resources \&quot;\&quot; (empty) means \&quot;all\&quot; for namespace scoped resources from a SubjectAccessReview or SelfSubjectAccessReview | [optional] |
| **resource** | **String** | resource is one of the existing resource types.  \&quot;*\&quot; means all. | [optional] |
| **subresource** | **String** | subresource is one of the existing resource types.  \&quot;\&quot; means none. | [optional] |
| **verb** | **String** | verb is a kubernetes resource API verb, like: get, list, watch, create, update, delete, proxy.  \&quot;*\&quot; means all. | [optional] |
| **version** | **String** | version is the API Version of the Resource.  \&quot;*\&quot; means all. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1ResourceAttributes.new(
  field_selector: null,
  group: null,
  label_selector: null,
  name: null,
  namespace: null,
  resource: null,
  subresource: null,
  verb: null,
  version: null
)
```


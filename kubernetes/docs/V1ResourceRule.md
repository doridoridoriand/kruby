# Kubernetes::V1ResourceRule

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **api_groups** | **Array&lt;String&gt;** | apiGroups is the name of the APIGroup that contains the resources.  If multiple API groups are specified, any action requested against one of the enumerated resources in any API group will be allowed.  \&quot;*\&quot; means all. | [optional] |
| **resource_names** | **Array&lt;String&gt;** | resourceNames is an optional white list of names that the rule applies to.  An empty set means that everything is allowed.  \&quot;*\&quot; means all. | [optional] |
| **resources** | **Array&lt;String&gt;** | resources is a list of resources this rule applies to.  \&quot;*\&quot; means all in the specified apiGroups.  \&quot;*/foo\&quot; represents the subresource &#39;foo&#39; for all resources in the specified apiGroups. | [optional] |
| **verbs** | **Array&lt;String&gt;** | verbs is a list of kubernetes resource API verbs, like: get, list, watch, create, update, delete, proxy.  \&quot;*\&quot; means all. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1ResourceRule.new(
  api_groups: null,
  resource_names: null,
  resources: null,
  verbs: null
)
```


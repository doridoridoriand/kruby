# Kubernetes::V1beta1StorageVersionMigrationStatus

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **conditions** | [**Array&lt;V1Condition&gt;**](V1Condition.md) | The latest available observations of the migration&#39;s current state. | [optional] |
| **resource_version** | **String** | ResourceVersion to compare with the GC cache for performing the migration. This is the current resource version of given group, version and resource when kube-controller-manager first observes this StorageVersionMigration resource. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1beta1StorageVersionMigrationStatus.new(
  conditions: null,
  resource_version: null
)
```


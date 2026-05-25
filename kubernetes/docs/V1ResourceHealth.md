# Kubernetes::V1ResourceHealth

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **health** | **String** | Health of the resource. can be one of:  - Healthy: operates as normal  - Unhealthy: reported unhealthy. We consider this a temporary health issue               since we do not have a mechanism today to distinguish               temporary and permanent issues.  - Unknown: The status cannot be determined.             For example, Device Plugin got unregistered and hasn&#39;t been re-registered since.  In future we may want to introduce the PermanentlyUnhealthy Status. | [optional] |
| **message** | **String** | Message provides human-readable context for Health (e.g. \&quot;ECC error count exceeded threshold\&quot;). This field is populated by the kubelet when ResourceHealthStatusMessage is enabled if the DRA plugin returns a message, and is null otherwise. | [optional] |
| **resource_id** | **String** | ResourceID is the unique identifier of the resource. See the ResourceID type for more information. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1ResourceHealth.new(
  health: null,
  message: null,
  resource_id: null
)
```


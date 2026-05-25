# Kubernetes::V1ImageVolumeStatus

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **image_ref** | **String** | ImageRef is the digest of the image used for this volume. It should have a value that&#39;s similar to the pod&#39;s status.containerStatuses[i].imageID. The ImageRef length should not exceed 256 characters. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1ImageVolumeStatus.new(
  image_ref: null
)
```


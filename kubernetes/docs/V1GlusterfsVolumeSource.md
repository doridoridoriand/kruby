# Kubernetes::V1GlusterfsVolumeSource

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **endpoints** | **String** | endpoints is the endpoint name that details Glusterfs topology. |  |
| **path** | **String** | path is the Glusterfs volume path. More info: https://examples.k8s.io/volumes/glusterfs/README.md#create-a-pod |  |
| **read_only** | **Boolean** | readOnly here will force the Glusterfs volume to be mounted with read-only permissions. Defaults to false. More info: https://examples.k8s.io/volumes/glusterfs/README.md#create-a-pod | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1GlusterfsVolumeSource.new(
  endpoints: null,
  path: null,
  read_only: null
)
```


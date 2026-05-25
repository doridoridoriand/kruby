# Kubernetes::V1alpha1ServerStorageVersion

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **api_server_id** | **String** | apiServerID is the ID of the reporting API server. |  |
| **decodable_versions** | **Array&lt;String&gt;** | decodableVersions are the encoding versions the API server can handle to decode. The API server can decode objects encoded in these versions. The encodingVersion must be included in the decodableVersions. |  |
| **encoding_version** | **String** | encodingVersion the API server encodes the object to when persisting it in the backend (e.g., etcd). |  |
| **served_versions** | **Array&lt;String&gt;** | servedVersions lists all versions the API server can serve. DecodableVersions must include all ServedVersions. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1alpha1ServerStorageVersion.new(
  api_server_id: null,
  decodable_versions: null,
  encoding_version: null,
  served_versions: null
)
```


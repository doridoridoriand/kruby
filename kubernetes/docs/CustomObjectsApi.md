# Kubernetes::CustomObjectsApi

All URIs are relative to *http://localhost*

| Method | HTTP request | Description |
| ------ | ------------ | ----------- |
| [**create_cluster_custom_object**](CustomObjectsApi.md#create_cluster_custom_object) | **POST** /apis/{group}/{version}/{plural} |  |
| [**create_namespaced_custom_object**](CustomObjectsApi.md#create_namespaced_custom_object) | **POST** /apis/{group}/{version}/namespaces/{namespace}/{plural} |  |
| [**delete_cluster_custom_object**](CustomObjectsApi.md#delete_cluster_custom_object) | **DELETE** /apis/{group}/{version}/{plural}/{name} |  |
| [**delete_collection_cluster_custom_object**](CustomObjectsApi.md#delete_collection_cluster_custom_object) | **DELETE** /apis/{group}/{version}/{plural} |  |
| [**delete_collection_namespaced_custom_object**](CustomObjectsApi.md#delete_collection_namespaced_custom_object) | **DELETE** /apis/{group}/{version}/namespaces/{namespace}/{plural} |  |
| [**delete_namespaced_custom_object**](CustomObjectsApi.md#delete_namespaced_custom_object) | **DELETE** /apis/{group}/{version}/namespaces/{namespace}/{plural}/{name} |  |
| [**get_api_resourcesgroupversion**](CustomObjectsApi.md#get_api_resourcesgroupversion) | **GET** /apis/{group}/{version} |  |
| [**get_cluster_custom_object**](CustomObjectsApi.md#get_cluster_custom_object) | **GET** /apis/{group}/{version}/{plural}/{name} |  |
| [**get_cluster_custom_object_scale**](CustomObjectsApi.md#get_cluster_custom_object_scale) | **GET** /apis/{group}/{version}/{plural}/{name}/scale |  |
| [**get_cluster_custom_object_status**](CustomObjectsApi.md#get_cluster_custom_object_status) | **GET** /apis/{group}/{version}/{plural}/{name}/status |  |
| [**get_namespaced_custom_object**](CustomObjectsApi.md#get_namespaced_custom_object) | **GET** /apis/{group}/{version}/namespaces/{namespace}/{plural}/{name} |  |
| [**get_namespaced_custom_object_scale**](CustomObjectsApi.md#get_namespaced_custom_object_scale) | **GET** /apis/{group}/{version}/namespaces/{namespace}/{plural}/{name}/scale |  |
| [**get_namespaced_custom_object_status**](CustomObjectsApi.md#get_namespaced_custom_object_status) | **GET** /apis/{group}/{version}/namespaces/{namespace}/{plural}/{name}/status |  |
| [**list_cluster_custom_object**](CustomObjectsApi.md#list_cluster_custom_object) | **GET** /apis/{group}/{version}/{plural} |  |
| [**list_custom_object_for_all_namespaces**](CustomObjectsApi.md#list_custom_object_for_all_namespaces) | **GET** /apis/{group}/{version}/{resource_plural} |  |
| [**list_namespaced_custom_object**](CustomObjectsApi.md#list_namespaced_custom_object) | **GET** /apis/{group}/{version}/namespaces/{namespace}/{plural} |  |
| [**patch_cluster_custom_object**](CustomObjectsApi.md#patch_cluster_custom_object) | **PATCH** /apis/{group}/{version}/{plural}/{name} |  |
| [**patch_cluster_custom_object_scale**](CustomObjectsApi.md#patch_cluster_custom_object_scale) | **PATCH** /apis/{group}/{version}/{plural}/{name}/scale |  |
| [**patch_cluster_custom_object_status**](CustomObjectsApi.md#patch_cluster_custom_object_status) | **PATCH** /apis/{group}/{version}/{plural}/{name}/status |  |
| [**patch_namespaced_custom_object**](CustomObjectsApi.md#patch_namespaced_custom_object) | **PATCH** /apis/{group}/{version}/namespaces/{namespace}/{plural}/{name} |  |
| [**patch_namespaced_custom_object_scale**](CustomObjectsApi.md#patch_namespaced_custom_object_scale) | **PATCH** /apis/{group}/{version}/namespaces/{namespace}/{plural}/{name}/scale |  |
| [**patch_namespaced_custom_object_status**](CustomObjectsApi.md#patch_namespaced_custom_object_status) | **PATCH** /apis/{group}/{version}/namespaces/{namespace}/{plural}/{name}/status |  |
| [**replace_cluster_custom_object**](CustomObjectsApi.md#replace_cluster_custom_object) | **PUT** /apis/{group}/{version}/{plural}/{name} |  |
| [**replace_cluster_custom_object_scale**](CustomObjectsApi.md#replace_cluster_custom_object_scale) | **PUT** /apis/{group}/{version}/{plural}/{name}/scale |  |
| [**replace_cluster_custom_object_status**](CustomObjectsApi.md#replace_cluster_custom_object_status) | **PUT** /apis/{group}/{version}/{plural}/{name}/status |  |
| [**replace_namespaced_custom_object**](CustomObjectsApi.md#replace_namespaced_custom_object) | **PUT** /apis/{group}/{version}/namespaces/{namespace}/{plural}/{name} |  |
| [**replace_namespaced_custom_object_scale**](CustomObjectsApi.md#replace_namespaced_custom_object_scale) | **PUT** /apis/{group}/{version}/namespaces/{namespace}/{plural}/{name}/scale |  |
| [**replace_namespaced_custom_object_status**](CustomObjectsApi.md#replace_namespaced_custom_object_status) | **PUT** /apis/{group}/{version}/namespaces/{namespace}/{plural}/{name}/status |  |


## create_cluster_custom_object

> Object create_cluster_custom_object(group, version, plural, body, opts)



Creates a cluster scoped Custom object

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | The custom resource's group name
version = 'version_example' # String | The custom resource's version
plural = 'plural_example' # String | The custom resource's plural name. For TPRs this would be lowercase plural kind.
body = Object # Object | The JSON schema of the Resource to create.
opts = {
  pretty: 'pretty_example', # String | If 'true', then the output is pretty printed.
  dry_run: 'dry_run_example', # String | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed
  field_manager: 'field_manager_example', # String | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. This field is required for apply requests (application/apply-patch) but optional for non-apply patch types (JsonPatch, MergePatch, StrategicMergePatch).
  field_validation: 'field_validation_example' # String | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional)
}

begin
  
  result = api_instance.create_cluster_custom_object(group, version, plural, body, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->create_cluster_custom_object: #{e}"
end
```

#### Using the create_cluster_custom_object_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> create_cluster_custom_object_with_http_info(group, version, plural, body, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.create_cluster_custom_object_with_http_info(group, version, plural, body, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->create_cluster_custom_object_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | The custom resource&#39;s group name |  |
| **version** | **String** | The custom resource&#39;s version |  |
| **plural** | **String** | The custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **body** | **Object** | The JSON schema of the Resource to create. |  |
| **pretty** | **String** | If &#39;true&#39;, then the output is pretty printed. | [optional] |
| **dry_run** | **String** | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed | [optional] |
| **field_manager** | **String** | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. This field is required for apply requests (application/apply-patch) but optional for non-apply patch types (JsonPatch, MergePatch, StrategicMergePatch). | [optional] |
| **field_validation** | **String** | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional) | [optional] |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## create_namespaced_custom_object

> Object create_namespaced_custom_object(group, version, namespace, plural, body, opts)



Creates a namespace scoped Custom object

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | The custom resource's group name
version = 'version_example' # String | The custom resource's version
namespace = 'namespace_example' # String | The custom resource's namespace
plural = 'plural_example' # String | The custom resource's plural name. For TPRs this would be lowercase plural kind.
body = Object # Object | The JSON schema of the Resource to create.
opts = {
  pretty: 'pretty_example', # String | If 'true', then the output is pretty printed.
  dry_run: 'dry_run_example', # String | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed
  field_manager: 'field_manager_example', # String | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint.
  field_validation: 'field_validation_example' # String | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional)
}

begin
  
  result = api_instance.create_namespaced_custom_object(group, version, namespace, plural, body, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->create_namespaced_custom_object: #{e}"
end
```

#### Using the create_namespaced_custom_object_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> create_namespaced_custom_object_with_http_info(group, version, namespace, plural, body, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.create_namespaced_custom_object_with_http_info(group, version, namespace, plural, body, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->create_namespaced_custom_object_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | The custom resource&#39;s group name |  |
| **version** | **String** | The custom resource&#39;s version |  |
| **namespace** | **String** | The custom resource&#39;s namespace |  |
| **plural** | **String** | The custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **body** | **Object** | The JSON schema of the Resource to create. |  |
| **pretty** | **String** | If &#39;true&#39;, then the output is pretty printed. | [optional] |
| **dry_run** | **String** | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed | [optional] |
| **field_manager** | **String** | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. | [optional] |
| **field_validation** | **String** | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional) | [optional] |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## delete_cluster_custom_object

> Object delete_cluster_custom_object(group, version, plural, name, opts)



Deletes the specified cluster scoped custom object

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | the custom resource's group
version = 'version_example' # String | the custom resource's version
plural = 'plural_example' # String | the custom object's plural name. For TPRs this would be lowercase plural kind.
name = 'name_example' # String | the custom object's name
opts = {
  grace_period_seconds: 56, # Integer | The duration in seconds before the object should be deleted. Value must be non-negative integer. The value zero indicates delete immediately. If this value is nil, the default grace period for the specified type will be used. Defaults to a per object value if not specified. zero means delete immediately.
  orphan_dependents: true, # Boolean | Deprecated: please use the PropagationPolicy, this field will be deprecated in 1.7. Should the dependent objects be orphaned. If true/false, the \"orphan\" finalizer will be added to/removed from the object's finalizers list. Either this field or PropagationPolicy may be set, but not both.
  propagation_policy: 'propagation_policy_example', # String | Whether and how garbage collection will be performed. Either this field or OrphanDependents may be set, but not both. The default policy is decided by the existing finalizer set in the metadata.finalizers and the resource-specific default policy.
  dry_run: 'dry_run_example', # String | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed
  body: Kubernetes::V1DeleteOptions.new # V1DeleteOptions | 
}

begin
  
  result = api_instance.delete_cluster_custom_object(group, version, plural, name, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->delete_cluster_custom_object: #{e}"
end
```

#### Using the delete_cluster_custom_object_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> delete_cluster_custom_object_with_http_info(group, version, plural, name, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.delete_cluster_custom_object_with_http_info(group, version, plural, name, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->delete_cluster_custom_object_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | the custom resource&#39;s group |  |
| **version** | **String** | the custom resource&#39;s version |  |
| **plural** | **String** | the custom object&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **name** | **String** | the custom object&#39;s name |  |
| **grace_period_seconds** | **Integer** | The duration in seconds before the object should be deleted. Value must be non-negative integer. The value zero indicates delete immediately. If this value is nil, the default grace period for the specified type will be used. Defaults to a per object value if not specified. zero means delete immediately. | [optional] |
| **orphan_dependents** | **Boolean** | Deprecated: please use the PropagationPolicy, this field will be deprecated in 1.7. Should the dependent objects be orphaned. If true/false, the \&quot;orphan\&quot; finalizer will be added to/removed from the object&#39;s finalizers list. Either this field or PropagationPolicy may be set, but not both. | [optional] |
| **propagation_policy** | **String** | Whether and how garbage collection will be performed. Either this field or OrphanDependents may be set, but not both. The default policy is decided by the existing finalizer set in the metadata.finalizers and the resource-specific default policy. | [optional] |
| **dry_run** | **String** | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed | [optional] |
| **body** | [**V1DeleteOptions**](V1DeleteOptions.md) |  | [optional] |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## delete_collection_cluster_custom_object

> Object delete_collection_cluster_custom_object(group, version, plural, opts)



Delete collection of cluster scoped custom objects

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | The custom resource's group name
version = 'version_example' # String | The custom resource's version
plural = 'plural_example' # String | The custom resource's plural name. For TPRs this would be lowercase plural kind.
opts = {
  pretty: 'pretty_example', # String | If 'true', then the output is pretty printed.
  label_selector: 'label_selector_example', # String | A selector to restrict the list of returned objects by their labels. Defaults to everything.
  grace_period_seconds: 56, # Integer | The duration in seconds before the object should be deleted. Value must be non-negative integer. The value zero indicates delete immediately. If this value is nil, the default grace period for the specified type will be used. Defaults to a per object value if not specified. zero means delete immediately.
  orphan_dependents: true, # Boolean | Deprecated: please use the PropagationPolicy, this field will be deprecated in 1.7. Should the dependent objects be orphaned. If true/false, the \"orphan\" finalizer will be added to/removed from the object's finalizers list. Either this field or PropagationPolicy may be set, but not both.
  propagation_policy: 'propagation_policy_example', # String | Whether and how garbage collection will be performed. Either this field or OrphanDependents may be set, but not both. The default policy is decided by the existing finalizer set in the metadata.finalizers and the resource-specific default policy.
  dry_run: 'dry_run_example', # String | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed
  body: Kubernetes::V1DeleteOptions.new # V1DeleteOptions | 
}

begin
  
  result = api_instance.delete_collection_cluster_custom_object(group, version, plural, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->delete_collection_cluster_custom_object: #{e}"
end
```

#### Using the delete_collection_cluster_custom_object_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> delete_collection_cluster_custom_object_with_http_info(group, version, plural, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.delete_collection_cluster_custom_object_with_http_info(group, version, plural, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->delete_collection_cluster_custom_object_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | The custom resource&#39;s group name |  |
| **version** | **String** | The custom resource&#39;s version |  |
| **plural** | **String** | The custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **pretty** | **String** | If &#39;true&#39;, then the output is pretty printed. | [optional] |
| **label_selector** | **String** | A selector to restrict the list of returned objects by their labels. Defaults to everything. | [optional] |
| **grace_period_seconds** | **Integer** | The duration in seconds before the object should be deleted. Value must be non-negative integer. The value zero indicates delete immediately. If this value is nil, the default grace period for the specified type will be used. Defaults to a per object value if not specified. zero means delete immediately. | [optional] |
| **orphan_dependents** | **Boolean** | Deprecated: please use the PropagationPolicy, this field will be deprecated in 1.7. Should the dependent objects be orphaned. If true/false, the \&quot;orphan\&quot; finalizer will be added to/removed from the object&#39;s finalizers list. Either this field or PropagationPolicy may be set, but not both. | [optional] |
| **propagation_policy** | **String** | Whether and how garbage collection will be performed. Either this field or OrphanDependents may be set, but not both. The default policy is decided by the existing finalizer set in the metadata.finalizers and the resource-specific default policy. | [optional] |
| **dry_run** | **String** | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed | [optional] |
| **body** | [**V1DeleteOptions**](V1DeleteOptions.md) |  | [optional] |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## delete_collection_namespaced_custom_object

> Object delete_collection_namespaced_custom_object(group, version, namespace, plural, opts)



Delete collection of namespace scoped custom objects

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | The custom resource's group name
version = 'version_example' # String | The custom resource's version
namespace = 'namespace_example' # String | The custom resource's namespace
plural = 'plural_example' # String | The custom resource's plural name. For TPRs this would be lowercase plural kind.
opts = {
  pretty: 'pretty_example', # String | If 'true', then the output is pretty printed.
  label_selector: 'label_selector_example', # String | A selector to restrict the list of returned objects by their labels. Defaults to everything.
  grace_period_seconds: 56, # Integer | The duration in seconds before the object should be deleted. Value must be non-negative integer. The value zero indicates delete immediately. If this value is nil, the default grace period for the specified type will be used. Defaults to a per object value if not specified. zero means delete immediately.
  orphan_dependents: true, # Boolean | Deprecated: please use the PropagationPolicy, this field will be deprecated in 1.7. Should the dependent objects be orphaned. If true/false, the \"orphan\" finalizer will be added to/removed from the object's finalizers list. Either this field or PropagationPolicy may be set, but not both.
  propagation_policy: 'propagation_policy_example', # String | Whether and how garbage collection will be performed. Either this field or OrphanDependents may be set, but not both. The default policy is decided by the existing finalizer set in the metadata.finalizers and the resource-specific default policy.
  dry_run: 'dry_run_example', # String | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed
  field_selector: 'field_selector_example', # String | A selector to restrict the list of returned objects by their fields. Defaults to everything.
  body: Kubernetes::V1DeleteOptions.new # V1DeleteOptions | 
}

begin
  
  result = api_instance.delete_collection_namespaced_custom_object(group, version, namespace, plural, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->delete_collection_namespaced_custom_object: #{e}"
end
```

#### Using the delete_collection_namespaced_custom_object_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> delete_collection_namespaced_custom_object_with_http_info(group, version, namespace, plural, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.delete_collection_namespaced_custom_object_with_http_info(group, version, namespace, plural, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->delete_collection_namespaced_custom_object_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | The custom resource&#39;s group name |  |
| **version** | **String** | The custom resource&#39;s version |  |
| **namespace** | **String** | The custom resource&#39;s namespace |  |
| **plural** | **String** | The custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **pretty** | **String** | If &#39;true&#39;, then the output is pretty printed. | [optional] |
| **label_selector** | **String** | A selector to restrict the list of returned objects by their labels. Defaults to everything. | [optional] |
| **grace_period_seconds** | **Integer** | The duration in seconds before the object should be deleted. Value must be non-negative integer. The value zero indicates delete immediately. If this value is nil, the default grace period for the specified type will be used. Defaults to a per object value if not specified. zero means delete immediately. | [optional] |
| **orphan_dependents** | **Boolean** | Deprecated: please use the PropagationPolicy, this field will be deprecated in 1.7. Should the dependent objects be orphaned. If true/false, the \&quot;orphan\&quot; finalizer will be added to/removed from the object&#39;s finalizers list. Either this field or PropagationPolicy may be set, but not both. | [optional] |
| **propagation_policy** | **String** | Whether and how garbage collection will be performed. Either this field or OrphanDependents may be set, but not both. The default policy is decided by the existing finalizer set in the metadata.finalizers and the resource-specific default policy. | [optional] |
| **dry_run** | **String** | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed | [optional] |
| **field_selector** | **String** | A selector to restrict the list of returned objects by their fields. Defaults to everything. | [optional] |
| **body** | [**V1DeleteOptions**](V1DeleteOptions.md) |  | [optional] |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## delete_namespaced_custom_object

> Object delete_namespaced_custom_object(group, version, namespace, plural, name, opts)



Deletes the specified namespace scoped custom object

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | the custom resource's group
version = 'version_example' # String | the custom resource's version
namespace = 'namespace_example' # String | The custom resource's namespace
plural = 'plural_example' # String | the custom resource's plural name. For TPRs this would be lowercase plural kind.
name = 'name_example' # String | the custom object's name
opts = {
  grace_period_seconds: 56, # Integer | The duration in seconds before the object should be deleted. Value must be non-negative integer. The value zero indicates delete immediately. If this value is nil, the default grace period for the specified type will be used. Defaults to a per object value if not specified. zero means delete immediately.
  orphan_dependents: true, # Boolean | Deprecated: please use the PropagationPolicy, this field will be deprecated in 1.7. Should the dependent objects be orphaned. If true/false, the \"orphan\" finalizer will be added to/removed from the object's finalizers list. Either this field or PropagationPolicy may be set, but not both.
  propagation_policy: 'propagation_policy_example', # String | Whether and how garbage collection will be performed. Either this field or OrphanDependents may be set, but not both. The default policy is decided by the existing finalizer set in the metadata.finalizers and the resource-specific default policy.
  dry_run: 'dry_run_example', # String | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed
  body: Kubernetes::V1DeleteOptions.new # V1DeleteOptions | 
}

begin
  
  result = api_instance.delete_namespaced_custom_object(group, version, namespace, plural, name, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->delete_namespaced_custom_object: #{e}"
end
```

#### Using the delete_namespaced_custom_object_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> delete_namespaced_custom_object_with_http_info(group, version, namespace, plural, name, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.delete_namespaced_custom_object_with_http_info(group, version, namespace, plural, name, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->delete_namespaced_custom_object_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | the custom resource&#39;s group |  |
| **version** | **String** | the custom resource&#39;s version |  |
| **namespace** | **String** | The custom resource&#39;s namespace |  |
| **plural** | **String** | the custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **name** | **String** | the custom object&#39;s name |  |
| **grace_period_seconds** | **Integer** | The duration in seconds before the object should be deleted. Value must be non-negative integer. The value zero indicates delete immediately. If this value is nil, the default grace period for the specified type will be used. Defaults to a per object value if not specified. zero means delete immediately. | [optional] |
| **orphan_dependents** | **Boolean** | Deprecated: please use the PropagationPolicy, this field will be deprecated in 1.7. Should the dependent objects be orphaned. If true/false, the \&quot;orphan\&quot; finalizer will be added to/removed from the object&#39;s finalizers list. Either this field or PropagationPolicy may be set, but not both. | [optional] |
| **propagation_policy** | **String** | Whether and how garbage collection will be performed. Either this field or OrphanDependents may be set, but not both. The default policy is decided by the existing finalizer set in the metadata.finalizers and the resource-specific default policy. | [optional] |
| **dry_run** | **String** | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed | [optional] |
| **body** | [**V1DeleteOptions**](V1DeleteOptions.md) |  | [optional] |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## get_api_resourcesgroupversion

> <V1APIResourceList> get_api_resourcesgroupversion(group, version)



get available resources

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | The custom resource's group name
version = 'version_example' # String | The custom resource's version

begin
  
  result = api_instance.get_api_resourcesgroupversion(group, version)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->get_api_resourcesgroupversion: #{e}"
end
```

#### Using the get_api_resourcesgroupversion_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<V1APIResourceList>, Integer, Hash)> get_api_resourcesgroupversion_with_http_info(group, version)

```ruby
begin
  
  data, status_code, headers = api_instance.get_api_resourcesgroupversion_with_http_info(group, version)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <V1APIResourceList>
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->get_api_resourcesgroupversion_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | The custom resource&#39;s group name |  |
| **version** | **String** | The custom resource&#39;s version |  |

### Return type

[**V1APIResourceList**](V1APIResourceList.md)

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## get_cluster_custom_object

> Object get_cluster_custom_object(group, version, plural, name)



Returns a cluster scoped custom object

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | the custom resource's group
version = 'version_example' # String | the custom resource's version
plural = 'plural_example' # String | the custom object's plural name. For TPRs this would be lowercase plural kind.
name = 'name_example' # String | the custom object's name

begin
  
  result = api_instance.get_cluster_custom_object(group, version, plural, name)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->get_cluster_custom_object: #{e}"
end
```

#### Using the get_cluster_custom_object_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> get_cluster_custom_object_with_http_info(group, version, plural, name)

```ruby
begin
  
  data, status_code, headers = api_instance.get_cluster_custom_object_with_http_info(group, version, plural, name)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->get_cluster_custom_object_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | the custom resource&#39;s group |  |
| **version** | **String** | the custom resource&#39;s version |  |
| **plural** | **String** | the custom object&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **name** | **String** | the custom object&#39;s name |  |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## get_cluster_custom_object_scale

> Object get_cluster_custom_object_scale(group, version, plural, name)



read scale of the specified custom object

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | the custom resource's group
version = 'version_example' # String | the custom resource's version
plural = 'plural_example' # String | the custom resource's plural name. For TPRs this would be lowercase plural kind.
name = 'name_example' # String | the custom object's name

begin
  
  result = api_instance.get_cluster_custom_object_scale(group, version, plural, name)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->get_cluster_custom_object_scale: #{e}"
end
```

#### Using the get_cluster_custom_object_scale_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> get_cluster_custom_object_scale_with_http_info(group, version, plural, name)

```ruby
begin
  
  data, status_code, headers = api_instance.get_cluster_custom_object_scale_with_http_info(group, version, plural, name)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->get_cluster_custom_object_scale_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | the custom resource&#39;s group |  |
| **version** | **String** | the custom resource&#39;s version |  |
| **plural** | **String** | the custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **name** | **String** | the custom object&#39;s name |  |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json, application/yaml, application/vnd.kubernetes.protobuf


## get_cluster_custom_object_status

> Object get_cluster_custom_object_status(group, version, plural, name)



read status of the specified cluster scoped custom object

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | the custom resource's group
version = 'version_example' # String | the custom resource's version
plural = 'plural_example' # String | the custom resource's plural name. For TPRs this would be lowercase plural kind.
name = 'name_example' # String | the custom object's name

begin
  
  result = api_instance.get_cluster_custom_object_status(group, version, plural, name)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->get_cluster_custom_object_status: #{e}"
end
```

#### Using the get_cluster_custom_object_status_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> get_cluster_custom_object_status_with_http_info(group, version, plural, name)

```ruby
begin
  
  data, status_code, headers = api_instance.get_cluster_custom_object_status_with_http_info(group, version, plural, name)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->get_cluster_custom_object_status_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | the custom resource&#39;s group |  |
| **version** | **String** | the custom resource&#39;s version |  |
| **plural** | **String** | the custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **name** | **String** | the custom object&#39;s name |  |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json, application/yaml, application/vnd.kubernetes.protobuf


## get_namespaced_custom_object

> Object get_namespaced_custom_object(group, version, namespace, plural, name)



Returns a namespace scoped custom object

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | the custom resource's group
version = 'version_example' # String | the custom resource's version
namespace = 'namespace_example' # String | The custom resource's namespace
plural = 'plural_example' # String | the custom resource's plural name. For TPRs this would be lowercase plural kind.
name = 'name_example' # String | the custom object's name

begin
  
  result = api_instance.get_namespaced_custom_object(group, version, namespace, plural, name)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->get_namespaced_custom_object: #{e}"
end
```

#### Using the get_namespaced_custom_object_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> get_namespaced_custom_object_with_http_info(group, version, namespace, plural, name)

```ruby
begin
  
  data, status_code, headers = api_instance.get_namespaced_custom_object_with_http_info(group, version, namespace, plural, name)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->get_namespaced_custom_object_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | the custom resource&#39;s group |  |
| **version** | **String** | the custom resource&#39;s version |  |
| **namespace** | **String** | The custom resource&#39;s namespace |  |
| **plural** | **String** | the custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **name** | **String** | the custom object&#39;s name |  |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## get_namespaced_custom_object_scale

> Object get_namespaced_custom_object_scale(group, version, namespace, plural, name)



read scale of the specified namespace scoped custom object

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | the custom resource's group
version = 'version_example' # String | the custom resource's version
namespace = 'namespace_example' # String | The custom resource's namespace
plural = 'plural_example' # String | the custom resource's plural name. For TPRs this would be lowercase plural kind.
name = 'name_example' # String | the custom object's name

begin
  
  result = api_instance.get_namespaced_custom_object_scale(group, version, namespace, plural, name)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->get_namespaced_custom_object_scale: #{e}"
end
```

#### Using the get_namespaced_custom_object_scale_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> get_namespaced_custom_object_scale_with_http_info(group, version, namespace, plural, name)

```ruby
begin
  
  data, status_code, headers = api_instance.get_namespaced_custom_object_scale_with_http_info(group, version, namespace, plural, name)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->get_namespaced_custom_object_scale_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | the custom resource&#39;s group |  |
| **version** | **String** | the custom resource&#39;s version |  |
| **namespace** | **String** | The custom resource&#39;s namespace |  |
| **plural** | **String** | the custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **name** | **String** | the custom object&#39;s name |  |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json, application/yaml, application/vnd.kubernetes.protobuf


## get_namespaced_custom_object_status

> Object get_namespaced_custom_object_status(group, version, namespace, plural, name)



read status of the specified namespace scoped custom object

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | the custom resource's group
version = 'version_example' # String | the custom resource's version
namespace = 'namespace_example' # String | The custom resource's namespace
plural = 'plural_example' # String | the custom resource's plural name. For TPRs this would be lowercase plural kind.
name = 'name_example' # String | the custom object's name

begin
  
  result = api_instance.get_namespaced_custom_object_status(group, version, namespace, plural, name)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->get_namespaced_custom_object_status: #{e}"
end
```

#### Using the get_namespaced_custom_object_status_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> get_namespaced_custom_object_status_with_http_info(group, version, namespace, plural, name)

```ruby
begin
  
  data, status_code, headers = api_instance.get_namespaced_custom_object_status_with_http_info(group, version, namespace, plural, name)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->get_namespaced_custom_object_status_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | the custom resource&#39;s group |  |
| **version** | **String** | the custom resource&#39;s version |  |
| **namespace** | **String** | The custom resource&#39;s namespace |  |
| **plural** | **String** | the custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **name** | **String** | the custom object&#39;s name |  |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json, application/yaml, application/vnd.kubernetes.protobuf


## list_cluster_custom_object

> Object list_cluster_custom_object(group, version, plural, opts)



list or watch cluster scoped custom objects

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | The custom resource's group name
version = 'version_example' # String | The custom resource's version
plural = 'plural_example' # String | The custom resource's plural name. For TPRs this would be lowercase plural kind.
opts = {
  pretty: 'pretty_example', # String | If 'true', then the output is pretty printed.
  allow_watch_bookmarks: true, # Boolean | allowWatchBookmarks requests watch events with type \"BOOKMARK\". Servers that do not implement bookmarks may ignore this flag and bookmarks are sent at the server's discretion. Clients should not assume bookmarks are returned at any specific interval, nor may they assume the server will send any BOOKMARK event during a session. If this is not a watch, this field is ignored. If the feature gate WatchBookmarks is not enabled in apiserver, this field is ignored.
  continue: 'continue_example', # String | The continue option should be set when retrieving more results from the server. Since this value is server defined, clients may only use the continue value from a previous query result with identical query parameters (except for the value of continue) and the server may reject a continue value it does not recognize. If the specified continue value is no longer valid whether due to expiration (generally five to fifteen minutes) or a configuration change on the server, the server will respond with a 410 ResourceExpired error together with a continue token. If the client needs a consistent list, it must restart their list without the continue field. Otherwise, the client may send another list request with the token received with the 410 error, the server will respond with a list starting from the next key, but from the latest snapshot, which is inconsistent from the previous list results - objects that are created, modified, or deleted after the first list request will be included in the response, as long as their keys are after the \"next key\".  This field is not supported when watch is true. Clients may start a watch from the last resourceVersion value returned by the server and not miss any modifications.
  field_selector: 'field_selector_example', # String | A selector to restrict the list of returned objects by their fields. Defaults to everything.
  label_selector: 'label_selector_example', # String | A selector to restrict the list of returned objects by their labels. Defaults to everything.
  limit: 56, # Integer | limit is a maximum number of responses to return for a list call. If more items exist, the server will set the `continue` field on the list metadata to a value that can be used with the same initial query to retrieve the next set of results. Setting a limit may return fewer than the requested amount of items (up to zero items) in the event all requested objects are filtered out and clients should only use the presence of the continue field to determine whether more results are available. Servers may choose not to support the limit argument and will return all of the available results. If limit is specified and the continue field is empty, clients may assume that no more results are available. This field is not supported if watch is true.  The server guarantees that the objects returned when using continue will be identical to issuing a single list call without a limit - that is, no objects created, modified, or deleted after the first request is issued will be included in any subsequent continued requests. This is sometimes referred to as a consistent snapshot, and ensures that a client that is using limit to receive smaller chunks of a very large result can ensure they see all possible objects. If objects are updated during a chunked list the version of the object that was present at the time the first list result was calculated is returned.
  resource_version: 'resource_version_example', # String | When specified with a watch call, shows changes that occur after that particular version of a resource. Defaults to changes from the beginning of history. When specified for list: - if unset, then the result is returned from remote storage based on quorum-read flag; - if it's 0, then we simply return what we currently have in cache, no guarantee; - if set to non zero, then the result is at least as fresh as given rv.
  resource_version_match: 'resource_version_match_example', # String | resourceVersionMatch determines how resourceVersion is applied to list calls. It is highly recommended that resourceVersionMatch be set for list calls where resourceVersion is set See https://kubernetes.io/docs/reference/using-api/api-concepts/#resource-versions for details.  Defaults to unset
  timeout_seconds: 56, # Integer | Timeout for the list/watch call. This limits the duration of the call, regardless of any activity or inactivity.
  watch: true # Boolean | Watch for changes to the described resources and return them as a stream of add, update, and remove notifications.
}

begin
  
  result = api_instance.list_cluster_custom_object(group, version, plural, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->list_cluster_custom_object: #{e}"
end
```

#### Using the list_cluster_custom_object_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> list_cluster_custom_object_with_http_info(group, version, plural, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.list_cluster_custom_object_with_http_info(group, version, plural, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->list_cluster_custom_object_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | The custom resource&#39;s group name |  |
| **version** | **String** | The custom resource&#39;s version |  |
| **plural** | **String** | The custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **pretty** | **String** | If &#39;true&#39;, then the output is pretty printed. | [optional] |
| **allow_watch_bookmarks** | **Boolean** | allowWatchBookmarks requests watch events with type \&quot;BOOKMARK\&quot;. Servers that do not implement bookmarks may ignore this flag and bookmarks are sent at the server&#39;s discretion. Clients should not assume bookmarks are returned at any specific interval, nor may they assume the server will send any BOOKMARK event during a session. If this is not a watch, this field is ignored. If the feature gate WatchBookmarks is not enabled in apiserver, this field is ignored. | [optional] |
| **continue** | **String** | The continue option should be set when retrieving more results from the server. Since this value is server defined, clients may only use the continue value from a previous query result with identical query parameters (except for the value of continue) and the server may reject a continue value it does not recognize. If the specified continue value is no longer valid whether due to expiration (generally five to fifteen minutes) or a configuration change on the server, the server will respond with a 410 ResourceExpired error together with a continue token. If the client needs a consistent list, it must restart their list without the continue field. Otherwise, the client may send another list request with the token received with the 410 error, the server will respond with a list starting from the next key, but from the latest snapshot, which is inconsistent from the previous list results - objects that are created, modified, or deleted after the first list request will be included in the response, as long as their keys are after the \&quot;next key\&quot;.  This field is not supported when watch is true. Clients may start a watch from the last resourceVersion value returned by the server and not miss any modifications. | [optional] |
| **field_selector** | **String** | A selector to restrict the list of returned objects by their fields. Defaults to everything. | [optional] |
| **label_selector** | **String** | A selector to restrict the list of returned objects by their labels. Defaults to everything. | [optional] |
| **limit** | **Integer** | limit is a maximum number of responses to return for a list call. If more items exist, the server will set the &#x60;continue&#x60; field on the list metadata to a value that can be used with the same initial query to retrieve the next set of results. Setting a limit may return fewer than the requested amount of items (up to zero items) in the event all requested objects are filtered out and clients should only use the presence of the continue field to determine whether more results are available. Servers may choose not to support the limit argument and will return all of the available results. If limit is specified and the continue field is empty, clients may assume that no more results are available. This field is not supported if watch is true.  The server guarantees that the objects returned when using continue will be identical to issuing a single list call without a limit - that is, no objects created, modified, or deleted after the first request is issued will be included in any subsequent continued requests. This is sometimes referred to as a consistent snapshot, and ensures that a client that is using limit to receive smaller chunks of a very large result can ensure they see all possible objects. If objects are updated during a chunked list the version of the object that was present at the time the first list result was calculated is returned. | [optional] |
| **resource_version** | **String** | When specified with a watch call, shows changes that occur after that particular version of a resource. Defaults to changes from the beginning of history. When specified for list: - if unset, then the result is returned from remote storage based on quorum-read flag; - if it&#39;s 0, then we simply return what we currently have in cache, no guarantee; - if set to non zero, then the result is at least as fresh as given rv. | [optional] |
| **resource_version_match** | **String** | resourceVersionMatch determines how resourceVersion is applied to list calls. It is highly recommended that resourceVersionMatch be set for list calls where resourceVersion is set See https://kubernetes.io/docs/reference/using-api/api-concepts/#resource-versions for details.  Defaults to unset | [optional] |
| **timeout_seconds** | **Integer** | Timeout for the list/watch call. This limits the duration of the call, regardless of any activity or inactivity. | [optional] |
| **watch** | **Boolean** | Watch for changes to the described resources and return them as a stream of add, update, and remove notifications. | [optional] |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json, application/json;stream=watch


## list_custom_object_for_all_namespaces

> Object list_custom_object_for_all_namespaces(group, version, resource_plural, opts)



list or watch namespace scoped custom objects

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | The custom resource's group name
version = 'version_example' # String | The custom resource's version
resource_plural = 'resource_plural_example' # String | The custom resource's plural name. For TPRs this would be lowercase plural kind.
opts = {
  pretty: 'pretty_example', # String | If 'true', then the output is pretty printed.
  allow_watch_bookmarks: true, # Boolean | allowWatchBookmarks requests watch events with type \"BOOKMARK\". Servers that do not implement bookmarks may ignore this flag and bookmarks are sent at the server's discretion. Clients should not assume bookmarks are returned at any specific interval, nor may they assume the server will send any BOOKMARK event during a session. If this is not a watch, this field is ignored. If the feature gate WatchBookmarks is not enabled in apiserver, this field is ignored.
  continue: 'continue_example', # String | The continue option should be set when retrieving more results from the server. Since this value is server defined, clients may only use the continue value from a previous query result with identical query parameters (except for the value of continue) and the server may reject a continue value it does not recognize. If the specified continue value is no longer valid whether due to expiration (generally five to fifteen minutes) or a configuration change on the server, the server will respond with a 410 ResourceExpired error together with a continue token. If the client needs a consistent list, it must restart their list without the continue field. Otherwise, the client may send another list request with the token received with the 410 error, the server will respond with a list starting from the next key, but from the latest snapshot, which is inconsistent from the previous list results - objects that are created, modified, or deleted after the first list request will be included in the response, as long as their keys are after the \"next key\".  This field is not supported when watch is true. Clients may start a watch from the last resourceVersion value returned by the server and not miss any modifications.
  field_selector: 'field_selector_example', # String | A selector to restrict the list of returned objects by their fields. Defaults to everything.
  label_selector: 'label_selector_example', # String | A selector to restrict the list of returned objects by their labels. Defaults to everything.
  limit: 56, # Integer | limit is a maximum number of responses to return for a list call. If more items exist, the server will set the `continue` field on the list metadata to a value that can be used with the same initial query to retrieve the next set of results. Setting a limit may return fewer than the requested amount of items (up to zero items) in the event all requested objects are filtered out and clients should only use the presence of the continue field to determine whether more results are available. Servers may choose not to support the limit argument and will return all of the available results. If limit is specified and the continue field is empty, clients may assume that no more results are available. This field is not supported if watch is true.  The server guarantees that the objects returned when using continue will be identical to issuing a single list call without a limit - that is, no objects created, modified, or deleted after the first request is issued will be included in any subsequent continued requests. This is sometimes referred to as a consistent snapshot, and ensures that a client that is using limit to receive smaller chunks of a very large result can ensure they see all possible objects. If objects are updated during a chunked list the version of the object that was present at the time the first list result was calculated is returned.
  resource_version: 'resource_version_example', # String | When specified with a watch call, shows changes that occur after that particular version of a resource. Defaults to changes from the beginning of history. When specified for list: - if unset, then the result is returned from remote storage based on quorum-read flag; - if it's 0, then we simply return what we currently have in cache, no guarantee; - if set to non zero, then the result is at least as fresh as given rv.
  resource_version_match: 'resource_version_match_example', # String | resourceVersionMatch determines how resourceVersion is applied to list calls. It is highly recommended that resourceVersionMatch be set for list calls where resourceVersion is set See https://kubernetes.io/docs/reference/using-api/api-concepts/#resource-versions for details.  Defaults to unset
  timeout_seconds: 56, # Integer | Timeout for the list/watch call. This limits the duration of the call, regardless of any activity or inactivity.
  watch: true # Boolean | Watch for changes to the described resources and return them as a stream of add, update, and remove notifications.
}

begin
  
  result = api_instance.list_custom_object_for_all_namespaces(group, version, resource_plural, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->list_custom_object_for_all_namespaces: #{e}"
end
```

#### Using the list_custom_object_for_all_namespaces_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> list_custom_object_for_all_namespaces_with_http_info(group, version, resource_plural, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.list_custom_object_for_all_namespaces_with_http_info(group, version, resource_plural, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->list_custom_object_for_all_namespaces_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | The custom resource&#39;s group name |  |
| **version** | **String** | The custom resource&#39;s version |  |
| **resource_plural** | **String** | The custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **pretty** | **String** | If &#39;true&#39;, then the output is pretty printed. | [optional] |
| **allow_watch_bookmarks** | **Boolean** | allowWatchBookmarks requests watch events with type \&quot;BOOKMARK\&quot;. Servers that do not implement bookmarks may ignore this flag and bookmarks are sent at the server&#39;s discretion. Clients should not assume bookmarks are returned at any specific interval, nor may they assume the server will send any BOOKMARK event during a session. If this is not a watch, this field is ignored. If the feature gate WatchBookmarks is not enabled in apiserver, this field is ignored. | [optional] |
| **continue** | **String** | The continue option should be set when retrieving more results from the server. Since this value is server defined, clients may only use the continue value from a previous query result with identical query parameters (except for the value of continue) and the server may reject a continue value it does not recognize. If the specified continue value is no longer valid whether due to expiration (generally five to fifteen minutes) or a configuration change on the server, the server will respond with a 410 ResourceExpired error together with a continue token. If the client needs a consistent list, it must restart their list without the continue field. Otherwise, the client may send another list request with the token received with the 410 error, the server will respond with a list starting from the next key, but from the latest snapshot, which is inconsistent from the previous list results - objects that are created, modified, or deleted after the first list request will be included in the response, as long as their keys are after the \&quot;next key\&quot;.  This field is not supported when watch is true. Clients may start a watch from the last resourceVersion value returned by the server and not miss any modifications. | [optional] |
| **field_selector** | **String** | A selector to restrict the list of returned objects by their fields. Defaults to everything. | [optional] |
| **label_selector** | **String** | A selector to restrict the list of returned objects by their labels. Defaults to everything. | [optional] |
| **limit** | **Integer** | limit is a maximum number of responses to return for a list call. If more items exist, the server will set the &#x60;continue&#x60; field on the list metadata to a value that can be used with the same initial query to retrieve the next set of results. Setting a limit may return fewer than the requested amount of items (up to zero items) in the event all requested objects are filtered out and clients should only use the presence of the continue field to determine whether more results are available. Servers may choose not to support the limit argument and will return all of the available results. If limit is specified and the continue field is empty, clients may assume that no more results are available. This field is not supported if watch is true.  The server guarantees that the objects returned when using continue will be identical to issuing a single list call without a limit - that is, no objects created, modified, or deleted after the first request is issued will be included in any subsequent continued requests. This is sometimes referred to as a consistent snapshot, and ensures that a client that is using limit to receive smaller chunks of a very large result can ensure they see all possible objects. If objects are updated during a chunked list the version of the object that was present at the time the first list result was calculated is returned. | [optional] |
| **resource_version** | **String** | When specified with a watch call, shows changes that occur after that particular version of a resource. Defaults to changes from the beginning of history. When specified for list: - if unset, then the result is returned from remote storage based on quorum-read flag; - if it&#39;s 0, then we simply return what we currently have in cache, no guarantee; - if set to non zero, then the result is at least as fresh as given rv. | [optional] |
| **resource_version_match** | **String** | resourceVersionMatch determines how resourceVersion is applied to list calls. It is highly recommended that resourceVersionMatch be set for list calls where resourceVersion is set See https://kubernetes.io/docs/reference/using-api/api-concepts/#resource-versions for details.  Defaults to unset | [optional] |
| **timeout_seconds** | **Integer** | Timeout for the list/watch call. This limits the duration of the call, regardless of any activity or inactivity. | [optional] |
| **watch** | **Boolean** | Watch for changes to the described resources and return them as a stream of add, update, and remove notifications. | [optional] |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json, application/json;stream=watch


## list_namespaced_custom_object

> Object list_namespaced_custom_object(group, version, namespace, plural, opts)



list or watch namespace scoped custom objects

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | The custom resource's group name
version = 'version_example' # String | The custom resource's version
namespace = 'namespace_example' # String | The custom resource's namespace
plural = 'plural_example' # String | The custom resource's plural name. For TPRs this would be lowercase plural kind.
opts = {
  pretty: 'pretty_example', # String | If 'true', then the output is pretty printed.
  allow_watch_bookmarks: true, # Boolean | allowWatchBookmarks requests watch events with type \"BOOKMARK\". Servers that do not implement bookmarks may ignore this flag and bookmarks are sent at the server's discretion. Clients should not assume bookmarks are returned at any specific interval, nor may they assume the server will send any BOOKMARK event during a session. If this is not a watch, this field is ignored. If the feature gate WatchBookmarks is not enabled in apiserver, this field is ignored.
  continue: 'continue_example', # String | The continue option should be set when retrieving more results from the server. Since this value is server defined, clients may only use the continue value from a previous query result with identical query parameters (except for the value of continue) and the server may reject a continue value it does not recognize. If the specified continue value is no longer valid whether due to expiration (generally five to fifteen minutes) or a configuration change on the server, the server will respond with a 410 ResourceExpired error together with a continue token. If the client needs a consistent list, it must restart their list without the continue field. Otherwise, the client may send another list request with the token received with the 410 error, the server will respond with a list starting from the next key, but from the latest snapshot, which is inconsistent from the previous list results - objects that are created, modified, or deleted after the first list request will be included in the response, as long as their keys are after the \"next key\".  This field is not supported when watch is true. Clients may start a watch from the last resourceVersion value returned by the server and not miss any modifications.
  field_selector: 'field_selector_example', # String | A selector to restrict the list of returned objects by their fields. Defaults to everything.
  label_selector: 'label_selector_example', # String | A selector to restrict the list of returned objects by their labels. Defaults to everything.
  limit: 56, # Integer | limit is a maximum number of responses to return for a list call. If more items exist, the server will set the `continue` field on the list metadata to a value that can be used with the same initial query to retrieve the next set of results. Setting a limit may return fewer than the requested amount of items (up to zero items) in the event all requested objects are filtered out and clients should only use the presence of the continue field to determine whether more results are available. Servers may choose not to support the limit argument and will return all of the available results. If limit is specified and the continue field is empty, clients may assume that no more results are available. This field is not supported if watch is true.  The server guarantees that the objects returned when using continue will be identical to issuing a single list call without a limit - that is, no objects created, modified, or deleted after the first request is issued will be included in any subsequent continued requests. This is sometimes referred to as a consistent snapshot, and ensures that a client that is using limit to receive smaller chunks of a very large result can ensure they see all possible objects. If objects are updated during a chunked list the version of the object that was present at the time the first list result was calculated is returned.
  resource_version: 'resource_version_example', # String | When specified with a watch call, shows changes that occur after that particular version of a resource. Defaults to changes from the beginning of history. When specified for list: - if unset, then the result is returned from remote storage based on quorum-read flag; - if it's 0, then we simply return what we currently have in cache, no guarantee; - if set to non zero, then the result is at least as fresh as given rv.
  resource_version_match: 'resource_version_match_example', # String | resourceVersionMatch determines how resourceVersion is applied to list calls. It is highly recommended that resourceVersionMatch be set for list calls where resourceVersion is set See https://kubernetes.io/docs/reference/using-api/api-concepts/#resource-versions for details.  Defaults to unset
  timeout_seconds: 56, # Integer | Timeout for the list/watch call. This limits the duration of the call, regardless of any activity or inactivity.
  watch: true # Boolean | Watch for changes to the described resources and return them as a stream of add, update, and remove notifications.
}

begin
  
  result = api_instance.list_namespaced_custom_object(group, version, namespace, plural, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->list_namespaced_custom_object: #{e}"
end
```

#### Using the list_namespaced_custom_object_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> list_namespaced_custom_object_with_http_info(group, version, namespace, plural, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.list_namespaced_custom_object_with_http_info(group, version, namespace, plural, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->list_namespaced_custom_object_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | The custom resource&#39;s group name |  |
| **version** | **String** | The custom resource&#39;s version |  |
| **namespace** | **String** | The custom resource&#39;s namespace |  |
| **plural** | **String** | The custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **pretty** | **String** | If &#39;true&#39;, then the output is pretty printed. | [optional] |
| **allow_watch_bookmarks** | **Boolean** | allowWatchBookmarks requests watch events with type \&quot;BOOKMARK\&quot;. Servers that do not implement bookmarks may ignore this flag and bookmarks are sent at the server&#39;s discretion. Clients should not assume bookmarks are returned at any specific interval, nor may they assume the server will send any BOOKMARK event during a session. If this is not a watch, this field is ignored. If the feature gate WatchBookmarks is not enabled in apiserver, this field is ignored. | [optional] |
| **continue** | **String** | The continue option should be set when retrieving more results from the server. Since this value is server defined, clients may only use the continue value from a previous query result with identical query parameters (except for the value of continue) and the server may reject a continue value it does not recognize. If the specified continue value is no longer valid whether due to expiration (generally five to fifteen minutes) or a configuration change on the server, the server will respond with a 410 ResourceExpired error together with a continue token. If the client needs a consistent list, it must restart their list without the continue field. Otherwise, the client may send another list request with the token received with the 410 error, the server will respond with a list starting from the next key, but from the latest snapshot, which is inconsistent from the previous list results - objects that are created, modified, or deleted after the first list request will be included in the response, as long as their keys are after the \&quot;next key\&quot;.  This field is not supported when watch is true. Clients may start a watch from the last resourceVersion value returned by the server and not miss any modifications. | [optional] |
| **field_selector** | **String** | A selector to restrict the list of returned objects by their fields. Defaults to everything. | [optional] |
| **label_selector** | **String** | A selector to restrict the list of returned objects by their labels. Defaults to everything. | [optional] |
| **limit** | **Integer** | limit is a maximum number of responses to return for a list call. If more items exist, the server will set the &#x60;continue&#x60; field on the list metadata to a value that can be used with the same initial query to retrieve the next set of results. Setting a limit may return fewer than the requested amount of items (up to zero items) in the event all requested objects are filtered out and clients should only use the presence of the continue field to determine whether more results are available. Servers may choose not to support the limit argument and will return all of the available results. If limit is specified and the continue field is empty, clients may assume that no more results are available. This field is not supported if watch is true.  The server guarantees that the objects returned when using continue will be identical to issuing a single list call without a limit - that is, no objects created, modified, or deleted after the first request is issued will be included in any subsequent continued requests. This is sometimes referred to as a consistent snapshot, and ensures that a client that is using limit to receive smaller chunks of a very large result can ensure they see all possible objects. If objects are updated during a chunked list the version of the object that was present at the time the first list result was calculated is returned. | [optional] |
| **resource_version** | **String** | When specified with a watch call, shows changes that occur after that particular version of a resource. Defaults to changes from the beginning of history. When specified for list: - if unset, then the result is returned from remote storage based on quorum-read flag; - if it&#39;s 0, then we simply return what we currently have in cache, no guarantee; - if set to non zero, then the result is at least as fresh as given rv. | [optional] |
| **resource_version_match** | **String** | resourceVersionMatch determines how resourceVersion is applied to list calls. It is highly recommended that resourceVersionMatch be set for list calls where resourceVersion is set See https://kubernetes.io/docs/reference/using-api/api-concepts/#resource-versions for details.  Defaults to unset | [optional] |
| **timeout_seconds** | **Integer** | Timeout for the list/watch call. This limits the duration of the call, regardless of any activity or inactivity. | [optional] |
| **watch** | **Boolean** | Watch for changes to the described resources and return them as a stream of add, update, and remove notifications. | [optional] |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json, application/json;stream=watch


## patch_cluster_custom_object

> Object patch_cluster_custom_object(group, version, plural, name, body, opts)



patch the specified cluster scoped custom object

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | the custom resource's group
version = 'version_example' # String | the custom resource's version
plural = 'plural_example' # String | the custom object's plural name. For TPRs this would be lowercase plural kind.
name = 'name_example' # String | the custom object's name
body = Object # Object | The JSON schema of the Resource to patch.
opts = {
  dry_run: 'dry_run_example', # String | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed
  field_manager: 'field_manager_example', # String | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. This field is required for apply requests (application/apply-patch) but optional for non-apply patch types (JsonPatch, MergePatch, StrategicMergePatch).
  field_validation: 'field_validation_example', # String | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional)
  force: true # Boolean | Force is going to \"force\" Apply requests. It means user will re-acquire conflicting fields owned by other people. Force flag must be unset for non-apply patch requests.
}

begin
  
  result = api_instance.patch_cluster_custom_object(group, version, plural, name, body, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->patch_cluster_custom_object: #{e}"
end
```

#### Using the patch_cluster_custom_object_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> patch_cluster_custom_object_with_http_info(group, version, plural, name, body, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.patch_cluster_custom_object_with_http_info(group, version, plural, name, body, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->patch_cluster_custom_object_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | the custom resource&#39;s group |  |
| **version** | **String** | the custom resource&#39;s version |  |
| **plural** | **String** | the custom object&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **name** | **String** | the custom object&#39;s name |  |
| **body** | **Object** | The JSON schema of the Resource to patch. |  |
| **dry_run** | **String** | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed | [optional] |
| **field_manager** | **String** | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. This field is required for apply requests (application/apply-patch) but optional for non-apply patch types (JsonPatch, MergePatch, StrategicMergePatch). | [optional] |
| **field_validation** | **String** | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional) | [optional] |
| **force** | **Boolean** | Force is going to \&quot;force\&quot; Apply requests. It means user will re-acquire conflicting fields owned by other people. Force flag must be unset for non-apply patch requests. | [optional] |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: application/json-patch+json, application/merge-patch+json
- **Accept**: application/json


## patch_cluster_custom_object_scale

> Object patch_cluster_custom_object_scale(group, version, plural, name, body, opts)



partially update scale of the specified cluster scoped custom object

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | the custom resource's group
version = 'version_example' # String | the custom resource's version
plural = 'plural_example' # String | the custom resource's plural name. For TPRs this would be lowercase plural kind.
name = 'name_example' # String | the custom object's name
body = Object # Object | 
opts = {
  dry_run: 'dry_run_example', # String | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed
  field_manager: 'field_manager_example', # String | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. This field is required for apply requests (application/apply-patch) but optional for non-apply patch types (JsonPatch, MergePatch, StrategicMergePatch).
  field_validation: 'field_validation_example', # String | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional)
  force: true # Boolean | Force is going to \"force\" Apply requests. It means user will re-acquire conflicting fields owned by other people. Force flag must be unset for non-apply patch requests.
}

begin
  
  result = api_instance.patch_cluster_custom_object_scale(group, version, plural, name, body, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->patch_cluster_custom_object_scale: #{e}"
end
```

#### Using the patch_cluster_custom_object_scale_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> patch_cluster_custom_object_scale_with_http_info(group, version, plural, name, body, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.patch_cluster_custom_object_scale_with_http_info(group, version, plural, name, body, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->patch_cluster_custom_object_scale_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | the custom resource&#39;s group |  |
| **version** | **String** | the custom resource&#39;s version |  |
| **plural** | **String** | the custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **name** | **String** | the custom object&#39;s name |  |
| **body** | **Object** |  |  |
| **dry_run** | **String** | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed | [optional] |
| **field_manager** | **String** | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. This field is required for apply requests (application/apply-patch) but optional for non-apply patch types (JsonPatch, MergePatch, StrategicMergePatch). | [optional] |
| **field_validation** | **String** | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional) | [optional] |
| **force** | **Boolean** | Force is going to \&quot;force\&quot; Apply requests. It means user will re-acquire conflicting fields owned by other people. Force flag must be unset for non-apply patch requests. | [optional] |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: application/json-patch+json, application/merge-patch+json
- **Accept**: application/json, application/yaml, application/vnd.kubernetes.protobuf


## patch_cluster_custom_object_status

> Object patch_cluster_custom_object_status(group, version, plural, name, body, opts)



partially update status of the specified cluster scoped custom object

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | the custom resource's group
version = 'version_example' # String | the custom resource's version
plural = 'plural_example' # String | the custom resource's plural name. For TPRs this would be lowercase plural kind.
name = 'name_example' # String | the custom object's name
body = Object # Object | 
opts = {
  dry_run: 'dry_run_example', # String | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed
  field_manager: 'field_manager_example', # String | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. This field is required for apply requests (application/apply-patch) but optional for non-apply patch types (JsonPatch, MergePatch, StrategicMergePatch).
  field_validation: 'field_validation_example', # String | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional)
  force: true # Boolean | Force is going to \"force\" Apply requests. It means user will re-acquire conflicting fields owned by other people. Force flag must be unset for non-apply patch requests.
}

begin
  
  result = api_instance.patch_cluster_custom_object_status(group, version, plural, name, body, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->patch_cluster_custom_object_status: #{e}"
end
```

#### Using the patch_cluster_custom_object_status_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> patch_cluster_custom_object_status_with_http_info(group, version, plural, name, body, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.patch_cluster_custom_object_status_with_http_info(group, version, plural, name, body, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->patch_cluster_custom_object_status_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | the custom resource&#39;s group |  |
| **version** | **String** | the custom resource&#39;s version |  |
| **plural** | **String** | the custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **name** | **String** | the custom object&#39;s name |  |
| **body** | **Object** |  |  |
| **dry_run** | **String** | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed | [optional] |
| **field_manager** | **String** | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. This field is required for apply requests (application/apply-patch) but optional for non-apply patch types (JsonPatch, MergePatch, StrategicMergePatch). | [optional] |
| **field_validation** | **String** | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional) | [optional] |
| **force** | **Boolean** | Force is going to \&quot;force\&quot; Apply requests. It means user will re-acquire conflicting fields owned by other people. Force flag must be unset for non-apply patch requests. | [optional] |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: application/json-patch+json, application/merge-patch+json
- **Accept**: application/json, application/yaml, application/vnd.kubernetes.protobuf


## patch_namespaced_custom_object

> Object patch_namespaced_custom_object(group, version, namespace, plural, name, body, opts)



patch the specified namespace scoped custom object

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | the custom resource's group
version = 'version_example' # String | the custom resource's version
namespace = 'namespace_example' # String | The custom resource's namespace
plural = 'plural_example' # String | the custom resource's plural name. For TPRs this would be lowercase plural kind.
name = 'name_example' # String | the custom object's name
body = Object # Object | The JSON schema of the Resource to patch.
opts = {
  dry_run: 'dry_run_example', # String | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed
  field_manager: 'field_manager_example', # String | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. This field is required for apply requests (application/apply-patch) but optional for non-apply patch types (JsonPatch, MergePatch, StrategicMergePatch).
  field_validation: 'field_validation_example', # String | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional)
  force: true # Boolean | Force is going to \"force\" Apply requests. It means user will re-acquire conflicting fields owned by other people. Force flag must be unset for non-apply patch requests.
}

begin
  
  result = api_instance.patch_namespaced_custom_object(group, version, namespace, plural, name, body, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->patch_namespaced_custom_object: #{e}"
end
```

#### Using the patch_namespaced_custom_object_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> patch_namespaced_custom_object_with_http_info(group, version, namespace, plural, name, body, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.patch_namespaced_custom_object_with_http_info(group, version, namespace, plural, name, body, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->patch_namespaced_custom_object_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | the custom resource&#39;s group |  |
| **version** | **String** | the custom resource&#39;s version |  |
| **namespace** | **String** | The custom resource&#39;s namespace |  |
| **plural** | **String** | the custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **name** | **String** | the custom object&#39;s name |  |
| **body** | **Object** | The JSON schema of the Resource to patch. |  |
| **dry_run** | **String** | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed | [optional] |
| **field_manager** | **String** | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. This field is required for apply requests (application/apply-patch) but optional for non-apply patch types (JsonPatch, MergePatch, StrategicMergePatch). | [optional] |
| **field_validation** | **String** | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional) | [optional] |
| **force** | **Boolean** | Force is going to \&quot;force\&quot; Apply requests. It means user will re-acquire conflicting fields owned by other people. Force flag must be unset for non-apply patch requests. | [optional] |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: application/json-patch+json, application/merge-patch+json
- **Accept**: application/json


## patch_namespaced_custom_object_scale

> Object patch_namespaced_custom_object_scale(group, version, namespace, plural, name, body, opts)



partially update scale of the specified namespace scoped custom object

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | the custom resource's group
version = 'version_example' # String | the custom resource's version
namespace = 'namespace_example' # String | The custom resource's namespace
plural = 'plural_example' # String | the custom resource's plural name. For TPRs this would be lowercase plural kind.
name = 'name_example' # String | the custom object's name
body = Object # Object | 
opts = {
  dry_run: 'dry_run_example', # String | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed
  field_manager: 'field_manager_example', # String | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. This field is required for apply requests (application/apply-patch) but optional for non-apply patch types (JsonPatch, MergePatch, StrategicMergePatch).
  field_validation: 'field_validation_example', # String | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional)
  force: true # Boolean | Force is going to \"force\" Apply requests. It means user will re-acquire conflicting fields owned by other people. Force flag must be unset for non-apply patch requests.
}

begin
  
  result = api_instance.patch_namespaced_custom_object_scale(group, version, namespace, plural, name, body, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->patch_namespaced_custom_object_scale: #{e}"
end
```

#### Using the patch_namespaced_custom_object_scale_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> patch_namespaced_custom_object_scale_with_http_info(group, version, namespace, plural, name, body, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.patch_namespaced_custom_object_scale_with_http_info(group, version, namespace, plural, name, body, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->patch_namespaced_custom_object_scale_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | the custom resource&#39;s group |  |
| **version** | **String** | the custom resource&#39;s version |  |
| **namespace** | **String** | The custom resource&#39;s namespace |  |
| **plural** | **String** | the custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **name** | **String** | the custom object&#39;s name |  |
| **body** | **Object** |  |  |
| **dry_run** | **String** | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed | [optional] |
| **field_manager** | **String** | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. This field is required for apply requests (application/apply-patch) but optional for non-apply patch types (JsonPatch, MergePatch, StrategicMergePatch). | [optional] |
| **field_validation** | **String** | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional) | [optional] |
| **force** | **Boolean** | Force is going to \&quot;force\&quot; Apply requests. It means user will re-acquire conflicting fields owned by other people. Force flag must be unset for non-apply patch requests. | [optional] |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: application/json-patch+json, application/merge-patch+json, application/apply-patch+yaml
- **Accept**: application/json, application/yaml, application/vnd.kubernetes.protobuf


## patch_namespaced_custom_object_status

> Object patch_namespaced_custom_object_status(group, version, namespace, plural, name, body, opts)



partially update status of the specified namespace scoped custom object

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | the custom resource's group
version = 'version_example' # String | the custom resource's version
namespace = 'namespace_example' # String | The custom resource's namespace
plural = 'plural_example' # String | the custom resource's plural name. For TPRs this would be lowercase plural kind.
name = 'name_example' # String | the custom object's name
body = Object # Object | 
opts = {
  dry_run: 'dry_run_example', # String | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed
  field_manager: 'field_manager_example', # String | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. This field is required for apply requests (application/apply-patch) but optional for non-apply patch types (JsonPatch, MergePatch, StrategicMergePatch).
  field_validation: 'field_validation_example', # String | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional)
  force: true # Boolean | Force is going to \"force\" Apply requests. It means user will re-acquire conflicting fields owned by other people. Force flag must be unset for non-apply patch requests.
}

begin
  
  result = api_instance.patch_namespaced_custom_object_status(group, version, namespace, plural, name, body, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->patch_namespaced_custom_object_status: #{e}"
end
```

#### Using the patch_namespaced_custom_object_status_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> patch_namespaced_custom_object_status_with_http_info(group, version, namespace, plural, name, body, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.patch_namespaced_custom_object_status_with_http_info(group, version, namespace, plural, name, body, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->patch_namespaced_custom_object_status_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | the custom resource&#39;s group |  |
| **version** | **String** | the custom resource&#39;s version |  |
| **namespace** | **String** | The custom resource&#39;s namespace |  |
| **plural** | **String** | the custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **name** | **String** | the custom object&#39;s name |  |
| **body** | **Object** |  |  |
| **dry_run** | **String** | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed | [optional] |
| **field_manager** | **String** | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. This field is required for apply requests (application/apply-patch) but optional for non-apply patch types (JsonPatch, MergePatch, StrategicMergePatch). | [optional] |
| **field_validation** | **String** | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional) | [optional] |
| **force** | **Boolean** | Force is going to \&quot;force\&quot; Apply requests. It means user will re-acquire conflicting fields owned by other people. Force flag must be unset for non-apply patch requests. | [optional] |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: application/json-patch+json, application/merge-patch+json, application/apply-patch+yaml
- **Accept**: application/json, application/yaml, application/vnd.kubernetes.protobuf


## replace_cluster_custom_object

> Object replace_cluster_custom_object(group, version, plural, name, body, opts)



replace the specified cluster scoped custom object

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | the custom resource's group
version = 'version_example' # String | the custom resource's version
plural = 'plural_example' # String | the custom object's plural name. For TPRs this would be lowercase plural kind.
name = 'name_example' # String | the custom object's name
body = Object # Object | The JSON schema of the Resource to replace.
opts = {
  dry_run: 'dry_run_example', # String | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed
  field_manager: 'field_manager_example', # String | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint.
  field_validation: 'field_validation_example' # String | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional)
}

begin
  
  result = api_instance.replace_cluster_custom_object(group, version, plural, name, body, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->replace_cluster_custom_object: #{e}"
end
```

#### Using the replace_cluster_custom_object_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> replace_cluster_custom_object_with_http_info(group, version, plural, name, body, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.replace_cluster_custom_object_with_http_info(group, version, plural, name, body, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->replace_cluster_custom_object_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | the custom resource&#39;s group |  |
| **version** | **String** | the custom resource&#39;s version |  |
| **plural** | **String** | the custom object&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **name** | **String** | the custom object&#39;s name |  |
| **body** | **Object** | The JSON schema of the Resource to replace. |  |
| **dry_run** | **String** | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed | [optional] |
| **field_manager** | **String** | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. | [optional] |
| **field_validation** | **String** | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional) | [optional] |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## replace_cluster_custom_object_scale

> Object replace_cluster_custom_object_scale(group, version, plural, name, body, opts)



replace scale of the specified cluster scoped custom object

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | the custom resource's group
version = 'version_example' # String | the custom resource's version
plural = 'plural_example' # String | the custom resource's plural name. For TPRs this would be lowercase plural kind.
name = 'name_example' # String | the custom object's name
body = Object # Object | 
opts = {
  dry_run: 'dry_run_example', # String | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed
  field_manager: 'field_manager_example', # String | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint.
  field_validation: 'field_validation_example' # String | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional)
}

begin
  
  result = api_instance.replace_cluster_custom_object_scale(group, version, plural, name, body, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->replace_cluster_custom_object_scale: #{e}"
end
```

#### Using the replace_cluster_custom_object_scale_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> replace_cluster_custom_object_scale_with_http_info(group, version, plural, name, body, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.replace_cluster_custom_object_scale_with_http_info(group, version, plural, name, body, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->replace_cluster_custom_object_scale_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | the custom resource&#39;s group |  |
| **version** | **String** | the custom resource&#39;s version |  |
| **plural** | **String** | the custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **name** | **String** | the custom object&#39;s name |  |
| **body** | **Object** |  |  |
| **dry_run** | **String** | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed | [optional] |
| **field_manager** | **String** | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. | [optional] |
| **field_validation** | **String** | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional) | [optional] |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json, application/yaml, application/vnd.kubernetes.protobuf


## replace_cluster_custom_object_status

> Object replace_cluster_custom_object_status(group, version, plural, name, body, opts)



replace status of the cluster scoped specified custom object

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | the custom resource's group
version = 'version_example' # String | the custom resource's version
plural = 'plural_example' # String | the custom resource's plural name. For TPRs this would be lowercase plural kind.
name = 'name_example' # String | the custom object's name
body = Object # Object | 
opts = {
  dry_run: 'dry_run_example', # String | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed
  field_manager: 'field_manager_example', # String | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint.
  field_validation: 'field_validation_example' # String | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional)
}

begin
  
  result = api_instance.replace_cluster_custom_object_status(group, version, plural, name, body, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->replace_cluster_custom_object_status: #{e}"
end
```

#### Using the replace_cluster_custom_object_status_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> replace_cluster_custom_object_status_with_http_info(group, version, plural, name, body, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.replace_cluster_custom_object_status_with_http_info(group, version, plural, name, body, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->replace_cluster_custom_object_status_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | the custom resource&#39;s group |  |
| **version** | **String** | the custom resource&#39;s version |  |
| **plural** | **String** | the custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **name** | **String** | the custom object&#39;s name |  |
| **body** | **Object** |  |  |
| **dry_run** | **String** | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed | [optional] |
| **field_manager** | **String** | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. | [optional] |
| **field_validation** | **String** | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional) | [optional] |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json, application/yaml, application/vnd.kubernetes.protobuf


## replace_namespaced_custom_object

> Object replace_namespaced_custom_object(group, version, namespace, plural, name, body, opts)



replace the specified namespace scoped custom object

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | the custom resource's group
version = 'version_example' # String | the custom resource's version
namespace = 'namespace_example' # String | The custom resource's namespace
plural = 'plural_example' # String | the custom resource's plural name. For TPRs this would be lowercase plural kind.
name = 'name_example' # String | the custom object's name
body = Object # Object | The JSON schema of the Resource to replace.
opts = {
  dry_run: 'dry_run_example', # String | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed
  field_manager: 'field_manager_example', # String | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint.
  field_validation: 'field_validation_example' # String | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional)
}

begin
  
  result = api_instance.replace_namespaced_custom_object(group, version, namespace, plural, name, body, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->replace_namespaced_custom_object: #{e}"
end
```

#### Using the replace_namespaced_custom_object_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> replace_namespaced_custom_object_with_http_info(group, version, namespace, plural, name, body, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.replace_namespaced_custom_object_with_http_info(group, version, namespace, plural, name, body, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->replace_namespaced_custom_object_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | the custom resource&#39;s group |  |
| **version** | **String** | the custom resource&#39;s version |  |
| **namespace** | **String** | The custom resource&#39;s namespace |  |
| **plural** | **String** | the custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **name** | **String** | the custom object&#39;s name |  |
| **body** | **Object** | The JSON schema of the Resource to replace. |  |
| **dry_run** | **String** | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed | [optional] |
| **field_manager** | **String** | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. | [optional] |
| **field_validation** | **String** | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional) | [optional] |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


## replace_namespaced_custom_object_scale

> Object replace_namespaced_custom_object_scale(group, version, namespace, plural, name, body, opts)



replace scale of the specified namespace scoped custom object

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | the custom resource's group
version = 'version_example' # String | the custom resource's version
namespace = 'namespace_example' # String | The custom resource's namespace
plural = 'plural_example' # String | the custom resource's plural name. For TPRs this would be lowercase plural kind.
name = 'name_example' # String | the custom object's name
body = Object # Object | 
opts = {
  dry_run: 'dry_run_example', # String | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed
  field_manager: 'field_manager_example', # String | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint.
  field_validation: 'field_validation_example' # String | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional)
}

begin
  
  result = api_instance.replace_namespaced_custom_object_scale(group, version, namespace, plural, name, body, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->replace_namespaced_custom_object_scale: #{e}"
end
```

#### Using the replace_namespaced_custom_object_scale_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> replace_namespaced_custom_object_scale_with_http_info(group, version, namespace, plural, name, body, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.replace_namespaced_custom_object_scale_with_http_info(group, version, namespace, plural, name, body, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->replace_namespaced_custom_object_scale_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | the custom resource&#39;s group |  |
| **version** | **String** | the custom resource&#39;s version |  |
| **namespace** | **String** | The custom resource&#39;s namespace |  |
| **plural** | **String** | the custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **name** | **String** | the custom object&#39;s name |  |
| **body** | **Object** |  |  |
| **dry_run** | **String** | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed | [optional] |
| **field_manager** | **String** | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. | [optional] |
| **field_validation** | **String** | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional) | [optional] |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json, application/yaml, application/vnd.kubernetes.protobuf


## replace_namespaced_custom_object_status

> Object replace_namespaced_custom_object_status(group, version, namespace, plural, name, body, opts)



replace status of the specified namespace scoped custom object

### Examples

```ruby
require 'time'
require 'kubernetes'
# setup authorization
Kubernetes.configure do |config|
  # Configure API key authorization: BearerToken
  config.api_key['BearerToken'] = 'YOUR API KEY'
  # Uncomment the following line to set a prefix for the API key, e.g. 'Bearer' (defaults to nil)
  # config.api_key_prefix['BearerToken'] = 'Bearer'
end

api_instance = Kubernetes::CustomObjectsApi.new
group = 'group_example' # String | the custom resource's group
version = 'version_example' # String | the custom resource's version
namespace = 'namespace_example' # String | The custom resource's namespace
plural = 'plural_example' # String | the custom resource's plural name. For TPRs this would be lowercase plural kind.
name = 'name_example' # String | the custom object's name
body = Object # Object | 
opts = {
  dry_run: 'dry_run_example', # String | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed
  field_manager: 'field_manager_example', # String | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint.
  field_validation: 'field_validation_example' # String | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional)
}

begin
  
  result = api_instance.replace_namespaced_custom_object_status(group, version, namespace, plural, name, body, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->replace_namespaced_custom_object_status: #{e}"
end
```

#### Using the replace_namespaced_custom_object_status_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(Object, Integer, Hash)> replace_namespaced_custom_object_status_with_http_info(group, version, namespace, plural, name, body, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.replace_namespaced_custom_object_status_with_http_info(group, version, namespace, plural, name, body, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => Object
rescue Kubernetes::ApiError => e
  puts "Error when calling CustomObjectsApi->replace_namespaced_custom_object_status_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **group** | **String** | the custom resource&#39;s group |  |
| **version** | **String** | the custom resource&#39;s version |  |
| **namespace** | **String** | The custom resource&#39;s namespace |  |
| **plural** | **String** | the custom resource&#39;s plural name. For TPRs this would be lowercase plural kind. |  |
| **name** | **String** | the custom object&#39;s name |  |
| **body** | **Object** |  |  |
| **dry_run** | **String** | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed | [optional] |
| **field_manager** | **String** | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. | [optional] |
| **field_validation** | **String** | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. (optional) | [optional] |

### Return type

**Object**

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json, application/yaml, application/vnd.kubernetes.protobuf


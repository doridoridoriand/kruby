# Kubernetes::AuthorizationV1Api

All URIs are relative to *http://localhost*

| Method | HTTP request | Description |
| ------ | ------------ | ----------- |
| [**create_namespaced_local_subject_access_review**](AuthorizationV1Api.md#create_namespaced_local_subject_access_review) | **POST** /apis/authorization.k8s.io/v1/namespaces/{namespace}/localsubjectaccessreviews |  |
| [**create_self_subject_access_review**](AuthorizationV1Api.md#create_self_subject_access_review) | **POST** /apis/authorization.k8s.io/v1/selfsubjectaccessreviews |  |
| [**create_self_subject_rules_review**](AuthorizationV1Api.md#create_self_subject_rules_review) | **POST** /apis/authorization.k8s.io/v1/selfsubjectrulesreviews |  |
| [**create_subject_access_review**](AuthorizationV1Api.md#create_subject_access_review) | **POST** /apis/authorization.k8s.io/v1/subjectaccessreviews |  |
| [**get_api_resources_authorization_v1**](AuthorizationV1Api.md#get_api_resources_authorization_v1) | **GET** /apis/authorization.k8s.io/v1/ |  |


## create_namespaced_local_subject_access_review

> <V1LocalSubjectAccessReview> create_namespaced_local_subject_access_review(namespace, body, opts)



create a LocalSubjectAccessReview

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

api_instance = Kubernetes::AuthorizationV1Api.new
namespace = 'namespace_example' # String | object name and auth scope, such as for teams and projects
body = Kubernetes::V1LocalSubjectAccessReview.new({spec: Kubernetes::V1SubjectAccessReviewSpec.new}) # V1LocalSubjectAccessReview | 
opts = {
  dry_run: 'dry_run_example', # String | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed
  field_manager: 'field_manager_example', # String | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint.
  field_validation: 'field_validation_example', # String | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered.
  pretty: 'pretty_example' # String | If 'true', then the output is pretty printed. Defaults to 'false' unless the user-agent indicates a browser or command-line HTTP tool (curl and wget).
}

begin
  
  result = api_instance.create_namespaced_local_subject_access_review(namespace, body, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling AuthorizationV1Api->create_namespaced_local_subject_access_review: #{e}"
end
```

#### Using the create_namespaced_local_subject_access_review_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<V1LocalSubjectAccessReview>, Integer, Hash)> create_namespaced_local_subject_access_review_with_http_info(namespace, body, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.create_namespaced_local_subject_access_review_with_http_info(namespace, body, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <V1LocalSubjectAccessReview>
rescue Kubernetes::ApiError => e
  puts "Error when calling AuthorizationV1Api->create_namespaced_local_subject_access_review_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **namespace** | **String** | object name and auth scope, such as for teams and projects |  |
| **body** | [**V1LocalSubjectAccessReview**](V1LocalSubjectAccessReview.md) |  |  |
| **dry_run** | **String** | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed | [optional] |
| **field_manager** | **String** | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. | [optional] |
| **field_validation** | **String** | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. | [optional] |
| **pretty** | **String** | If &#39;true&#39;, then the output is pretty printed. Defaults to &#39;false&#39; unless the user-agent indicates a browser or command-line HTTP tool (curl and wget). | [optional] |

### Return type

[**V1LocalSubjectAccessReview**](V1LocalSubjectAccessReview.md)

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json, application/yaml, application/vnd.kubernetes.protobuf, application/cbor


## create_self_subject_access_review

> <V1SelfSubjectAccessReview> create_self_subject_access_review(body, opts)



create a SelfSubjectAccessReview

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

api_instance = Kubernetes::AuthorizationV1Api.new
body = Kubernetes::V1SelfSubjectAccessReview.new({spec: Kubernetes::V1SelfSubjectAccessReviewSpec.new}) # V1SelfSubjectAccessReview | 
opts = {
  dry_run: 'dry_run_example', # String | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed
  field_manager: 'field_manager_example', # String | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint.
  field_validation: 'field_validation_example', # String | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered.
  pretty: 'pretty_example' # String | If 'true', then the output is pretty printed. Defaults to 'false' unless the user-agent indicates a browser or command-line HTTP tool (curl and wget).
}

begin
  
  result = api_instance.create_self_subject_access_review(body, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling AuthorizationV1Api->create_self_subject_access_review: #{e}"
end
```

#### Using the create_self_subject_access_review_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<V1SelfSubjectAccessReview>, Integer, Hash)> create_self_subject_access_review_with_http_info(body, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.create_self_subject_access_review_with_http_info(body, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <V1SelfSubjectAccessReview>
rescue Kubernetes::ApiError => e
  puts "Error when calling AuthorizationV1Api->create_self_subject_access_review_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **body** | [**V1SelfSubjectAccessReview**](V1SelfSubjectAccessReview.md) |  |  |
| **dry_run** | **String** | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed | [optional] |
| **field_manager** | **String** | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. | [optional] |
| **field_validation** | **String** | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. | [optional] |
| **pretty** | **String** | If &#39;true&#39;, then the output is pretty printed. Defaults to &#39;false&#39; unless the user-agent indicates a browser or command-line HTTP tool (curl and wget). | [optional] |

### Return type

[**V1SelfSubjectAccessReview**](V1SelfSubjectAccessReview.md)

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json, application/yaml, application/vnd.kubernetes.protobuf, application/cbor


## create_self_subject_rules_review

> <V1SelfSubjectRulesReview> create_self_subject_rules_review(body, opts)



create a SelfSubjectRulesReview

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

api_instance = Kubernetes::AuthorizationV1Api.new
body = Kubernetes::V1SelfSubjectRulesReview.new({spec: Kubernetes::V1SelfSubjectRulesReviewSpec.new}) # V1SelfSubjectRulesReview | 
opts = {
  dry_run: 'dry_run_example', # String | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed
  field_manager: 'field_manager_example', # String | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint.
  field_validation: 'field_validation_example', # String | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered.
  pretty: 'pretty_example' # String | If 'true', then the output is pretty printed. Defaults to 'false' unless the user-agent indicates a browser or command-line HTTP tool (curl and wget).
}

begin
  
  result = api_instance.create_self_subject_rules_review(body, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling AuthorizationV1Api->create_self_subject_rules_review: #{e}"
end
```

#### Using the create_self_subject_rules_review_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<V1SelfSubjectRulesReview>, Integer, Hash)> create_self_subject_rules_review_with_http_info(body, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.create_self_subject_rules_review_with_http_info(body, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <V1SelfSubjectRulesReview>
rescue Kubernetes::ApiError => e
  puts "Error when calling AuthorizationV1Api->create_self_subject_rules_review_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **body** | [**V1SelfSubjectRulesReview**](V1SelfSubjectRulesReview.md) |  |  |
| **dry_run** | **String** | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed | [optional] |
| **field_manager** | **String** | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. | [optional] |
| **field_validation** | **String** | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. | [optional] |
| **pretty** | **String** | If &#39;true&#39;, then the output is pretty printed. Defaults to &#39;false&#39; unless the user-agent indicates a browser or command-line HTTP tool (curl and wget). | [optional] |

### Return type

[**V1SelfSubjectRulesReview**](V1SelfSubjectRulesReview.md)

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json, application/yaml, application/vnd.kubernetes.protobuf, application/cbor


## create_subject_access_review

> <V1SubjectAccessReview> create_subject_access_review(body, opts)



create a SubjectAccessReview

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

api_instance = Kubernetes::AuthorizationV1Api.new
body = Kubernetes::V1SubjectAccessReview.new({spec: Kubernetes::V1SubjectAccessReviewSpec.new}) # V1SubjectAccessReview | 
opts = {
  dry_run: 'dry_run_example', # String | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed
  field_manager: 'field_manager_example', # String | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint.
  field_validation: 'field_validation_example', # String | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered.
  pretty: 'pretty_example' # String | If 'true', then the output is pretty printed. Defaults to 'false' unless the user-agent indicates a browser or command-line HTTP tool (curl and wget).
}

begin
  
  result = api_instance.create_subject_access_review(body, opts)
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling AuthorizationV1Api->create_subject_access_review: #{e}"
end
```

#### Using the create_subject_access_review_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<V1SubjectAccessReview>, Integer, Hash)> create_subject_access_review_with_http_info(body, opts)

```ruby
begin
  
  data, status_code, headers = api_instance.create_subject_access_review_with_http_info(body, opts)
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <V1SubjectAccessReview>
rescue Kubernetes::ApiError => e
  puts "Error when calling AuthorizationV1Api->create_subject_access_review_with_http_info: #{e}"
end
```

### Parameters

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **body** | [**V1SubjectAccessReview**](V1SubjectAccessReview.md) |  |  |
| **dry_run** | **String** | When present, indicates that modifications should not be persisted. An invalid or unrecognized dryRun directive will result in an error response and no further processing of the request. Valid values are: - All: all dry run stages will be processed | [optional] |
| **field_manager** | **String** | fieldManager is a name associated with the actor or entity that is making these changes. The value must be less than or 128 characters long, and only contain printable characters, as defined by https://golang.org/pkg/unicode/#IsPrint. | [optional] |
| **field_validation** | **String** | fieldValidation instructs the server on how to handle objects in the request (POST/PUT/PATCH) containing unknown or duplicate fields. Valid values are: - Ignore: This will ignore any unknown fields that are silently dropped from the object, and will ignore all but the last duplicate field that the decoder encounters. This is the default behavior prior to v1.23. - Warn: This will send a warning via the standard warning response header for each unknown field that is dropped from the object, and for each duplicate field that is encountered. The request will still succeed if there are no other errors, and will only persist the last of any duplicate fields. This is the default in v1.23+ - Strict: This will fail the request with a BadRequest error if any unknown fields would be dropped from the object, or if any duplicate fields are present. The error returned from the server will contain all unknown and duplicate fields encountered. | [optional] |
| **pretty** | **String** | If &#39;true&#39;, then the output is pretty printed. Defaults to &#39;false&#39; unless the user-agent indicates a browser or command-line HTTP tool (curl and wget). | [optional] |

### Return type

[**V1SubjectAccessReview**](V1SubjectAccessReview.md)

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json, application/yaml, application/vnd.kubernetes.protobuf, application/cbor


## get_api_resources_authorization_v1

> <V1APIResourceList> get_api_resources_authorization_v1



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

api_instance = Kubernetes::AuthorizationV1Api.new

begin
  
  result = api_instance.get_api_resources_authorization_v1
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling AuthorizationV1Api->get_api_resources_authorization_v1: #{e}"
end
```

#### Using the get_api_resources_authorization_v1_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<V1APIResourceList>, Integer, Hash)> get_api_resources_authorization_v1_with_http_info

```ruby
begin
  
  data, status_code, headers = api_instance.get_api_resources_authorization_v1_with_http_info
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <V1APIResourceList>
rescue Kubernetes::ApiError => e
  puts "Error when calling AuthorizationV1Api->get_api_resources_authorization_v1_with_http_info: #{e}"
end
```

### Parameters

This endpoint does not need any parameter.

### Return type

[**V1APIResourceList**](V1APIResourceList.md)

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json, application/yaml, application/vnd.kubernetes.protobuf, application/cbor


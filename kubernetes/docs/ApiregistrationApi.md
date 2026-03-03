# Kubernetes::ApiregistrationApi

All URIs are relative to *http://localhost*

| Method | HTTP request | Description |
| ------ | ------------ | ----------- |
| [**get_api_group_apiregistration**](ApiregistrationApi.md#get_api_group_apiregistration) | **GET** /apis/apiregistration.k8s.io/ |  |


## get_api_group_apiregistration

> <V1APIGroup> get_api_group_apiregistration



get information of a group

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

api_instance = Kubernetes::ApiregistrationApi.new

begin
  
  result = api_instance.get_api_group_apiregistration
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling ApiregistrationApi->get_api_group_apiregistration: #{e}"
end
```

#### Using the get_api_group_apiregistration_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<V1APIGroup>, Integer, Hash)> get_api_group_apiregistration_with_http_info

```ruby
begin
  
  data, status_code, headers = api_instance.get_api_group_apiregistration_with_http_info
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <V1APIGroup>
rescue Kubernetes::ApiError => e
  puts "Error when calling ApiregistrationApi->get_api_group_apiregistration_with_http_info: #{e}"
end
```

### Parameters

This endpoint does not need any parameter.

### Return type

[**V1APIGroup**](V1APIGroup.md)

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json, application/yaml, application/vnd.kubernetes.protobuf


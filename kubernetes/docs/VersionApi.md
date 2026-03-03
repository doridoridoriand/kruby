# Kubernetes::VersionApi

All URIs are relative to *http://localhost*

| Method | HTTP request | Description |
| ------ | ------------ | ----------- |
| [**get_code**](VersionApi.md#get_code) | **GET** /version/ |  |


## get_code

> <VersionInfo> get_code



get the version information for this server

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

api_instance = Kubernetes::VersionApi.new

begin
  
  result = api_instance.get_code
  p result
rescue Kubernetes::ApiError => e
  puts "Error when calling VersionApi->get_code: #{e}"
end
```

#### Using the get_code_with_http_info variant

This returns an Array which contains the response data, status code and headers.

> <Array(<VersionInfo>, Integer, Hash)> get_code_with_http_info

```ruby
begin
  
  data, status_code, headers = api_instance.get_code_with_http_info
  p status_code # => 2xx
  p headers # => { ... }
  p data # => <VersionInfo>
rescue Kubernetes::ApiError => e
  puts "Error when calling VersionApi->get_code_with_http_info: #{e}"
end
```

### Parameters

This endpoint does not need any parameter.

### Return type

[**VersionInfo**](VersionInfo.md)

### Authorization

[BearerToken](../README.md#BearerToken)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json


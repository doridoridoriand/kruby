# Kubernetes::V1TokenReviewSpec

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **audiences** | **Array&lt;String&gt;** | audiences is a list of the identifiers that the resource server presented with the token identifies as. Audience-aware token authenticators will verify that the token was intended for at least one of the audiences in this list. If no audiences are provided, the audience will default to the audience of the Kubernetes apiserver. | [optional] |
| **token** | **String** | token is the opaque bearer token. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1TokenReviewSpec.new(
  audiences: null,
  token: null
)
```


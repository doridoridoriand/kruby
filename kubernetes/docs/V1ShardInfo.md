# Kubernetes::V1ShardInfo

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **selector** | **String** | selector is the shard selector string from the request, echoed back so clients can verify which shard they received and merge responses from multiple shards. |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1ShardInfo.new(
  selector: null
)
```


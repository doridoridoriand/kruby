# Kubernetes::V1NodeStatus

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **addresses** | [**Array&lt;V1NodeAddress&gt;**](V1NodeAddress.md) | List of addresses reachable to the node. Queried from cloud provider, if available. More info: https://kubernetes.io/docs/reference/node/node-status/#addresses Note: This field is declared as mergeable, but the merge key is not sufficiently unique, which can cause data corruption when it is merged. Callers should instead use a full-replacement patch. See https://pr.k8s.io/79391 for an example. Consumers should assume that addresses can change during the lifetime of a Node. However, there are some exceptions where this may not be possible, such as Pods that inherit a Node&#39;s address in its own status or consumers of the downward API (status.hostIP). | [optional] |
| **allocatable** | **Hash&lt;String, String&gt;** | Allocatable represents the resources of a node that are available for scheduling. Defaults to Capacity. | [optional] |
| **capacity** | **Hash&lt;String, String&gt;** | Capacity represents the total resources of a node. More info: https://kubernetes.io/docs/reference/node/node-status/#capacity | [optional] |
| **conditions** | [**Array&lt;V1NodeCondition&gt;**](V1NodeCondition.md) | Conditions is an array of current observed node conditions. More info: https://kubernetes.io/docs/reference/node/node-status/#condition | [optional] |
| **config** | [**V1NodeConfigStatus**](V1NodeConfigStatus.md) |  | [optional] |
| **daemon_endpoints** | [**V1NodeDaemonEndpoints**](V1NodeDaemonEndpoints.md) |  | [optional] |
| **declared_features** | **Array&lt;String&gt;** | DeclaredFeatures represents the features related to feature gates that are declared by the node. | [optional] |
| **features** | [**V1NodeFeatures**](V1NodeFeatures.md) |  | [optional] |
| **images** | [**Array&lt;V1ContainerImage&gt;**](V1ContainerImage.md) | List of container images on this node | [optional] |
| **node_info** | [**V1NodeSystemInfo**](V1NodeSystemInfo.md) |  | [optional] |
| **phase** | **String** | NodePhase is the recently observed lifecycle phase of the node. More info: https://kubernetes.io/docs/concepts/nodes/node/#phase The field is never populated, and now is deprecated. | [optional] |
| **runtime_handlers** | [**Array&lt;V1NodeRuntimeHandler&gt;**](V1NodeRuntimeHandler.md) | The available runtime handlers. | [optional] |
| **volumes_attached** | [**Array&lt;V1AttachedVolume&gt;**](V1AttachedVolume.md) | List of volumes that are attached to the node. | [optional] |
| **volumes_in_use** | **Array&lt;String&gt;** | List of attachable volumes in use (mounted) by the node. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1NodeStatus.new(
  addresses: null,
  allocatable: null,
  capacity: null,
  conditions: null,
  config: null,
  daemon_endpoints: null,
  declared_features: null,
  features: null,
  images: null,
  node_info: null,
  phase: null,
  runtime_handlers: null,
  volumes_attached: null,
  volumes_in_use: null
)
```


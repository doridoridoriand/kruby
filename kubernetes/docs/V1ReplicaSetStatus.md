# Kubernetes::V1ReplicaSetStatus

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **available_replicas** | **Integer** | The number of available non-terminating pods (ready for at least minReadySeconds) for this replica set. | [optional] |
| **conditions** | [**Array&lt;V1ReplicaSetCondition&gt;**](V1ReplicaSetCondition.md) | Represents the latest available observations of a replica set&#39;s current state. | [optional] |
| **fully_labeled_replicas** | **Integer** | The number of non-terminating pods that have labels matching the labels of the pod template of the replicaset. | [optional] |
| **observed_generation** | **Integer** | ObservedGeneration reflects the generation of the most recently observed ReplicaSet. | [optional] |
| **ready_replicas** | **Integer** | The number of non-terminating pods targeted by this ReplicaSet with a Ready Condition. | [optional] |
| **replicas** | **Integer** | Replicas is the most recently observed number of non-terminating pods. More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicaset |  |
| **terminating_replicas** | **Integer** | The number of terminating pods for this replica set. Terminating pods have a non-null .metadata.deletionTimestamp and have not yet reached the Failed or Succeeded .status.phase.  This is a beta field and requires enabling DeploymentReplicaSetTerminatingReplicas feature (enabled by default). | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1ReplicaSetStatus.new(
  available_replicas: null,
  conditions: null,
  fully_labeled_replicas: null,
  observed_generation: null,
  ready_replicas: null,
  replicas: null,
  terminating_replicas: null
)
```


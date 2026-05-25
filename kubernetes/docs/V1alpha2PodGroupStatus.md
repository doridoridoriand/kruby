# Kubernetes::V1alpha2PodGroupStatus

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **conditions** | [**Array&lt;V1Condition&gt;**](V1Condition.md) | Conditions represent the latest observations of the PodGroup&#39;s state.  Known condition types: - \&quot;PodGroupScheduled\&quot;: Indicates whether the scheduling requirement has been satisfied. - \&quot;DisruptionTarget\&quot;: Indicates whether the PodGroup is about to be terminated   due to disruption such as preemption.  Known reasons for the PodGroupScheduled condition: - \&quot;Unschedulable\&quot;: The PodGroup cannot be scheduled due to resource constraints,   affinity/anti-affinity rules, or insufficient capacity for the gang. - \&quot;SchedulerError\&quot;: The PodGroup cannot be scheduled due to some internal error   that happened during scheduling, for example due to nodeAffinity parsing errors.  Known reasons for the DisruptionTarget condition: - \&quot;PreemptionByScheduler\&quot;: The PodGroup was preempted by the scheduler to make room for   higher-priority PodGroups or Pods. | [optional] |
| **resource_claim_statuses** | [**Array&lt;V1alpha2PodGroupResourceClaimStatus&gt;**](V1alpha2PodGroupResourceClaimStatus.md) | Status of resource claims. | [optional] |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1alpha2PodGroupStatus.new(
  conditions: null,
  resource_claim_statuses: null
)
```


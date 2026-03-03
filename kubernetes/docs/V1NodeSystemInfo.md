# Kubernetes::V1NodeSystemInfo

## Properties

| Name | Type | Description | Notes |
| ---- | ---- | ----------- | ----- |
| **architecture** | **String** | The Architecture reported by the node |  |
| **boot_id** | **String** | Boot ID reported by the node. |  |
| **container_runtime_version** | **String** | ContainerRuntime Version reported by the node through runtime remote API (e.g. containerd://1.4.2). |  |
| **kernel_version** | **String** | Kernel Version reported by the node from &#39;uname -r&#39; (e.g. 3.16.0-0.bpo.4-amd64). |  |
| **kube_proxy_version** | **String** | Deprecated: KubeProxy Version reported by the node. |  |
| **kubelet_version** | **String** | Kubelet Version reported by the node. |  |
| **machine_id** | **String** | MachineID reported by the node. For unique machine identification in the cluster this field is preferred. Learn more from man(5) machine-id: http://man7.org/linux/man-pages/man5/machine-id.5.html |  |
| **operating_system** | **String** | The Operating System reported by the node |  |
| **os_image** | **String** | OS Image reported by the node from /etc/os-release (e.g. Debian GNU/Linux 7 (wheezy)). |  |
| **swap** | [**V1NodeSwapStatus**](V1NodeSwapStatus.md) |  | [optional] |
| **system_uuid** | **String** | SystemUUID reported by the node. For unique machine identification MachineID is preferred. This field is specific to Red Hat hosts https://access.redhat.com/documentation/en-us/red_hat_subscription_management/1/html/rhsm/uuid |  |

## Example

```ruby
require 'kubernetes'

instance = Kubernetes::V1NodeSystemInfo.new(
  architecture: null,
  boot_id: null,
  container_runtime_version: null,
  kernel_version: null,
  kube_proxy_version: null,
  kubelet_version: null,
  machine_id: null,
  operating_system: null,
  os_image: null,
  swap: null,
  system_uuid: null
)
```


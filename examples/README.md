# Example Catalog

These examples are curated entry points for common kruby workflows.
They complement the generated API and model reference under `kubernetes/docs/`.

## Prerequisites

- Install the gem locally or use the repository checkout.
- Set `KUBECONFIG` to a cluster you can access.
- Use `require "kruby"` or `require "kubernetes"` for backward compatibility.

## Quick Start

| Example | Focus | Notes |
| --- | --- | --- |
| [`simple`](simple/simple.rb) | List pods in a namespace | Smallest possible read-only client |
| [`dry-run`](dry-run/dry-run.rb) | Validate dry-run behavior before a real create/delete cycle | Demonstrates server-side `dry_run: "All"` plus cleanup |
| [`label-selector`](label-selector/label-selector.rb) | Narrow list calls efficiently | Shows `label_selector` and `field_selector` |

## Core Resources

| Example | Primary APIs and models | What it demonstrates |
| --- | --- | --- |
| [`namespace`](namespace/namespace.rb) | `CoreV1Api`, `V1Namespace` | Create and delete namespaces |
| [`configmap`](configmap/configmap.rb) | `CoreV1Api`, `V1ConfigMap` | Manage application configuration |
| [`secret`](secret/secret.rb) | `CoreV1Api`, `V1Secret` | Create secret data safely |
| [`service`](service/service.rb) | `CoreV1Api`, `V1Service` | Expose pods with a Service |
| [`persistent-volume-claim`](persistent-volume-claim/persistent-volume-claim.rb) | `CoreV1Api`, `V1PersistentVolumeClaim` | Request persistent storage |

## Workloads

| Example | Primary APIs and models | What it demonstrates |
| --- | --- | --- |
| [`deployment`](deployment/deployment.rb) | `AppsV1Api`, `V1Deployment` | Declarative stateless rollout |
| [`statefulset`](statefulset/statefulset.rb) | `AppsV1Api`, `V1StatefulSet` | Stable identities and storage |
| [`cronjob`](cronjob/cronjob.rb) | `BatchV1Api`, `V1CronJob` | Scheduled batch execution |
| [`horizontal-pod-autoscaler`](horizontal-pod-autoscaler/horizontal-pod-autoscaler.rb) | `AutoscalingV2Api`, `V2HorizontalPodAutoscaler` | Autoscaling configuration |

## Networking and Policy

| Example | Primary APIs and models | What it demonstrates |
| --- | --- | --- |
| [`ingress`](ingress/ingress.rb) | `NetworkingV1Api`, `V1Ingress` | HTTP routing resources |
| [`network-policy`](network-policy/network-policy.rb) | `NetworkingV1Api`, `V1NetworkPolicy` | Pod-to-pod traffic policy |
| [`rbac`](rbac/rbac.rb) | `RbacAuthorizationV1Api`, RBAC models | Roles, bindings, and service accounts |

## Observability and Streaming

| Example | Primary APIs and models | What it demonstrates |
| --- | --- | --- |
| [`events`](events/events.rb) | `EventsV1Api`, `CoreV1Api` | Read cluster events |
| [`logs`](logs/logs.rb) | `LogsApi`, `CoreV1Api` | Fetch logs, tail logs, and handle cleanup |
| [`watch`](watch/watch.rb) | `Kubernetes::Watch` | Stream namespace changes |
| [`multi-watch`](multi-watch/multi-watch.rb) | `Kubernetes::Watch` | Watch pods, services, and events concurrently |

## Advanced APIs

| Example | Primary APIs and models | What it demonstrates |
| --- | --- | --- |
| [`custom-object`](custom-object/custom-object.rb) | `CustomObjectsApi` | Work with CRDs and unstructured payloads |

## Usage Notes

- Examples that create resources usually clean them up before exit.
- Some examples accept environment variables such as `NAMESPACE`, `POD_NAME`, or `WATCH_TIMEOUT_SECONDS`.
- Reuse a single `Kubernetes::ApiClient` when making many calls in the same process.
- Prefer selectors and watch streams over repeated wide polling when possible.

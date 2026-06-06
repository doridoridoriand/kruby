# frozen_string_literal: true

module SpecSupport
  module E2E
    module Factories
      module_function

      def pod(name:, labels: {})
        {
          apiVersion: "v1",
          kind: "Pod",
          metadata: {
            name: name,
            labels: labels
          },
          spec: {
            containers: [
              {
                name: "pause",
                image: "registry.k8s.io/pause:3.9"
              }
            ]
          }
        }
      end

      def deployment(name:, labels: {})
        pod_labels = labels.merge("app" => name)

        {
          apiVersion: "apps/v1",
          kind: "Deployment",
          metadata: {
            name: name,
            labels: labels
          },
          spec: {
            replicas: 1,
            selector: {
              matchLabels: {
                app: name
              }
            },
            template: {
              metadata: {
                labels: pod_labels
              },
              spec: {
                containers: [
                  {
                    name: "pause",
                    image: "registry.k8s.io/pause:3.9"
                  }
                ]
              }
            }
          }
        }
      end

      def daemon_set(name:, labels: {})
        pod_labels = labels.merge("app" => name)

        {
          apiVersion: "apps/v1",
          kind: "DaemonSet",
          metadata: {
            name: name,
            labels: labels
          },
          spec: {
            selector: {
              matchLabels: {
                app: name
              }
            },
            template: {
              metadata: {
                labels: pod_labels
              },
              spec: {
                nodeSelector: {
                  "kruby-e2e-node" => "never"
                },
                containers: [
                  {
                    name: "pause",
                    image: "registry.k8s.io/pause:3.9"
                  }
                ]
              }
            }
          }
        }
      end

      def replica_set(name:, labels: {})
        pod_labels = labels.merge("app" => name)

        {
          apiVersion: "apps/v1",
          kind: "ReplicaSet",
          metadata: {
            name: name,
            labels: labels
          },
          spec: {
            replicas: 0,
            selector: {
              matchLabels: {
                app: name
              }
            },
            template: {
              metadata: {
                labels: pod_labels
              },
              spec: {
                containers: [
                  {
                    name: "pause",
                    image: "registry.k8s.io/pause:3.9"
                  }
                ]
              }
            }
          }
        }
      end

      def stateful_set(name:, labels: {})
        pod_labels = labels.merge("app" => name)

        {
          apiVersion: "apps/v1",
          kind: "StatefulSet",
          metadata: {
            name: name,
            labels: labels
          },
          spec: {
            replicas: 0,
            serviceName: "#{name}-headless",
            selector: {
              matchLabels: {
                app: name
              }
            },
            template: {
              metadata: {
                labels: pod_labels
              },
              spec: {
                containers: [
                  {
                    name: "pause",
                    image: "registry.k8s.io/pause:3.9"
                  }
                ]
              }
            }
          }
        }
      end

      def job(name:, labels: {})
        pod_labels = labels.merge("job" => name)

        {
          apiVersion: "batch/v1",
          kind: "Job",
          metadata: {
            name: name,
            labels: labels
          },
          spec: {
            template: {
              metadata: {
                labels: pod_labels
              },
              spec: {
                restartPolicy: "Never",
                containers: [
                  {
                    name: "pause",
                    image: "registry.k8s.io/pause:3.9"
                  }
                ]
              }
            }
          }
        }
      end

      def service(name:, labels: {})
        {
          apiVersion: "v1",
          kind: "Service",
          metadata: {
            name: name,
            labels: labels
          },
          spec: {
            selector: labels,
            ports: [
              {
                name: "http",
                port: 80,
                protocol: "TCP",
                targetPort: 80
              }
            ]
          }
        }
      end

      def config_map(name:, labels: {})
        {
          apiVersion: "v1",
          kind: "ConfigMap",
          metadata: {
            name: name,
            labels: labels
          },
          data: {
            "app" => name
          }
        }
      end

      def secret(name:, labels: {})
        {
          apiVersion: "v1",
          kind: "Secret",
          metadata: {
            name: name,
            labels: labels
          },
          type: "Opaque",
          stringData: {
            "key" => "e2e-test-value"
          }
        }
      end

      def namespace(name:, labels: {})
        {
          apiVersion: "v1",
          kind: "Namespace",
          metadata: {
            name: name,
            labels: labels
          }
        }
      end

      def endpoints(name:, labels: {})
        {
          apiVersion: "v1",
          kind: "Endpoints",
          metadata: {
            name: name,
            labels: labels
          },
          subsets: [
            {
              addresses: [
                {
                  ip: "10.0.0.1"
                }
              ],
              ports: [
                {
                  name: "http",
                  port: 80,
                  protocol: "TCP"
                }
              ]
            }
          ]
        }
      end

      def persistent_volume_claim(name:, labels: {})
        {
          apiVersion: "v1",
          kind: "PersistentVolumeClaim",
          metadata: {
            name: name,
            labels: labels
          },
          spec: {
            storageClassName: "",
            accessModes: ["ReadWriteOnce"],
            resources: {
              requests: {
                storage: "1Mi"
              }
            }
          }
        }
      end

      def persistent_volume(name:, labels: {})
        {
          apiVersion: "v1",
          kind: "PersistentVolume",
          metadata: {
            name: name,
            labels: labels
          },
          spec: {
            capacity: {
              storage: "1Mi"
            },
            accessModes: ["ReadWriteOnce"],
            persistentVolumeReclaimPolicy: "Retain",
            storageClassName: "",
            hostPath: {
              path: "/tmp/#{name}",
              type: "DirectoryOrCreate"
            }
          }
        }
      end

      def role(name:, labels: {})
        {
          apiVersion: "rbac.authorization.k8s.io/v1",
          kind: "Role",
          metadata: {
            name: name,
            labels: labels
          },
          rules: [
            {
              apiGroups: [""],
              resources: ["pods"],
              verbs: ["get", "list", "watch"]
            }
          ]
        }
      end

      def cluster_role(name:, labels: {})
        {
          apiVersion: "rbac.authorization.k8s.io/v1",
          kind: "ClusterRole",
          metadata: {
            name: name,
            labels: labels
          },
          rules: [
            {
              apiGroups: [""],
              resources: ["pods"],
              verbs: ["get", "list", "watch"]
            }
          ]
        }
      end

      def role_binding(name:, role_name:, namespace:, labels: {})
        {
          apiVersion: "rbac.authorization.k8s.io/v1",
          kind: "RoleBinding",
          metadata: {
            name: name,
            labels: labels
          },
          roleRef: {
            apiGroup: "rbac.authorization.k8s.io",
            kind: "Role",
            name: role_name
          },
          subjects: [
            {
              kind: "ServiceAccount",
              name: "default",
              namespace: namespace
            }
          ]
        }
      end

      def cluster_role_binding(name:, cluster_role_name:, labels: {})
        {
          apiVersion: "rbac.authorization.k8s.io/v1",
          kind: "ClusterRoleBinding",
          metadata: {
            name: name,
            labels: labels
          },
          roleRef: {
            apiGroup: "rbac.authorization.k8s.io",
            kind: "ClusterRole",
            name: cluster_role_name
          },
          subjects: [
            {
              kind: "ServiceAccount",
              name: "default",
              namespace: "default",
              apiGroup: ""
            }
          ]
        }
      end

      def ingress(name:, labels: {})
        {
          "apiVersion" => "networking.k8s.io/v1",
          "kind" => "Ingress",
          "metadata" => { "name" => name, "labels" => labels },
          "spec" => {
            "rules" => [
              {
                "host" => "e2e-test.local",
                "http" => {
                  "paths" => [
                    {
                      "path" => "/",
                      "pathType" => "Prefix",
                      "backend" => {
                        "service" => {
                          "name" => "nonexistent",
                          "port" => { "number" => 80 }
                        }
                      }
                    }
                  ]
                }
              }
            ]
          }
        }
      end

      def network_policy(name:, labels: {})
        {
          "apiVersion" => "networking.k8s.io/v1",
          "kind" => "NetworkPolicy",
          "metadata" => { "name" => name, "labels" => labels },
          "spec" => {
            "podSelector" => { "matchLabels" => { "app" => "e2e-test" } },
            "policyTypes" => ["Ingress"]
          }
        }
      end

      def ingress_class(name:, labels: {})
        {
          "apiVersion" => "networking.k8s.io/v1",
          "kind" => "IngressClass",
          "metadata" => { "name" => name, "labels" => labels },
          "spec" => {
            "controller" => "kruby-e2e.example/controller"
          }
        }
      end

      def storage_class(name:, labels: {})
        {
          "apiVersion" => "storage.k8s.io/v1",
          "kind" => "StorageClass",
          "metadata" => { "name" => name, "labels" => labels },
          "provisioner" => "kubernetes.io/no-provisioner",
          "volumeBindingMode" => "WaitForFirstConsumer"
        }
      end

      def csi_driver(name:, labels: {})
        {
          "apiVersion" => "storage.k8s.io/v1",
          "kind" => "CSIDriver",
          "metadata" => { "name" => name, "labels" => labels },
          "spec" => {
            "attachRequired" => false,
            "podInfoOnMount" => false,
            "volumeLifecycleModes" => ["Persistent"]
          }
        }
      end

      def csi_storage_capacity(name:, labels: {})
        {
          "apiVersion" => "storage.k8s.io/v1",
          "kind" => "CSIStorageCapacity",
          "metadata" => { "name" => name, "labels" => labels },
          "storageClassName" => "kruby-e2e-no-provisioner",
          "capacity" => "1Mi"
        }
      end

      def horizontal_pod_autoscaler(name:, labels: {})
        {
          "apiVersion" => "autoscaling/v2",
          "kind" => "HorizontalPodAutoscaler",
          "metadata" => { "name" => name, "labels" => labels },
          "spec" => {
            "minReplicas" => 1,
            "maxReplicas" => 3,
            "scaleTargetRef" => {
              "apiVersion" => "apps/v1",
              "kind" => "Deployment",
              "name" => "#{name}-target"
            }
          }
        }
      end

      def pod_disruption_budget(name:, labels: {})
        {
          "apiVersion" => "policy/v1",
          "kind" => "PodDisruptionBudget",
          "metadata" => { "name" => name, "labels" => labels },
          "spec" => {
            "maxUnavailable" => 1,
            "selector" => {
              "matchLabels" => {
                "app.kubernetes.io/instance" => name
              }
            }
          }
        }
      end

      def lease(name:, labels: {})
        {
          "apiVersion" => "coordination.k8s.io/v1",
          "kind" => "Lease",
          "metadata" => { "name" => name, "labels" => labels },
          "spec" => {
            "holderIdentity" => "kruby-e2e",
            "leaseDurationSeconds" => 30
          }
        }
      end

      def priority_class(name:, labels: {})
        {
          "apiVersion" => "scheduling.k8s.io/v1",
          "kind" => "PriorityClass",
          "metadata" => { "name" => name, "labels" => labels },
          "value" => 1000,
          "globalDefault" => false,
          "description" => "kruby E2E priority class"
        }
      end

      def limit_range(name:, labels: {})
        {
          "apiVersion" => "v1",
          "kind" => "LimitRange",
          "metadata" => { "name" => name, "labels" => labels },
          "spec" => {
            "limits" => [
              {
                "type" => "Container",
                "default" => {
                  "cpu" => "500m",
                  "memory" => "256Mi"
                },
                "max" => {
                  "cpu" => "1",
                  "memory" => "512Mi"
                },
                "min" => {
                  "cpu" => "10m",
                  "memory" => "16Mi"
                }
              }
            ]
          }
        }
      end

      def resource_quota(name:, labels: {})
        {
          "apiVersion" => "v1",
          "kind" => "ResourceQuota",
          "metadata" => { "name" => name, "labels" => labels },
          "spec" => {
            "hard" => {
              "pods" => "100",
              "requests.cpu" => "50",
              "requests.memory" => "100Gi"
            }
          }
        }
      end

      def service_account(name:, labels: {})
        {
          "apiVersion" => "v1",
          "kind" => "ServiceAccount",
          "metadata" => { "name" => name, "labels" => labels }
        }
      end

      def pod_template(name:, labels: {})
        pod_labels = labels.merge("app" => name)

        {
          "apiVersion" => "v1",
          "kind" => "PodTemplate",
          "metadata" => { "name" => name, "labels" => labels },
          "template" => {
            "metadata" => { "labels" => pod_labels },
            "spec" => {
              "containers" => [
                {
                  "name" => "pause",
                  "image" => "registry.k8s.io/pause:3.9"
                }
              ]
            }
          }
        }
      end

      def replication_controller(name:, labels: {})
        pod_labels = labels.merge("app" => name)

        {
          "apiVersion" => "v1",
          "kind" => "ReplicationController",
          "metadata" => { "name" => name, "labels" => labels },
          "spec" => {
            "replicas" => 1,
            "selector" => { "app" => name },
            "template" => {
              "metadata" => { "labels" => pod_labels },
              "spec" => {
                "containers" => [
                  {
                    "name" => "pause",
                    "image" => "registry.k8s.io/pause:3.9"
                  }
                ]
              }
            }
          }
        }
      end

      def controller_revision(name:, labels: {})
        {
          "apiVersion" => "apps/v1",
          "kind" => "ControllerRevision",
          "metadata" => { "name" => name, "labels" => labels },
          "data" => {
            "state" => "initialized"
          },
          "revision" => 1
        }
      end

      def cron_job(name:, labels: {})
        pod_labels = labels.merge("app" => name)

        {
          "apiVersion" => "batch/v1",
          "kind" => "CronJob",
          "metadata" => { "name" => name, "labels" => labels },
          "spec" => {
            "schedule" => "0 0 * * *",
            "jobTemplate" => {
              "spec" => {
                "template" => {
                  "metadata" => { "labels" => pod_labels },
                  "spec" => {
                    "restartPolicy" => "OnFailure",
                    "containers" => [
                      {
                        "name" => "busybox",
                        "image" => "registry.k8s.io/busybox:1.28",
                        "args" => ["echo", "hello"]
                      }
                    ]
                  }
                }
              }
            }
          }
        }
      end
    end
  end
end

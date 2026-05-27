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
            "controller" => "e2e-test-controller.local"
          }
        }
      end
    end
  end
end

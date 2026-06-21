# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Kubernetes model serialization" do
  MODEL_CASES = [
    {
      klass: Kubernetes::V1ObjectMeta,
      payload: {
        name: "demo",
        namespace: "default",
        labels: { "app" => "demo" },
        annotations: { "owner" => "kruby" },
        creationTimestamp: "2026-05-27T00:00:00Z",
        deletionGracePeriodSeconds: "30"
      },
      expected_types: {
        creation_timestamp: Time,
        deletion_grace_period_seconds: Integer,
        labels: Hash,
        annotations: Hash
      }
    },
    {
      klass: Kubernetes::V1Container,
      payload: {
        name: "app",
        image: "registry.k8s.io/pause:3.9",
        tty: "true"
      },
      expected_values: {
        tty: true
      }
    },
    {
      klass: Kubernetes::V1PodSpec,
      payload: {
        containers: [
          { name: "app", image: "registry.k8s.io/pause:3.9" }
        ],
        restartPolicy: "Never"
      },
      expected_types: {
        containers: Array
      }
    },
    {
      klass: Kubernetes::V1Pod,
      payload: {
        apiVersion: "v1",
        kind: "Pod",
        metadata: { name: "pod-demo", labels: { "app" => "demo" } },
        spec: {
          containers: [
            { name: "app", image: "registry.k8s.io/pause:3.9" }
          ]
        }
      },
      expected_types: {
        metadata: Kubernetes::V1ObjectMeta,
        spec: Kubernetes::V1PodSpec
      }
    },
    {
      klass: Kubernetes::V1ServicePort,
      payload: {
        name: "http",
        port: "80",
        protocol: "TCP",
        targetPort: 8080
      },
      expected_values: {
        port: 80
      }
    },
    {
      klass: Kubernetes::V1ServiceSpec,
      payload: {
        selector: { "app" => "demo" },
        ports: [
          { name: "http", port: 80, protocol: "TCP" }
        ],
        type: "ClusterIP"
      },
      expected_types: {
        ports: Array,
        selector: Hash
      }
    },
    {
      klass: Kubernetes::V1Service,
      payload: {
        apiVersion: "v1",
        kind: "Service",
        metadata: { name: "service-demo" },
        spec: {
          selector: { "app" => "demo" },
          ports: [{ name: "http", port: 80 }]
        }
      },
      expected_types: {
        metadata: Kubernetes::V1ObjectMeta,
        spec: Kubernetes::V1ServiceSpec
      }
    },
    {
      klass: Kubernetes::V1ConfigMap,
      payload: {
        apiVersion: "v1",
        kind: "ConfigMap",
        metadata: { name: "config-demo" },
        data: { "setting" => "enabled" },
        binaryData: { "payload" => "a3J1Ynk=" }
      },
      expected_types: {
        metadata: Kubernetes::V1ObjectMeta,
        data: Hash,
        binary_data: Hash
      }
    },
    {
      klass: Kubernetes::V1Secret,
      payload: {
        apiVersion: "v1",
        kind: "Secret",
        metadata: { name: "secret-demo" },
        type: "Opaque",
        stringData: { "password" => "secret" }
      },
      expected_types: {
        metadata: Kubernetes::V1ObjectMeta,
        string_data: Hash
      }
    },
    {
      klass: Kubernetes::V1Namespace,
      payload: {
        apiVersion: "v1",
        kind: "Namespace",
        metadata: { name: "namespace-demo" }
      },
      expected_types: {
        metadata: Kubernetes::V1ObjectMeta
      }
    },
    {
      klass: Kubernetes::V1PersistentVolumeClaimSpec,
      payload: {
        accessModes: ["ReadWriteOnce"],
        resources: { requests: { "storage" => "1Mi" } },
        storageClassName: ""
      },
      expected_types: {
        access_modes: Array,
        resources: Kubernetes::V1VolumeResourceRequirements
      }
    },
    {
      klass: Kubernetes::V1PersistentVolumeClaim,
      payload: {
        apiVersion: "v1",
        kind: "PersistentVolumeClaim",
        metadata: { name: "pvc-demo" },
        spec: {
          accessModes: ["ReadWriteOnce"],
          resources: { requests: { "storage" => "1Mi" } }
        }
      },
      expected_types: {
        metadata: Kubernetes::V1ObjectMeta,
        spec: Kubernetes::V1PersistentVolumeClaimSpec
      }
    },
    {
      klass: Kubernetes::V1PersistentVolumeSpec,
      payload: {
        capacity: { "storage" => "1Mi" },
        accessModes: ["ReadWriteOnce"],
        persistentVolumeReclaimPolicy: "Retain",
        hostPath: { path: "/tmp/kruby" }
      },
      expected_types: {
        capacity: Hash,
        host_path: Kubernetes::V1HostPathVolumeSource
      }
    },
    {
      klass: Kubernetes::V1PersistentVolume,
      payload: {
        apiVersion: "v1",
        kind: "PersistentVolume",
        metadata: { name: "pv-demo" },
        spec: {
          capacity: { "storage" => "1Mi" },
          accessModes: ["ReadWriteOnce"],
          hostPath: { path: "/tmp/kruby" }
        }
      },
      expected_types: {
        metadata: Kubernetes::V1ObjectMeta,
        spec: Kubernetes::V1PersistentVolumeSpec
      }
    },
    {
      klass: Kubernetes::V1LabelSelector,
      payload: {
        matchLabels: { "app" => "demo" }
      },
      expected_types: {
        match_labels: Hash
      }
    },
    {
      klass: Kubernetes::V1PodTemplateSpec,
      payload: {
        metadata: { labels: { "app" => "demo" } },
        spec: { containers: [{ name: "app", image: "registry.k8s.io/pause:3.9" }] }
      },
      expected_types: {
        metadata: Kubernetes::V1ObjectMeta,
        spec: Kubernetes::V1PodSpec
      }
    },
    {
      klass: Kubernetes::V1DeploymentSpec,
      payload: {
        replicas: "2",
        selector: { matchLabels: { "app" => "demo" } },
        template: {
          metadata: { labels: { "app" => "demo" } },
          spec: { containers: [{ name: "app", image: "registry.k8s.io/pause:3.9" }] }
        }
      },
      expected_types: {
        replicas: Integer,
        selector: Kubernetes::V1LabelSelector,
        template: Kubernetes::V1PodTemplateSpec
      },
      expected_values: {
        replicas: 2
      }
    },
    {
      klass: Kubernetes::V1Deployment,
      payload: {
        apiVersion: "apps/v1",
        kind: "Deployment",
        metadata: { name: "deployment-demo" },
        spec: {
          selector: { matchLabels: { "app" => "demo" } },
          template: {
            metadata: { labels: { "app" => "demo" } },
            spec: { containers: [{ name: "app", image: "registry.k8s.io/pause:3.9" }] }
          }
        }
      },
      expected_types: {
        metadata: Kubernetes::V1ObjectMeta,
        spec: Kubernetes::V1DeploymentSpec
      }
    },
    {
      klass: Kubernetes::V1ReplicaSet,
      payload: {
        apiVersion: "apps/v1",
        kind: "ReplicaSet",
        metadata: { name: "replicaset-demo" },
        spec: {
          replicas: 0,
          selector: { matchLabels: { "app" => "demo" } },
          template: {
            metadata: { labels: { "app" => "demo" } },
            spec: { containers: [{ name: "app", image: "registry.k8s.io/pause:3.9" }] }
          }
        }
      },
      expected_types: {
        metadata: Kubernetes::V1ObjectMeta,
        spec: Kubernetes::V1ReplicaSetSpec
      }
    },
    {
      klass: Kubernetes::V1StatefulSet,
      payload: {
        apiVersion: "apps/v1",
        kind: "StatefulSet",
        metadata: { name: "statefulset-demo" },
        spec: {
          serviceName: "statefulset-demo",
          replicas: 0,
          selector: { matchLabels: { "app" => "demo" } },
          template: {
            metadata: { labels: { "app" => "demo" } },
            spec: { containers: [{ name: "app", image: "registry.k8s.io/pause:3.9" }] }
          }
        }
      },
      expected_types: {
        metadata: Kubernetes::V1ObjectMeta,
        spec: Kubernetes::V1StatefulSetSpec
      }
    },
    {
      klass: Kubernetes::V1DaemonSet,
      payload: {
        apiVersion: "apps/v1",
        kind: "DaemonSet",
        metadata: { name: "daemonset-demo" },
        spec: {
          selector: { matchLabels: { "app" => "demo" } },
          template: {
            metadata: { labels: { "app" => "demo" } },
            spec: { containers: [{ name: "app", image: "registry.k8s.io/pause:3.9" }] }
          }
        }
      },
      expected_types: {
        metadata: Kubernetes::V1ObjectMeta,
        spec: Kubernetes::V1DaemonSetSpec
      }
    },
    {
      klass: Kubernetes::V1Job,
      payload: {
        apiVersion: "batch/v1",
        kind: "Job",
        metadata: { name: "job-demo" },
        spec: {
          template: {
            spec: {
              restartPolicy: "Never",
              containers: [{ name: "app", image: "registry.k8s.io/pause:3.9" }]
            }
          }
        }
      },
      expected_types: {
        metadata: Kubernetes::V1ObjectMeta,
        spec: Kubernetes::V1JobSpec
      }
    },
    {
      klass: Kubernetes::V1Ingress,
      payload: {
        apiVersion: "networking.k8s.io/v1",
        kind: "Ingress",
        metadata: { name: "ingress-demo" },
        spec: { ingressClassName: "nginx" }
      },
      expected_types: {
        metadata: Kubernetes::V1ObjectMeta,
        spec: Kubernetes::V1IngressSpec
      }
    },
    {
      klass: Kubernetes::V1IngressSpec,
      payload: {
        ingressClassName: "nginx"
      },
      expected_values: {
        ingress_class_name: "nginx"
      }
    },
    {
      klass: Kubernetes::V1NetworkPolicy,
      payload: {
        apiVersion: "networking.k8s.io/v1",
        kind: "NetworkPolicy",
        metadata: { name: "networkpolicy-demo" },
        spec: {
          podSelector: { matchLabels: { "app" => "demo" } },
          policyTypes: ["Ingress"]
        }
      },
      expected_types: {
        metadata: Kubernetes::V1ObjectMeta,
        spec: Kubernetes::V1NetworkPolicySpec
      }
    },
    {
      klass: Kubernetes::V1PolicyRule,
      payload: {
        apiGroups: [""],
        resources: ["pods"],
        verbs: ["get", "list"]
      },
      expected_types: {
        api_groups: Array,
        resources: Array,
        verbs: Array
      }
    },
    {
      klass: Kubernetes::V1Role,
      payload: {
        apiVersion: "rbac.authorization.k8s.io/v1",
        kind: "Role",
        metadata: { name: "role-demo" },
        rules: [
          { apiGroups: [""], resources: ["pods"], verbs: ["get"] }
        ]
      },
      expected_types: {
        metadata: Kubernetes::V1ObjectMeta,
        rules: Array
      }
    },
    {
      klass: Kubernetes::V1RoleBinding,
      payload: {
        apiVersion: "rbac.authorization.k8s.io/v1",
        kind: "RoleBinding",
        metadata: { name: "rolebinding-demo" },
        roleRef: {
          apiGroup: "rbac.authorization.k8s.io",
          kind: "Role",
          name: "role-demo"
        },
        subjects: [
          { kind: "ServiceAccount", name: "default", namespace: "default" }
        ]
      },
      expected_types: {
        metadata: Kubernetes::V1ObjectMeta,
        role_ref: Kubernetes::V1RoleRef,
        subjects: Array
      }
    },
    {
      klass: Kubernetes::V1Status,
      payload: {
        status: "Failure",
        message: "not found",
        reason: "NotFound",
        code: "404"
      },
      expected_values: {
        code: 404
      }
    },
    {
      klass: Kubernetes::V2HorizontalPodAutoscaler,
      payload: {
        apiVersion: "autoscaling/v2",
        kind: "HorizontalPodAutoscaler",
        metadata: { name: "hpa-demo" },
        spec: {
          scaleTargetRef: {
            apiVersion: "apps/v1",
            kind: "Deployment",
            name: "deployment-demo"
          },
          minReplicas: 1,
          maxReplicas: "3"
        }
      },
      expected_types: {
        metadata: Kubernetes::V1ObjectMeta,
        spec: Kubernetes::V2HorizontalPodAutoscalerSpec
      }
    },
    {
      klass: Kubernetes::V1StorageClass,
      payload: {
        apiVersion: "storage.k8s.io/v1",
        kind: "StorageClass",
        metadata: { name: "storageclass-demo" },
        provisioner: "kubernetes.io/no-provisioner",
        volumeBindingMode: "WaitForFirstConsumer"
      },
      expected_types: {
        metadata: Kubernetes::V1ObjectMeta
      }
    },
    {
      klass: Kubernetes::V1ProjectedVolumeSource,
      payload: {
        defaultMode: "420",
        sources: [
          {
            configMap: {
              name: "app-config",
              items: [{ key: "config.yaml", path: "configs/app.yaml" }]
            }
          },
          {
            secret: {
              name: "app-secret",
              optional: "true",
              items: [{ key: "token", path: "creds/token" }]
            }
          },
          {
            serviceAccountToken: {
              path: "token",
              expirationSeconds: "3600"
            }
          }
        ]
      },
      expected_types: {
        sources: Array
      },
      expected_values: {
        default_mode: 420
      }
    },
    {
      klass: Kubernetes::V1Probe,
      payload: {
        httpGet: {
          path: "/healthz",
          port: "8080",
          scheme: "HTTP"
        },
        initialDelaySeconds: "5",
        timeoutSeconds: "3",
        failureThreshold: "2",
        terminationGracePeriodSeconds: "1"
      },
      expected_types: {
        http_get: Kubernetes::V1HTTPGetAction
      },
      expected_values: {
        initial_delay_seconds: 5,
        timeout_seconds: 3,
        failure_threshold: 2,
        termination_grace_period_seconds: 1
      }
    },
    {
      klass: Kubernetes::V1alpha1ClusterTrustBundle,
      payload: {
        apiVersion: "certificates.k8s.io/v1alpha1",
        kind: "ClusterTrustBundle",
        metadata: { name: "example.com:signer:v1" },
        spec: {
          signerName: "example.com/signer",
          trustBundle: "-----BEGIN CERTIFICATE-----\nMIIB\n-----END CERTIFICATE-----\n"
        }
      },
      expected_types: {
        metadata: Kubernetes::V1ObjectMeta,
        spec: Kubernetes::V1alpha1ClusterTrustBundleSpec
      }
    }
  ].freeze

  it "deserializes representative models and serializes them back to Kubernetes JSON keys" do
    expect(MODEL_CASES.length).to be >= 20

    MODEL_CASES.each do |test_case|
      model = test_case.fetch(:klass).build_from_hash(test_case.fetch(:payload))

      expect(model).to be_a(test_case.fetch(:klass))

      test_case.fetch(:expected_types, {}).each do |attribute, expected_type|
        expect(model.public_send(attribute)).to be_a(expected_type), "#{test_case.fetch(:klass)}##{attribute}"
      end

      test_case.fetch(:expected_values, {}).each do |attribute, expected_value|
        expect(model.public_send(attribute)).to eq(expected_value), "#{test_case.fetch(:klass)}##{attribute}"
      end

      serialized = model.to_hash
      expect(model.to_body).to eq(serialized)
      test_case.fetch(:payload).each_key do |json_key|
        expect(serialized).to have_key(json_key), "#{test_case.fetch(:klass)} serialized #{json_key}"
      end
    end
  end

  it "accepts symbol and string keys for initializer attributes" do
    symbol_keyed = Kubernetes::V1ObjectMeta.new(name: "symbol-name")
    string_keyed = Kubernetes::V1ObjectMeta.new("name" => "string-name")

    expect(symbol_keyed.name).to eq("symbol-name")
    expect(string_keyed.name).to eq("string-name")
  end

  it "rejects unknown initializer attributes" do
    expect do
      Kubernetes::V1Pod.new(not_a_real_attribute: "value")
    end.to raise_error(ArgumentError, /not_a_real_attribute/)
  end

  it "round-trips special characters and non-ASCII strings" do
    model = Kubernetes::V1ConfigMap.build_from_hash(
      {
        apiVersion: "v1",
        kind: "ConfigMap",
        metadata: { name: "unicode-demo" },
        data: {
          "message" => "こんにちは\nkruby",
          "json" => "{\"enabled\":true}",
          "emoji_like_text" => "plain-ascii:-)"
        }
      }
    )

    expect(model.data["message"]).to eq("こんにちは\nkruby")
    serialized = model.to_hash
    serialized_data = serialized["data"] || serialized[:data]
    expect(serialized_data["message"]).to eq("こんにちは\nkruby")
  end

  it "keeps required-field validation for models with mandatory nested specs" do
    bundle = Kubernetes::V1alpha1ClusterTrustBundle.build_from_hash(
      {
        apiVersion: "certificates.k8s.io/v1alpha1",
        kind: "ClusterTrustBundle",
        metadata: { name: "missing-spec" }
      }
    )

    expect(bundle).not_to be_valid
    expect(bundle.list_invalid_properties).to include(/spec cannot be nil/)
  end

  it "compares model equality and hash code by attributes" do
    first = Kubernetes::V1ConfigMap.new(
      metadata: Kubernetes::V1ObjectMeta.new(name: "config-demo"),
      data: { "setting" => "enabled" }
    )
    second = Kubernetes::V1ConfigMap.new(
      metadata: Kubernetes::V1ObjectMeta.new(name: "config-demo"),
      data: { "setting" => "enabled" }
    )

    expect(first).to eq(second)
    expect(first).to eql(second)
    expect(first.hash).to eq(second.hash)
  end
end

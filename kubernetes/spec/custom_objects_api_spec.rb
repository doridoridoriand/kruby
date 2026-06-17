# frozen_string_literal: true

require "spec_helper"
require "webmock/rspec"

RSpec.describe Kubernetes::CustomObjectsApi do
  let(:config) do
    Kubernetes::Configuration.new.tap do |c|
      c.scheme = "https"
      c.host = "k8s.example.com"
      c.base_path = ""
    end
  end
  let(:api_client) { Kubernetes::ApiClient.new(config) }
  let(:api) { Kubernetes::CustomObjectsApi.new(api_client) }

  describe "#get_cluster_custom_object" do
    it "returns deserialized data on success" do
      body_json = { apiVersion: "example.com/v1", kind: "Example", metadata: { name: "my-crd" } }.to_json
      WebMock.stub_request(:get, "https://k8s.example.com/apis/example.com/v1/examples/my-crd")
        .to_return(status: 200, body: body_json, headers: { "Content-Type" => "application/json" })

      result, status, _ = api.get_cluster_custom_object_with_http_info("example.com", "v1", "examples", "my-crd")
      expect(status).to eq(200)
      expect(result).to be_a(Hash)
      expect(result[:metadata][:name]).to eq("my-crd")
    end

    it "raises ApiError on 404" do
      WebMock.stub_request(:get, "https://k8s.example.com/apis/example.com/v1/examples/notfound")
        .to_return(status: 404, body: { message: "not found", reason: "NotFound" }.to_json)

      expect { api.get_cluster_custom_object("example.com", "v1", "examples", "notfound") }.to raise_error(Kubernetes::ApiError) do |e|
        expect(e.code).to eq(404)
      end
    end

    it "raises ApiError on 500" do
      WebMock.stub_request(:get, "https://k8s.example.com/apis/example.com/v1/examples/my-crd")
        .to_return(status: 500, body: { message: "internal error" }.to_json)

      expect { api.get_cluster_custom_object("example.com", "v1", "examples", "my-crd") }.to raise_error(Kubernetes::ApiError) do |e|
        expect(e.code).to eq(500)
      end
    end

    it "raises ArgumentError when group is nil" do
      api.api_client.config.client_side_validation = true
      expect { api.get_cluster_custom_object(nil, "v1", "examples", "my-crd") }.to raise_error(ArgumentError, /group/)
    end

    it "raises ArgumentError when version is nil" do
      api.api_client.config.client_side_validation = true
      expect { api.get_cluster_custom_object("example.com", nil, "examples", "my-crd") }.to raise_error(ArgumentError, /version/)
    end

    it "raises ArgumentError when plural is nil" do
      api.api_client.config.client_side_validation = true
      expect { api.get_cluster_custom_object("example.com", "v1", nil, "my-crd") }.to raise_error(ArgumentError, /plural/)
    end

    it "raises ArgumentError when name is nil" do
      api.api_client.config.client_side_validation = true
      expect { api.get_cluster_custom_object("example.com", "v1", "examples", nil) }.to raise_error(ArgumentError, /name/)
    end
  end

  describe "#get_namespaced_custom_object" do
    it "returns namespaced custom object data on success" do
      body_json = { apiVersion: "example.com/v1", kind: "Example", metadata: { name: "my-crd", namespace: "default" } }.to_json
      WebMock.stub_request(:get, "https://k8s.example.com/apis/example.com/v1/namespaces/default/examples/my-crd")
        .to_return(status: 200, body: body_json, headers: { "Content-Type" => "application/json" })

      result, status, _ = api.get_namespaced_custom_object_with_http_info("example.com", "v1", "default", "examples", "my-crd")
      expect(status).to eq(200)
      expect(result[:metadata][:name]).to eq("my-crd")
      expect(result[:metadata][:namespace]).to eq("default")
    end

    it "raises ApiError on 403 forbidden" do
      WebMock.stub_request(:get, "https://k8s.example.com/apis/example.com/v1/namespaces/default/examples/my-crd")
        .to_return(status: 403, body: { message: "forbidden", reason: "Forbidden" }.to_json)

      expect { api.get_namespaced_custom_object("example.com", "v1", "default", "examples", "my-crd") }.to raise_error(Kubernetes::ApiError) do |e|
        expect(e.code).to eq(403)
      end
    end

    it "raises ArgumentError when namespace is nil" do
      api.api_client.config.client_side_validation = true
      expect { api.get_namespaced_custom_object("example.com", "v1", nil, "examples", "my-crd") }.to raise_error(ArgumentError, /namespace/)
    end
  end

  describe "#create_cluster_custom_object" do
    it "creates and returns the custom object" do
      body = { apiVersion: "example.com/v1", kind: "Example", metadata: { name: "new-crd" }, spec: { replicas: 3 } }
      response = { apiVersion: "example.com/v1", kind: "Example", metadata: { name: "new-crd", uid: "abc-123" }, spec: { replicas: 3 } }

      WebMock.stub_request(:post, "https://k8s.example.com/apis/example.com/v1/examples")
        .to_return(status: 201, body: response.to_json, headers: { "Content-Type" => "application/json" })

      result, status, _ = api.create_cluster_custom_object_with_http_info("example.com", "v1", "examples", body)
      expect(status).to eq(201)
      expect(result[:metadata][:name]).to eq("new-crd")
      expect(result[:metadata][:uid]).to eq("abc-123")
    end

    it "raises ApiError on 409 conflict" do
      body = { apiVersion: "example.com/v1", kind: "Example", metadata: { name: "exists" } }
      WebMock.stub_request(:post, "https://k8s.example.com/apis/example.com/v1/examples")
        .to_return(status: 409, body: { message: "already exists", reason: "AlreadyExists" }.to_json)

      expect { api.create_cluster_custom_object("example.com", "v1", "examples", body) }.to raise_error(Kubernetes::ApiError) do |e|
        expect(e.code).to eq(409)
      end
    end

    it "raises ArgumentError when body is nil" do
      api.api_client.config.client_side_validation = true
      expect { api.create_cluster_custom_object("example.com", "v1", "examples", nil) }.to raise_error(ArgumentError, /body/)
    end
  end

  describe "#create_namespaced_custom_object" do
    it "creates and returns the namespaced custom object" do
      body = { apiVersion: "example.com/v1", kind: "Example", metadata: { name: "new-crd", namespace: "dev" } }
      response = { apiVersion: "example.com/v1", kind: "Example", metadata: { name: "new-crd", namespace: "dev", uid: "xyz-789" } }

      WebMock.stub_request(:post, "https://k8s.example.com/apis/example.com/v1/namespaces/dev/examples")
        .to_return(status: 201, body: response.to_json, headers: { "Content-Type" => "application/json" })

      result, status, _ = api.create_namespaced_custom_object_with_http_info("example.com", "v1", "dev", "examples", body)
      expect(status).to eq(201)
      expect(result[:metadata][:uid]).to eq("xyz-789")
    end
  end

  describe "#delete_cluster_custom_object" do
    it "deletes and returns status on success" do
      response = { kind: "Status", status: "Success", message: "deleted" }
      WebMock.stub_request(:delete, "https://k8s.example.com/apis/example.com/v1/examples/my-crd")
        .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })

      result, status, _ = api.delete_cluster_custom_object_with_http_info("example.com", "v1", "examples", "my-crd")
      expect(status).to eq(200)
      expect(result[:status]).to eq("Success")
    end

    it "raises ArgumentError when name is nil" do
      api.api_client.config.client_side_validation = true
      expect { api.delete_cluster_custom_object("example.com", "v1", "examples", nil) }.to raise_error(ArgumentError, /name/)
    end

    it "raises ArgumentError when plural is nil" do
      api.api_client.config.client_side_validation = true
      expect { api.delete_cluster_custom_object("example.com", "v1", nil, "my-crd") }.to raise_error(ArgumentError, /plural/)
    end
  end

  describe "#delete_namespaced_custom_object" do
    it "deletes and returns status on success" do
      response = { kind: "Status", status: "Success", message: "deleted" }
      WebMock.stub_request(:delete, "https://k8s.example.com/apis/example.com/v1/namespaces/default/examples/my-crd")
        .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })

      result, status, _ = api.delete_namespaced_custom_object_with_http_info("example.com", "v1", "default", "examples", "my-crd")
      expect(status).to eq(200)
      expect(result[:status]).to eq("Success")
    end

    it "raises ArgumentError when namespace is nil" do
      api.api_client.config.client_side_validation = true
      expect { api.delete_namespaced_custom_object("example.com", "v1", nil, "examples", "my-crd") }.to raise_error(ArgumentError, /namespace/)
    end
  end

  describe "#list_cluster_custom_object" do
    it "returns a list of custom objects" do
      response = {
        apiVersion: "v1",
        kind: "List",
        items: [
          { metadata: { name: "obj1" } },
          { metadata: { name: "obj2" } }
        ]
      }
      WebMock.stub_request(:get, "https://k8s.example.com/apis/example.com/v1/examples")
        .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })

      result, status, _ = api.list_cluster_custom_object_with_http_info("example.com", "v1", "examples")
      expect(status).to eq(200)
      expect(result[:items].length).to eq(2)
    end

    it "passes label_selector query param" do
      response = { apiVersion: "v1", kind: "List", items: [{ metadata: { name: "obj1" } }] }
      WebMock.stub_request(:get, "https://k8s.example.com/apis/example.com/v1/examples?labelSelector=app=test")
        .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })

      api.list_cluster_custom_object("example.com", "v1", "examples", label_selector: "app=test")
    end

    it "passes list query parameters" do
      response = { apiVersion: "v1", kind: "List", items: [] }
      WebMock.stub_request(:get, "https://k8s.example.com/apis/example.com/v1/examples?labelSelector=app=test&fieldSelector=status.phase=Running&limit=10")
        .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })

      api.list_cluster_custom_object("example.com", "v1", "examples",
                                     label_selector: "app=test",
                                     field_selector: "status.phase=Running",
                                     limit: 10)
    end

    it "raises ArgumentError when group is nil" do
      api.api_client.config.client_side_validation = true
      expect { api.list_cluster_custom_object(nil, "v1", "examples") }.to raise_error(ArgumentError, /group/)
    end
  end

  describe "#list_namespaced_custom_object" do
    it "returns a list of namespaced custom objects" do
      response = { apiVersion: "v1", kind: "List", items: [{ metadata: { name: "obj1", namespace: "default" } }] }
      WebMock.stub_request(:get, "https://k8s.example.com/apis/example.com/v1/namespaces/default/examples")
        .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })

      result, status, _ = api.list_namespaced_custom_object_with_http_info("example.com", "v1", "default", "examples")
      expect(status).to eq(200)
      expect(result[:items][0][:metadata][:namespace]).to eq("default")
    end

    it "passes field_selector query param" do
      response = { apiVersion: "v1", kind: "List", items: [] }
      WebMock.stub_request(:get, "https://k8s.example.com/apis/example.com/v1/namespaces/default/examples?fieldSelector=metadata.name=myobj")
        .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })

      api.list_namespaced_custom_object("example.com", "v1", "default", "examples", field_selector: "metadata.name=myobj")
    end

    it "raises ArgumentError when namespace is nil" do
      api.api_client.config.client_side_validation = true
      expect { api.list_namespaced_custom_object("example.com", "v1", nil, "examples") }.to raise_error(ArgumentError, /namespace/)
    end
  end

  describe "#get_cluster_custom_object_status" do
    it "returns status subresource" do
      response = { metadata: { name: "my-crd" }, status: { ready: true } }
      WebMock.stub_request(:get, "https://k8s.example.com/apis/example.com/v1/examples/my-crd/status")
        .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })

      result, status, _ = api.get_cluster_custom_object_status_with_http_info("example.com", "v1", "examples", "my-crd")
      expect(status).to eq(200)
      expect(result[:status][:ready]).to be true
    end
  end

  describe "#get_namespaced_custom_object_status" do
    it "returns namespaced status subresource" do
      response = { metadata: { name: "my-crd", namespace: "default" }, status: { conditions: [] } }
      WebMock.stub_request(:get, "https://k8s.example.com/apis/example.com/v1/namespaces/default/examples/my-crd/status")
        .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })

      result, status, _ = api.get_namespaced_custom_object_status_with_http_info("example.com", "v1", "default", "examples", "my-crd")
      expect(status).to eq(200)
      expect(result[:status][:conditions]).to eq([])
    end
  end

  describe "#replace_cluster_custom_object" do
    it "replaces and returns updated custom object" do
      body = { apiVersion: "example.com/v1", kind: "Example", metadata: { name: "my-crd", resourceVersion: "123" }, spec: { replicas: 5 } }
      response = { apiVersion: "example.com/v1", kind: "Example", metadata: { name: "my-crd", resourceVersion: "124" }, spec: { replicas: 5 } }

      WebMock.stub_request(:put, "https://k8s.example.com/apis/example.com/v1/examples/my-crd")
        .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })

      result, status, _ = api.replace_cluster_custom_object_with_http_info("example.com", "v1", "examples", "my-crd", body)
      expect(status).to eq(200)
      expect(result[:spec][:replicas]).to eq(5)
    end

    it "raises ArgumentError when name is nil" do
      api.api_client.config.client_side_validation = true
      expect { api.replace_cluster_custom_object("example.com", "v1", "examples", nil, {}) }.to raise_error(ArgumentError, /name/)
    end

    it "raises ApiError on 409 conflict" do
      body = { apiVersion: "example.com/v1", kind: "Example", metadata: { name: "my-crd", resourceVersion: "old" } }
      WebMock.stub_request(:put, "https://k8s.example.com/apis/example.com/v1/examples/my-crd")
        .to_return(status: 409, body: { message: "conflict", reason: "Conflict" }.to_json)

      expect { api.replace_cluster_custom_object("example.com", "v1", "examples", "my-crd", body) }.to raise_error(Kubernetes::ApiError) do |e|
        expect(e.code).to eq(409)
      end
    end
  end

  describe "#patch_cluster_custom_object" do
    it "patches and returns updated custom object" do
      body = { spec: { replicas: 10 } }
      response = { apiVersion: "example.com/v1", kind: "Example", metadata: { name: "my-crd", resourceVersion: "125" }, spec: { replicas: 10 } }

      WebMock.stub_request(:patch, "https://k8s.example.com/apis/example.com/v1/examples/my-crd")
        .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })

      result, status_code, _ = api.patch_cluster_custom_object_with_http_info("example.com", "v1", "examples", "my-crd", body)
      expect(status_code).to eq(200)
      expect(result[:spec][:replicas]).to eq(10)
    end

    it "raises ArgumentError when name is nil" do
      api.api_client.config.client_side_validation = true
      expect { api.patch_cluster_custom_object("example.com", "v1", "examples", nil, {}) }.to raise_error(ArgumentError, /name/)
    end
  end

  describe "#list_custom_object_for_all_namespaces" do
    it "returns list across all namespaces" do
      response = {
        apiVersion: "v1", kind: "List",
        items: [
          { metadata: { name: "obj1", namespace: "ns1" } },
          { metadata: { name: "obj2", namespace: "ns2" } }
        ]
      }
      WebMock.stub_request(:get, /https:\/\/k8s\.example\.com\/apis\/example\.com\/v1\/examples/)
        .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })

      result, status, _ = api.list_custom_object_for_all_namespaces_with_http_info("example.com", "v1", "examples")
      expect(status).to eq(200)
      expect(result[:items].length).to eq(2)
    end
  end

  describe "#delete_collection_cluster_custom_object" do
    it "deletes collection and returns status" do
      response = { kind: "Status", status: "Success", details: { kind: "examples" } }
      WebMock.stub_request(:delete, "https://k8s.example.com/apis/example.com/v1/examples")
        .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })

      result, status, _ = api.delete_collection_cluster_custom_object_with_http_info("example.com", "v1", "examples")
      expect(status).to eq(200)
      expect(result[:status]).to eq("Success")
    end

    it "passes label_selector for selective deletion" do
      response = { kind: "Status", status: "Success" }
      WebMock.stub_request(:delete, "https://k8s.example.com/apis/example.com/v1/examples?labelSelector=app=old")
        .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })

      api.delete_collection_cluster_custom_object("example.com", "v1", "examples", label_selector: "app=old")
    end
  end

  describe "#delete_collection_namespaced_custom_object" do
    it "deletes namespaced collection and returns status" do
      response = { kind: "Status", status: "Success", details: { kind: "examples" } }
      WebMock.stub_request(:delete, "https://k8s.example.com/apis/example.com/v1/namespaces/default/examples")
        .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })

      result, status, _ = api.delete_collection_namespaced_custom_object_with_http_info("example.com", "v1", "default", "examples")
      expect(status).to eq(200)
      expect(result[:status]).to eq("Success")
    end
  end
end

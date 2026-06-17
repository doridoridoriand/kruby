# frozen_string_literal: true

require "spec_helper"
require "base64"
require "fixtures/config/kube_config_hash"

require "kubernetes/config/kube_config"
require "kubernetes/config/incluster_config"

RSpec.describe "Authentication mechanisms" do
  # ========== KubeConfig Auth ==========
  describe Kubernetes::KubeConfig, "#setup_auth" do
    let(:kube_config) { Kubernetes::KubeConfig.new(nil, TEST_KUBE_CONFIG) }

    it "prefers token over username/password" do
      user = kube_config.find_user("simple_token")
      expect(user["authorization"]).to start_with("Bearer ")
      expect(user["authorization"]).not_to start_with("Basic ")
    end

    it "creates Bearer authorization header from token" do
      user = kube_config.find_user("simple_token")
      expect(user["authorization"]).to eq("Bearer #{TEST_DATA_BASE64}")
    end

    it "creates Basic authorization header from username/password" do
      user = kube_config.find_user("user_pass")
      expect(user["authorization"]).to eq(TEST_BASIC_TOKEN)
    end

    it "creates Bearer authorization from Azure auth-provider" do
      user = kube_config.find_user("user_azure")
      expect(user["authorization"]).to eq(TEST_AZURE_TOKEN)
    end

    it "creates temp files and sets Bearer token with client certificate data" do
      user = kube_config.find_user("user_cert_data")
      expect(user["authorization"]).to eq("Bearer #{TEST_DATA_BASE64}")
      expect(File.read(user["client-certificate"])).to eq(TEST_CLIENT_CERT)
      expect(File.read(user["client-key"])).to eq(TEST_CLIENT_KEY)
    end

    it "reads token from tokenFile" do
      user = kube_config.find_user("simple_token_file")
      expect(user["authorization"]).to eq("Bearer token1")
    end
  end

  # ========== TLS/SSL Configuration ==========
  describe Kubernetes::KubeConfig, "#setup_ssl and configure" do
    let(:kube_config) { Kubernetes::KubeConfig.new(nil, TEST_KUBE_CONFIG) }

    it "sets CA cert, client cert, client key, and verify_ssl for SSL context" do
      config = Kubernetes::Configuration.new
      kube_config.configure(config, "context_ssl")

      expect(config.scheme).to eq("https")
      expect(config.host).to eq("test-host:443")
      expect(config.ssl_ca_cert).to eq(Kubernetes::Testing.file_fixture("certs/ca.crt").to_s)
      expect(config.cert_file).to eq(Kubernetes::Testing.file_fixture("certs/client.crt").to_s)
      expect(config.key_file).to eq(Kubernetes::Testing.file_fixture("certs/client.key").to_s)
      expect(config.verify_ssl).to eq(true)
      expect(config.verify_ssl_host).to eq(true)
    end

    it "sets verify_ssl and verify_ssl_host to false for insecure context" do
      config = Kubernetes::Configuration.new
      kube_config.configure(config, "context_insecure")
      expect(config.verify_ssl).to eq(false)
      expect(config.verify_ssl_host).to eq(false)
    end

    it "sets bearer token authorization for token context" do
      config = Kubernetes::Configuration.new
      kube_config.configure(config, "context_token")
      expect(config.api_key["authorization"]).to eq("Bearer #{TEST_DATA_BASE64}")
      expect(config.scheme).to eq("https")
      expect(config.host).to eq("test-host:443")
    end

    it "creates temp file from certificate-authority-data" do
      cluster = kube_config.find_cluster("ssl-data")
      expect(File.read(cluster["certificate-authority"])).to eq(TEST_CERTIFICATE_AUTH)
      expect(cluster["verify_ssl"]).to eq(true)
    end

    it "sets verify_ssl to false when insecure-skip-tls-verify is true" do
      cluster = kube_config.find_cluster("ssl-data-insecure")
      expect(cluster["verify_ssl"]).to eq(false)
    end
  end

  # ========== Multiple Context Switching ==========
  describe Kubernetes::KubeConfig, "multiple contexts" do
    let(:kube_config) { Kubernetes::KubeConfig.new(nil, TEST_KUBE_CONFIG) }

    it "can switch between contexts with different auth methods" do
      ssl_config = Kubernetes::Configuration.new
      kube_config.configure(ssl_config, "context_ssl")
      expect(ssl_config.verify_ssl).to eq(true)

      token_config = Kubernetes::Configuration.new
      kube_config.configure(token_config, "context_token")
      expect(token_config.api_key["authorization"]).to start_with("Bearer ")
    end

    it "can switch between user and no-user contexts" do
      no_user_config = Kubernetes::Configuration.new
      kube_config.configure(no_user_config, "no_user")
      expect(no_user_config.host).to eq("test-host:80")

      token_config = Kubernetes::Configuration.new
      kube_config.configure(token_config, "context_token")
      expect(token_config.api_key["authorization"]).to start_with("Bearer ")
    end
  end

  # ========== InClusterConfig Extended ==========
  describe Kubernetes::InClusterConfig do
    let(:incluster_config) do
      Kubernetes::InClusterConfig.new.tap do |c|
        c.instance_variable_set(
          :@env,
          Kubernetes::InClusterConfig::SERVICE_HOST_ENV_NAME => "kubernetes.default.svc",
          Kubernetes::InClusterConfig::SERVICE_PORT_ENV_NAME => "443"
        )
        c.instance_variable_set(:@ca_cert, Kubernetes::Testing.file_fixture("certs/ca.crt").to_s)
        c.instance_variable_set(:@token_file, Kubernetes::Testing.file_fixture("tokens/token").to_s)
      end
    end

    it "sets Bearer token from token file" do
      config = Kubernetes::Configuration.new
      incluster_config.configure(config)
      expect(config.api_key["authorization"]).to eq("Bearer token1")
    end

    it "uses KUBERNETES_SERVICE_HOST:port for IP-based host" do
      incluster_config.instance_variable_set(
        :@env,
        Kubernetes::InClusterConfig::SERVICE_HOST_ENV_NAME => "10.96.0.1",
        Kubernetes::InClusterConfig::SERVICE_PORT_ENV_NAME => "6443"
      )
      config = Kubernetes::Configuration.new
      incluster_config.configure(config)
      expect(config.host).to eq("10.96.0.1:6443")
      expect(config.scheme).to eq("https")
    end

    it "raises ConfigError when token file does not exist" do
      incluster_config.instance_variable_set(:@token_file, "/nonexistent/token")
      expect { incluster_config.validate }.to raise_error(Kubernetes::ConfigError)
    end

    it "returns false when not in cluster environment" do
      stub_const("Kubernetes::InClusterConfig::SERVICE_TOKEN_FILENAME", "/nonexistent/token")
      stub_const("Kubernetes::InClusterConfig::SERVICE_CA_CERT_FILENAME", "/nonexistent/ca.crt")

      expect(Kubernetes::InClusterConfig.in_cluster?).to be false
    end
  end

  # ========== ApiClient Auth Integration ==========
  describe Kubernetes::ApiClient do
    let(:config) { Kubernetes::Configuration.new }
    let(:api_client) { Kubernetes::ApiClient.new(config) }

    describe "#update_params_for_auth!" do
      it "injects BearerToken into header params" do
        config.api_key["BearerToken"] = "Bearer my-token"
        header_params = {}
        api_client.update_params_for_auth!(header_params, {}, ["BearerToken"])
        expect(header_params["authorization"]).to eq("Bearer my-token")
      end

      it "handles multiple auth names" do
        config.api_key["BearerToken"] = "Bearer tok1"
        config.api_key["ApiKeyAuth"] = "key123"
        config.api_key_prefix["ApiKeyAuth"] = "Token"

        config.define_singleton_method(:auth_settings) do
          @auth_settings || {
            "BearerToken" => { type: "api_key", in: "header", key: "authorization",
                               value: api_key_with_prefix("BearerToken") },
            "ApiKeyAuth" => { type: "api_key", in: "header", key: "X-API-Key",
                              value: api_key_with_prefix("ApiKeyAuth") }
          }
        end

        header_params = {}
        api_client.update_params_for_auth!(header_params, {}, ["BearerToken", "ApiKeyAuth"])
        expect(header_params["authorization"]).to eq("Bearer tok1")
        expect(header_params["X-API-Key"]).to eq("Token key123")
      end

      it "skips unknown auth names" do
        expect { api_client.update_params_for_auth!({}, {}, ["UnknownAuth"]) }.not_to raise_error
      end

      it "raises ArgumentError for invalid auth location" do
        config.define_singleton_method(:auth_settings) do
          { "BadAuth" => { type: "api_key", in: "body", key: "auth", value: "x" } }
        end
        expect {
          api_client.update_params_for_auth!({}, {}, ["BadAuth"])
        }.to raise_error(ArgumentError, /Authentication token must be in/)
      end
    end

    describe "#build_request applies TLS and auth settings" do
      it "passes SSL options to Typhoeus request" do
        config.verify_ssl = false
        config.verify_ssl_host = false
        config.cert_file = "/path/to/client.crt"
        config.key_file = "/path/to/client.key"
        config.ssl_ca_cert = "/path/to/ca.crt"

        request = api_client.build_request(:get, "/api/v1/pods")
        expect(request.options[:ssl_verifypeer]).to eq(false)
        expect(request.options[:ssl_verifyhost]).to eq(0)
        expect(request.options[:sslcert]).to eq("/path/to/client.crt")
        expect(request.options[:sslkey]).to eq("/path/to/client.key")
        expect(request.options[:cainfo]).to eq("/path/to/ca.crt")
      end

      it "sets verify_ssl_host to 2 when verification enabled" do
        request = api_client.build_request(:get, "/api/v1/pods")
        expect(request.options[:ssl_verifypeer]).to eq(true)
        expect(request.options[:ssl_verifyhost]).to eq(2)
      end

      it "applies bearer token to request headers via auth_names" do
        config.api_key["BearerToken"] = "Bearer secret-token"
        request = api_client.build_request(:get, "/api/v1/pods", auth_names: ["BearerToken"])
        expect(request.options[:headers]["authorization"]).to eq("Bearer secret-token")
      end

      it "applies timeout to request" do
        config.timeout = 30
        request = api_client.build_request(:get, "/api/v1/pods")
        expect(request.options[:timeout]).to eq(30)
      end
    end
  end

  # ========== Configuration Auth ==========
  describe Kubernetes::Configuration, "auth" do
    it "handles basic auth with special characters" do
      config = Kubernetes::Configuration.new
      config.username = "user@domain.com"
      config.password = "p@ss:w0rd"

      token = config.basic_auth_token
      decoded = token.delete_prefix("Basic ").unpack1("m")
      expect(decoded).to eq("user@domain.com:p@ss:w0rd")
    end

    it "reflects updated BearerToken api_key in auth_settings" do
      config = Kubernetes::Configuration.new
      config.api_key["BearerToken"] = "Bearer old"
      expect(config.auth_settings["BearerToken"][:value]).to eq("Bearer old")

      config.api_key["BearerToken"] = "Bearer new"
      expect(config.auth_settings["BearerToken"][:value]).to eq("Bearer new")
    end

    it "stores cert and key file paths" do
      config = Kubernetes::Configuration.new
      config.cert_file = "/path/to/client.pem"
      config.key_file = "/path/to/key.pem"
      expect(config.cert_file).to eq("/path/to/client.pem")
      expect(config.key_file).to eq("/path/to/key.pem")
    end

    it "defaults to nil for cert_file and key_file" do
      config = Kubernetes::Configuration.new
      expect(config.cert_file).to be_nil
      expect(config.key_file).to be_nil
    end
  end

  # ========== KubeConfig Error Handling ==========
  describe Kubernetes::KubeConfig do
    let(:kube_config) { Kubernetes::KubeConfig.new(nil, TEST_KUBE_CONFIG) }

    it "raises ConfigError for unknown context" do
      expect { kube_config.find_context("nonexistent") }.to raise_error(Kubernetes::ConfigError, /context.*not found/)
    end

    it "raises ConfigError for unknown cluster" do
      expect { kube_config.find_cluster("nonexistent") }.to raise_error(Kubernetes::ConfigError, /cluster.*not found/)
    end

    it "raises ConfigError for unknown user" do
      expect { kube_config.find_user("nonexistent") }.to raise_error(Kubernetes::ConfigError, /user.*not found/)
    end
  end
end

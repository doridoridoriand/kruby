# frozen_string_literal: true

require "spec_helper"

RSpec.describe Kubernetes::Configuration do
  let(:config) { Kubernetes::Configuration.new }

  describe "#base_url" do
    it "returns default base_url when no server index" do
      config.scheme = "https"
      config.host = "k8s.example.com"
      config.base_path = "/api/v1"

      expect(config.base_url).to eq("https://k8s.example.com/api/v1")
    end

    it "removes trailing slashes" do
      config.scheme = "http"
      config.host = "localhost"

      [nil, "", "/", "//"].each do |base_path|
        config.base_path = base_path
        expect(config.base_url).to eq("http://localhost")
      end
    end

    it "returns base_url with scheme and host" do
      config.scheme = "https"
      config.host = "k8s.example.com"
      config.base_path = ""

      expect(config.base_url).to eq("https://k8s.example.com")
    end

    it "handles base_path normalization" do
      config.scheme = "https"
      config.host = "k8s.example.com"
      config.base_path = "/api//v1///"

      expect(config.base_url).to eq("https://k8s.example.com/api/v1")
    end

    it "uses server_url when server_index is set" do
      config.server_index = 0
      allow(config).to receive(:server_settings).and_return([
        { url: "https://custom.k8s.example.com/api/v1", description: "custom server" }
      ])

      expect(config.base_url).to eq("https://custom.k8s.example.com/api/v1")
    end
  end

  describe "#scheme=" do
    it "removes :// from scheme" do
      config.scheme = "https://"
      expect(config.scheme).to eq("https")
    end

    it "preserves scheme without ://" do
      config.scheme = "http"
      expect(config.scheme).to eq("http")
    end
  end

  describe "#host=" do
    it "removes http:// from host" do
      config.host = "http://example.com"
      expect(config.host).to eq("example.com")
    end

    it "removes https:// from host" do
      config.host = "https://example.com"
      expect(config.host).to eq("example.com")
    end

    it "removes trailing path from host" do
      config.host = "example.com/v4"
      expect(config.host).to eq("example.com")
    end

    it "handles host with https and path" do
      config.host = "https://example.com/api/v1"
      expect(config.host).to eq("example.com")
    end
  end

  describe "#base_path=" do
    it "prepends slash to base_path" do
      config.base_path = "v1/api"
      expect(config.base_path).to eq("/v1/api")
    end

    it "does not double-prepand slash" do
      config.base_path = "/v1/api"
      expect(config.base_path).to eq("/v1/api")
    end

    it "collapses multiple slashes" do
      config.base_path = "/v1///api"
      expect(config.base_path).to eq("/v1/api")
    end

    it "sets to empty string when only /" do
      config.base_path = "/"
      expect(config.base_path).to eq("")
    end

    it "handles nil base_path" do
      config.base_path = nil
      expect(config.base_path).to eq("")
    end
  end

  describe "#initialize" do
    it "sets default scheme to http" do
      expect(config.scheme).to eq("http")
    end

    it "sets default host to localhost" do
      expect(config.host).to eq("localhost")
    end

    it "sets default base_path to empty string" do
      expect(config.base_path).to eq("")
    end

    it "sets default timeout to 0" do
      expect(config.timeout).to eq(0)
    end

    it "sets default verify_ssl to true" do
      expect(config.verify_ssl).to eq(true)
    end

    it "sets default verify_ssl_host to true" do
      expect(config.verify_ssl_host).to eq(true)
    end

    it "sets default params_encoding to nil" do
      expect(config.params_encoding).to be_nil
    end

    it "accepts block configuration" do
      c = Kubernetes::Configuration.new do |cfg|
        cfg.scheme = "https"
        cfg.host = "example.com"
        cfg.timeout = 30
      end

      expect(c.scheme).to eq("https")
      expect(c.host).to eq("example.com")
      expect(c.timeout).to eq(30)
    end
  end

  describe ".default" do
    around do |example|
      described_class.reset_default
      example.run
    ensure
      described_class.reset_default
    end

    it "returns a Configuration object" do
      expect(Kubernetes::Configuration.default).to be_a(Kubernetes::Configuration)
    end

    it "is memoized" do
      first = Kubernetes::Configuration.default
      second = Kubernetes::Configuration.default
      expect(first).to be(second)
    end

    it "memoizes safely across concurrent callers" do
      allow(described_class).to receive(:new).and_wrap_original do |original, *args, &block|
        sleep 0.01
        original.call(*args, &block)
      end

      results = Array.new(8)
      threads = results.each_index.map do |index|
        Thread.new do
          results[index] = described_class.default
        end
      end
      threads.each(&:value)

      expect(results.uniq.length).to eq(1)
      expect(described_class).to have_received(:new).once
    end
  end

  describe ".default_config" do
    it "returns a configuration object" do
      expect(Kubernetes::Configuration.default_config).to be_a(Kubernetes::Configuration)
    end
  end

  describe "#configure" do
    it "yields self for block configuration" do
      config.configure do |c|
        c.scheme = "https"
        c.timeout = 60
      end

      expect(config.scheme).to eq("https")
      expect(config.timeout).to eq(60)
    end
  end

  describe "#api_key_with_prefix" do
    it "returns api_key without prefix when no prefix is set" do
      config.api_key = { "api_key" => "secret" }
      config.api_key_prefix = {}

      expect(config.api_key_with_prefix("api_key")).to eq("secret")
    end

    it "returns api_key with prefix when prefix is set" do
      config.api_key = { "BearerToken" => "abc123" }
      config.api_key_prefix = { "BearerToken" => "Bearer" }

      expect(config.api_key_with_prefix("BearerToken")).to eq("Bearer abc123")
    end

    it "returns nil when api_key is not set" do
      config.api_key = {}
      config.api_key_prefix = {}

      expect(config.api_key_with_prefix("nonexistent")).to be_nil
    end

    it "uses param_alias when primary param is not found" do
      config.api_key = { "primary" => "fallback" }
      config.api_key_prefix = {}

      expect(config.api_key_with_prefix("nonexistent", "primary")).to eq("fallback")
    end
  end

  describe "#basic_auth_token" do
    it "returns Basic auth token" do
      config.username = "admin"
      config.password = "secret"

      token = config.basic_auth_token
      expect(token).to start_with("Basic ")
      decoded = token.delete_prefix("Basic ").unpack1("m").delete("\r\n")
      expect(decoded).to eq("admin:secret")
    end
  end

  describe "#auth_settings" do
    it "returns a hash with BearerToken" do
      settings = config.auth_settings
      expect(settings).to have_key("BearerToken")
      expect(settings["BearerToken"][:type]).to eq("api_key")
      expect(settings["BearerToken"][:in]).to eq("header")
      expect(settings["BearerToken"][:key]).to eq("authorization")
    end
  end

  describe "#server_url" do
    it "returns server URL for valid index" do
      url = config.server_url(0, {}, [{ url: "https://k8s.example.com", description: "default" }])
      expect(url).to eq("https://k8s.example.com")
    end

    it "raises ArgumentError for negative index" do
      expect { config.server_url(-1) }.to raise_error(ArgumentError, /Invalid index -1/)
    end

    it "raises ArgumentError for out-of-range index" do
      expect { config.server_url(10) }.to raise_error(ArgumentError, /Invalid index 10/)
    end

    it "substitutes server variables" do
      servers = [
        {
          url: "https://{region}.k8s.example.com/api",
          description: "server with variable",
          variables: {
            region: { default_value: "us-west", enum_values: ["us-west", "eu-central"] }
          }
        }
      ]

      url = config.server_url(0, {}, servers)
      expect(url).to eq("https://us-west.k8s.example.com/api")
    end

    it "uses provided variable value" do
      servers = [
        {
          url: "https://{region}.k8s.example.com/api",
          description: "server with variable",
          variables: {
            region: { default_value: "us-west", enum_values: ["us-west", "eu-central"] }
          }
        }
      ]

      url = config.server_url(0, { "region" => "eu-central" }, servers)
      expect(url).to eq("https://eu-central.k8s.example.com/api")
    end

    it "raises ArgumentError for invalid enum value" do
      servers = [
        {
          url: "https://{region}.k8s.example.com/api",
          description: "server with variable",
          variables: {
            region: { default_value: "us-west", enum_values: ["us-west", "eu-central"] }
          }
        }
      ]

      expect { config.server_url(0, { "region" => "invalid" }, servers) }
        .to raise_error(ArgumentError, /invalid value/)
    end

    it "works without variables" do
      url = config.server_url(0, {}, [{ url: "https://static.k8s.example.com", description: "static" }])
      expect(url).to eq("https://static.k8s.example.com")
    end

    it "handles multiple variables" do
      servers = [
        {
          url: "https://{region}.{env}.k8s.example.com",
          description: "multi-var server",
          variables: {
            region: { default_value: "us" },
            env: { default_value: "prod" }
          }
        }
      ]

      url = config.server_url(0, { "env" => "dev" }, servers)
      expect(url).to eq("https://us.dev.k8s.example.com")
    end
  end

  describe "#server_settings" do
    it "returns array of server settings" do
      settings = config.server_settings
      expect(settings).to be_an(Array)
      expect(settings.first).to have_key(:url)
      expect(settings.first).to have_key(:description)
    end
  end

  describe "#operation_server_settings" do
    it "returns empty hash by default" do
      expect(config.operation_server_settings).to eq({})
    end
  end

  describe "#timeout" do
    it "can be customized" do
      config.timeout = 120
      expect(config.timeout).to eq(120)
    end

    it "defaults to 0" do
      expect(config.timeout).to eq(0)
    end
  end

  describe "#verify_ssl" do
    it "can be set to false" do
      config.verify_ssl = false
      expect(config.verify_ssl).to eq(false)
    end
  end

  describe "#verify_ssl_host" do
    it "can be set to false" do
      config.verify_ssl_host = false
      expect(config.verify_ssl_host).to eq(false)
    end
  end

  describe "#ssl_ca_cert" do
    it "can be set to custom CA cert path" do
      config.ssl_ca_cert = "/path/to/ca.pem"
      expect(config.ssl_ca_cert).to eq("/path/to/ca.pem")
    end
  end

  describe "#debugging" do
    it "can be set to true" do
      config.debugging = true
      expect(config.debugging).to eq(true)
    end

    it "defaults to false" do
      expect(config.debugging).to eq(false)
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe SpecSupport::E2E::Factories do
  describe ".ip_address" do
    it "builds a networking.k8s.io/v1 IPAddress with a valid parentRef spec" do
      body = described_class.ip_address(
        name: "192.0.2.10",
        labels: { "app.kubernetes.io/name" => "kruby-e2e" }
      )

      expect(body).to include(
        "apiVersion" => "networking.k8s.io/v1",
        "kind" => "IPAddress"
      )
      expect(body["metadata"]).to include(
        "name" => "192.0.2.10",
        "labels" => { "app.kubernetes.io/name" => "kruby-e2e" }
      )
      expect(body["spec"]).to include(
        "parentRef" => include(
          "resource" => "services",
          "namespace" => "default",
          "name" => "kruby-e2e-ip-192-0-2-10"
        )
      )
      expect(body).not_to have_key("parent")
      expect(body).not_to have_key("type")
      expect(body).not_to have_key("address")
    end
  end
end

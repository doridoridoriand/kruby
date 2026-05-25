# frozen_string_literal: true

require_relative "../support/e2e/spec_runner"
require_relative "../support/e2e/targets/networking_v1_ingress_class"

RSpec.describe "E2E - networking.k8s.io/v1/ingressclasses" do
  include SpecSupport::E2E::SpecRunner

  E2E_TARGET_GROUP_ID = "networking_v1_ingress_class"

  describe "ingress_class" do
    let(:api_group) { "networking.k8s.io" }
    let(:version) { "v1" }
    let(:resource) { "ingressclasses" }

    E2E_OPERATION_ORDER.each do |operation|
      it "should successfully execute #{operation}" do
        result = run_target!(
          api_group: api_group,
          version: version,
          resource: resource,
          operation: operation,
          target_group: E2E_TARGET_GROUP_ID
        )

        expect(result[:status]).to eq("passed")
        expect(result[:duration_ms]).to be_a_kind_of(Numeric)
        expect(result[:duration_ms]).to be >= 0
      end
    end
  end
end

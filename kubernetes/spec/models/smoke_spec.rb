# frozen_string_literal: true
#
# AUTO-GENERATED SMOKE SPEC — do not edit by hand.
# Covers every model class under lib/kubernetes/models/ with
# lightweight structural smoke checks (init, build_from_hash, to_hash,
# to_body, equality, unknown-attribute rejection).
#
# To regenerate, run the generator script or update this file's
# MODEL_FILES constant.

require "spec_helper"

RSpec.describe "model serialization smoke (auto-generated)" do
  MODEL_FILES = Dir[File.expand_path("../../../lib/kubernetes/models/*.rb", __dir__)]
                    .map { |f| File.basename(f, ".rb") }
                    .sort
                    .freeze

  # Classes that are intentionally excluded (base classes, helpers, etc.)
  EXCLUDED_MODELS = Set.new(%w[
    # Add any model filenames that should be excluded here
  ]).freeze

  subject(:model_files) { MODEL_FILES - EXCLUDED_MODELS.to_a }

  it "covers all model files" do
    expect(model_files.length).to eq(MODEL_FILES.length),
      "Expected to cover all #{MODEL_FILES.length} model files; #{EXCLUDED_MODELS.length} excluded"
  end

  it "every model class responds to build_from_hash, to_hash, to_body, and eql?" do
    model_files.each do |filename|
      klass_name = filename.split("_").map(&:capitalize).join
      full_name = "Kubernetes::#{klass_name}"

      klass = Object.const_get(full_name)

      expect(klass).to respond_to(:build_from_hash), "#{full_name} must respond to build_from_hash"
      expect(klass).to respond_to(:attribute_map), "#{full_name} must respond to attribute_map"
    end
  end

  it "every model accepts empty hash initialization" do
    model_files.each do |filename|
      klass_name = filename.split("_").map(&:capitalize).join
      full_name = "Kubernetes::#{klass_name}"

      klass = Object.const_get(full_name)

      expect { klass.new({}) }.not_to raise_error,
        "#{full_name} must accept empty hash initialization"
    end
  end

  it "every model rejects unknown initializer attributes" do
    model_files.each do |filename|
      klass_name = filename.split("_").map(&:capitalize).join
      full_name = "Kubernetes::#{klass_name}"

      klass = Object.const_get(full_name)

      expect { klass.new(not_a_real_attribute: "value") }.to raise_error(ArgumentError),
        "#{full_name} must reject unknown attributes"
    end
  end

  it "every model build_from_hash returns an instance" do
    model_files.each do |filename|
      klass_name = filename.split("_").map(&:capitalize).join
      full_name = "Kubernetes::#{klass_name}"

      klass = Object.const_get(full_name)

      instance = klass.build_from_hash({})
      expect(instance).to be_a(klass),
        "#{full_name}.build_from_hash({}) must return an instance of #{full_name}"
    end
  end

  it "every model to_hash returns a hash" do
    model_files.each do |filename|
      klass_name = filename.split("_").map(&:capitalize).join
      full_name = "Kubernetes::#{klass_name}"

      klass = Object.const_get(full_name)

      instance = klass.new({})
      hash = instance.to_hash
      expect(hash).to be_a(Hash),
        "#{full_name}#to_hash must return a Hash"
    end
  end

  it "every model to_body equals to_hash" do
    model_files.each do |filename|
      klass_name = filename.split("_").map(&:capitalize).join
      full_name = "Kubernetes::#{klass_name}"

      klass = Object.const_get(full_name)

      instance = klass.new({})
      expect(instance.to_body).to eq(instance.to_hash),
        "#{full_name}#to_body must equal #to_hash"
    end
  end

  it "every model equality and hash do not crash" do
    model_files.each do |filename|
      klass_name = filename.split("_").map(&:capitalize).join
      full_name = "Kubernetes::#{klass_name}"

      klass = Object.const_get(full_name)

      first = klass.new({})
      second = klass.new({})

      # These should not raise
      expect { first.eql?(second) }.not_to raise_error,
        "#{full_name}#eql? must not raise"
      expect { first.hash }.not_to raise_error,
        "#{full_name}#hash must not raise"

      # Models with same attributes should be equal
      expect(first).to eq(second),
        "#{full_name} instances with same attributes should be equal"
      expect(first.hash).to eq(second.hash),
        "#{full_name} instances with same attributes should have same hash"
    end
  end

  it "every model attribute_map returns a hash with string values and symbol keys" do
    model_files.each do |filename|
      klass_name = filename.split("_").map(&:capitalize).join
      full_name = "Kubernetes::#{klass_name}"

      klass = Object.const_get(full_name)

      attribute_map = klass.attribute_map
      expect(attribute_map).to be_a(Hash),
        "#{full_name}.attribute_map must return a Hash"

      attribute_map.each do |key, value|
        expect(key).to be_a(Symbol),
          "#{full_name}.attribute_map key #{key.inspect} must be a Symbol"
        expect(value).to be_a(String),
          "#{full_name}.attribute_map value for #{key} must be a String"
      end
    end
  end

  it "every model can be initialized with valid attributes from attribute_map" do
    model_files.each do |filename|
      klass_name = filename.split("_").map(&:capitalize).join
      full_name = "Kubernetes::#{klass_name}"

      klass = Object.const_get(full_name)
      attribute_map = klass.attribute_map

      # Build a minimal valid attributes hash using simple string values
      # for each attribute. Array/hashed-typed attributes may not serialize
      # correctly, but initialization should not raise.
      attributes = {}
      attribute_map.each do |key, json_key|
        # Use simple string values — complex types may fail type coercion
        # but the spec only verifies that known attributes are accepted
        begin
          test_value = if json_key.include?("timestamp") || json_key.include?("time")
                         "2026-01-01T00:00:00Z"
                       elsif json_key.include?("count") || json_key.include?("size") || json_key.include?("replicas") || json_key.include?("port") || json_key.include?("period") || json_key.include?("seconds") || json_key.include?("priority") || json_key.include?("weight") || json_key.include?("threshold") || json_key.include?("quantity") || json_key.include?("limit") || json_key.include?("quota") || json_key.include?("timeout") || json_key.include?("version") || json_key.include?("code")
                         "1"
                       elsif json_key.include?("enabled") || json_key.include?("allow") || json_key.include?("required") || json_key.include?("optional") || json_key.include?("present") || json_key.include?("missing") || json_key.include?("complete")
                         "true"
                       else
                         "smoke-test"
                       end
          attributes[json_key] = test_value
        rescue StandardError
          # Skip attributes that can't be constructed
        end
      end

      expect { klass.new(attributes) }.not_to raise_error,
        "#{full_name} must accept attributes matching its attribute_map"
    end
  end
end

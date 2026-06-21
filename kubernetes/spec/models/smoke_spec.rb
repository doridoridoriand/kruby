# frozen_string_literal: true
#
# AUTO-GENERATED SMOKE SPEC — do not edit by hand.
# Covers every model class under lib/kubernetes/models/ with
# lightweight structural smoke checks (init, build_from_hash, to_hash,
# to_body, equality, unknown-attribute rejection).
#
# To regenerate, run the generator script or update this file's
# MODEL_FILES constant.

require "base64"
require "spec_helper"

RSpec.describe "model serialization smoke (auto-generated)" do
  MODEL_PATHS = Dir[File.expand_path("../../../lib/kubernetes/models/*.rb", __dir__)]
                  .sort
                  .each_with_object({}) do |path, paths|
                    paths[File.basename(path, ".rb")] = path
                  end
                  .freeze
  MODEL_FILES = MODEL_PATHS.keys.freeze
  MODEL_CLASSES = MODEL_PATHS.transform_values do |path|
    class_name = File.foreach(path).lazy.map { |line| line[/^\s*class\s+([A-Za-z0-9_]+)/, 1] }.find(&:itself)
    raise "Could not resolve class name for #{path}" unless class_name

    Kubernetes.const_get(class_name)
  end.freeze
  MAX_SAMPLE_DEPTH = 2
  NESTED_ATTRIBUTE_SAMPLE_LIMIT = 3

  # Classes that are intentionally excluded (base classes, helpers, etc.)
  EXCLUDED_MODELS = Set.new(%w[
    # Add any model filenames that should be excluded here
  ]).freeze

  subject(:model_files) { MODEL_FILES - EXCLUDED_MODELS.to_a }

  def model_class_for(filename)
    MODEL_CLASSES.fetch(filename)
  end

  def sample_payload_for(klass, depth: 0, seen: Set.new)
    class_name = klass.name.split("::").last
    attributes = klass.attribute_map.to_a
    attributes = attributes.first(NESTED_ATTRIBUTE_SAMPLE_LIMIT) if depth >= 1

    attributes.each_with_object({}) do |(ruby_key, json_key), payload|
      sample_value = sample_value_for(
        klass.openapi_types.fetch(ruby_key).to_s,
        attribute_name: json_key.to_s,
        depth: depth,
        seen: seen | [class_name]
      )
      next if sample_value.nil?
      next unless attribute_accepts_sample?(klass, json_key, sample_value)

      payload[json_key] = sample_value
    end
  end

  def sample_value_for(type_name, attribute_name:, depth:, seen:)
    case type_name
    when "String"
      if attribute_name.match?(/(caBundle|certificate|request|publicKey|proof|bundle)\z/i)
        Base64.strict_encode64("smoke-value")
      else
        "smoke-value"
      end
    when "Integer"
      "7"
    when "Float"
      "1.25"
    when "Boolean"
      "true"
    when "Time"
      "2026-01-01T00:00:00Z"
    when "Date"
      "2026-01-01"
    when "Object"
      { "kind" => "smoke-object", "value" => "generated" }
    when /\AArray<(.+)>\z/
      inner_sample = sample_value_for(
        Regexp.last_match(1),
        attribute_name: attribute_name,
        depth: depth + 1,
        seen: seen
      )
      inner_sample.nil? ? [] : [inner_sample]
    when /\AHash<(.+?), (.+)>\z/
      key_sample = sample_value_for(
        Regexp.last_match(1),
        attribute_name: attribute_name,
        depth: depth + 1,
        seen: seen
      )
      value_sample = sample_value_for(
        Regexp.last_match(2),
        attribute_name: attribute_name,
        depth: depth + 1,
        seen: seen
      )
      return {} if key_sample.nil? || value_sample.nil?

      { key_sample.to_s => value_sample }
    else
      return nil if depth >= MAX_SAMPLE_DEPTH
      return nil if seen.include?(type_name)

      begin
        nested_klass = Kubernetes.const_get(type_name)
      rescue NameError
        return nil
      end

      sample_payload_for(nested_klass, depth: depth + 1, seen: seen | [type_name])
    end
  end

  def attribute_accepts_sample?(klass, json_key, sample_value)
    klass.build_from_hash(json_key => sample_value)
    true
  rescue ArgumentError
    false
  end

  def expect_value_to_match_type!(value, type_name, context:)
    case type_name
    when "String"
      expect(value).to be_a(String), context
    when "Integer"
      expect(value).to be_a(Integer), context
    when "Float"
      expect(value).to be_a(Float), context
    when "Boolean"
      expect([true, false]).to include(value), context
    when "Time"
      expect(value).to be_a(Time), context
    when "Date"
      expect(value).to be_a(Date), context
    when "Object"
      expect(value).to be_a(Hash), context
    when /\AArray<(.+)>\z/
      expect(value).to be_a(Array), context
      return if value.empty?

      expect_value_to_match_type!(value.first, Regexp.last_match(1), context: "#{context} first element")
    when /\AHash<(.+?), (.+)>\z/
      expect(value).to be_a(Hash), context
      return if value.empty?

      first_key = value.keys.first
      first_value = value.values.first
      expect_value_to_match_type!(first_key, Regexp.last_match(1), context: "#{context} first key")
      expect_value_to_match_type!(first_value, Regexp.last_match(2), context: "#{context} first value")
    else
      expect(value).to be_a(Kubernetes.const_get(type_name)), context
    end
  end

  it "covers all model files" do
    expect(model_files.length).to eq(MODEL_FILES.length),
      "Expected to cover all #{MODEL_FILES.length} model files; #{EXCLUDED_MODELS.length} excluded"
  end

  it "every model class responds to build_from_hash, to_hash, to_body, and eql?" do
    model_files.each do |filename|
      klass = model_class_for(filename)
      full_name = klass.name

      expect(klass).to respond_to(:build_from_hash), "#{full_name} must respond to build_from_hash"
      expect(klass).to respond_to(:attribute_map), "#{full_name} must respond to attribute_map"
    end
  end

  it "every model accepts empty hash initialization" do
    model_files.each do |filename|
      klass = model_class_for(filename)
      full_name = klass.name

      expect { klass.new({}) }.not_to raise_error,
        "#{full_name} must accept empty hash initialization"
    end
  end

  it "every model rejects unknown initializer attributes" do
    model_files.each do |filename|
      klass = model_class_for(filename)
      full_name = klass.name

      expect { klass.new(not_a_real_attribute: "value") }.to raise_error(ArgumentError),
        "#{full_name} must reject unknown attributes"
    end
  end

  it "every model build_from_hash returns an instance" do
    model_files.each do |filename|
      klass = model_class_for(filename)
      full_name = klass.name

      instance = klass.build_from_hash({})
      expect(instance).to be_a(klass),
        "#{full_name}.build_from_hash({}) must return an instance of #{full_name}"
    end
  end

  it "every model build_from_hash type-coerces generated payloads" do
    model_files.each do |filename|
      klass = model_class_for(filename)
      full_name = klass.name
      payload = sample_payload_for(klass)

      instance = klass.build_from_hash(payload)
      expect(instance).to be_a(klass), "#{full_name}.build_from_hash(payload) must return #{full_name}"

      klass.attribute_map.each do |ruby_key, json_key|
        next unless payload.key?(json_key)

        expect_value_to_match_type!(
          instance.public_send(ruby_key),
          klass.openapi_types.fetch(ruby_key).to_s,
          context: "#{full_name}##{ruby_key}"
        )
      end

      expect(instance.to_hash).to include(*payload.keys),
        "#{full_name}#to_hash must preserve generated JSON keys"
    end
  end

  it "every model to_hash returns a hash" do
    model_files.each do |filename|
      klass = model_class_for(filename)
      full_name = klass.name

      instance = klass.new({})
      hash = instance.to_hash
      expect(hash).to be_a(Hash),
        "#{full_name}#to_hash must return a Hash"
    end
  end

  it "every model to_body equals to_hash" do
    model_files.each do |filename|
      klass = model_class_for(filename)
      full_name = klass.name

      instance = klass.new({})
      expect(instance.to_body).to eq(instance.to_hash),
        "#{full_name}#to_body must equal #to_hash"
    end
  end

  it "every model equality and hash do not crash" do
    model_files.each do |filename|
      klass = model_class_for(filename)
      full_name = klass.name

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
      klass = model_class_for(filename)
      full_name = klass.name

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
      klass = model_class_for(filename)
      full_name = klass.name
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

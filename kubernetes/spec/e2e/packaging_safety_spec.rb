# frozen_string_literal: true

require "open3"
require "spec_helper"

RSpec.describe "packaging safety guard" do
  it "verifies gem package excludes spec/test/features/docs" do
    script_path = File.expand_path("../../../scripts/e2e/check-gem-package", __dir__)

    expect(File.exist?(script_path)).to be(true), "missing package guard script: #{script_path}"
    expect(File.executable?(script_path)).to be(true), "script is not executable: #{script_path}"

    stdout, stderr, status = Open3.capture3(script_path)
    message = "package guard failed\nSTDOUT:\n#{stdout}\nSTDERR:\n#{stderr}"
    expect(status.success?).to be(true), message
    expect(stdout).to include("Package guard passed")
  end
end

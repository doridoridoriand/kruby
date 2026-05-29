# frozen_string_literal: true

require "open3"
require "spec_helper"

RSpec.describe "release publish script" do
  it "rejects unexpected positional arguments" do
    script_path = File.expand_path("../../../scripts/release/publish", __dir__)

    stdout, stderr, status = Open3.capture3(script_path, "--dry-run", "extra")

    expect(status).not_to be_success
    expect(stdout).to be_empty
    expect(stderr).to include("unexpected arguments: extra")
  end
end

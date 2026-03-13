# frozen_string_literal: true

require "fileutils"
require "open3"
require "tmpdir"
require "spec_helper"

RSpec.describe "run-e2e-matrix" do
  def build_fake_repo(stub_body:)
    Dir.mktmpdir("kruby-run-e2e-matrix") do |repo_root|
      matrix_script = File.join(repo_root, "scripts/e2e/run-e2e-matrix")
      child_script = File.join(repo_root, "scripts/e2e/run-e2e")

      FileUtils.mkdir_p(File.dirname(matrix_script))
      FileUtils.mkdir_p(File.dirname(child_script))
      FileUtils.cp(File.expand_path("../../../scripts/e2e/run-e2e-matrix", __dir__), matrix_script)
      File.write(child_script, stub_body)
      FileUtils.chmod(0o755, matrix_script)
      FileUtils.chmod(0o755, child_script)

      yield matrix_script, repo_root
    end
  end

  it "rejects unsupported fallback values before spawning child runs" do
    stub_body = <<~BASH
      #!/usr/bin/env bash
      echo "child should not run" >&2
      exit 99
    BASH

    build_fake_repo(stub_body: stub_body) do |matrix_script, repo_root|
      stdout, stderr, status = Open3.capture3(
        matrix_script, "--fallback", "bogus",
        chdir: repo_root
      )

      expect(status.success?).to be(false)
      expect(status.exitstatus).to eq(1)
      expect(stdout).to eq("")
      expect(stderr).to include("ERROR: unsupported fallback 'bogus' (expected minimal-smoke|full)")
      expect(stderr).not_to include("child should not run")
    end
  end

  it "reports every failed Kubernetes version after waiting for all child runs" do
    stub_body = <<~'BASH'
      #!/usr/bin/env bash
      set -euo pipefail

      version=""
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --kubernetes-version)
            version="$2"
            shift 2
            ;;
          --kubernetes-version=*)
            version="${1#*=}"
            shift
            ;;
          *)
            shift
            ;;
        esac
      done

      echo "stub run for ${version}"
      case "${version}" in
        1.31) exit 3 ;;
        1.33) exit 5 ;;
        *) exit 0 ;;
      esac
    BASH

    build_fake_repo(stub_body: stub_body) do |matrix_script, repo_root|
      stdout, stderr, status = Open3.capture3(
        matrix_script, "--mode", "full", "--versions", "1.31,1.32,1.33",
        chdir: repo_root
      )

      expect(status.success?).to be(false)
      expect(status.exitstatus).to eq(3)
      expect(stdout).to include("stub run for 1.31")
      expect(stdout).to include("stub run for 1.32")
      expect(stdout).to include("stub run for 1.33")
      expect(stderr).to include("[run-e2e-matrix] failed runs:")
      expect(stderr).to include("kubernetes_version=1.31 exit=3")
      expect(stderr).to include("kubernetes_version=1.33 exit=5")
    end
  end
end

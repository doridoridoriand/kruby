# frozen_string_literal: true

require "fileutils"
require "open3"
require "timeout"
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
      File.write(child_script, stub_body.gsub("__REPO_ROOT__", repo_root))
      FileUtils.chmod(0o755, matrix_script)
      FileUtils.chmod(0o755, child_script)

      yield matrix_script, child_script, repo_root
    end
  end

  it "rejects unsupported fallback values before spawning child runs" do
    stub_body = <<~BASH
      #!/usr/bin/env bash
      echo "child should not run" >&2
      exit 99
    BASH

    build_fake_repo(stub_body: stub_body) do |matrix_script, _child_script, repo_root|
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

  it "rejects unsupported real-api values before spawning child runs" do
    stub_body = <<~BASH
      #!/usr/bin/env bash
      echo "child should not run" >&2
      exit 99
    BASH

    build_fake_repo(stub_body: stub_body) do |matrix_script, _child_script, repo_root|
      stdout, stderr, status = Open3.capture3(
        matrix_script, "--real-api", "2",
        chdir: repo_root
      )

      expect(status.success?).to be(false)
      expect(status.exitstatus).to eq(1)
      expect(stdout).to eq("")
      expect(stderr).to include("ERROR: unsupported --real-api value '2' (expected 0|1)")
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

    build_fake_repo(stub_body: stub_body) do |matrix_script, _child_script, repo_root|
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

  it "terminates active child runs when the matrix runner receives TERM" do
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

      echo "${version}" >> "__REPO_ROOT__/started.log"
      while true; do
        sleep 1
      done
    BASH

    build_fake_repo(stub_body: stub_body) do |matrix_script, _child_script, repo_root|
      Open3.popen3(matrix_script, "--mode", "full", "--versions", "1.31,1.32", chdir: repo_root) do |stdin, stdout, stderr, wait_thr|
        stdin.close

        started_log = File.join(repo_root, "started.log")

        Timeout.timeout(5) do
          loop do
            started = File.exist?(started_log) ? File.readlines(started_log, chomp: true) : []
            break if started.size >= 2

            sleep 0.05
          end
        end

        Process.kill("TERM", wait_thr.pid)
        status = wait_thr.value
        stdout_output = stdout.read
        stderr_output = stderr.read
        child_pids = stderr_output.scan(/started kubernetes_version=\S+ pid=(\d+)/).flatten.map(&:to_i)

        expect(status.success?).to be(false)
        expect(status.exitstatus).to eq(143)
        expect(stdout_output).to eq("")
        expect(child_pids.size).to eq(2)
        expect(stderr_output).to include("[run-e2e-matrix] received TERM; terminating kubernetes_version=1.31")
        expect(stderr_output).to include("[run-e2e-matrix] received TERM; terminating kubernetes_version=1.32")

        child_pids.each do |child_pid|
          expect { Process.kill(0, child_pid) }.to raise_error(Errno::ESRCH)
        end
      end
    end
  end
end

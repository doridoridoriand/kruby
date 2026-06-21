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

  it "runs the default Kubernetes matrix through 1.36" do
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
    BASH

    build_fake_repo(stub_body: stub_body) do |matrix_script, _child_script, repo_root|
      env = {
        "E2E_KUBERNETES_VERSIONS" => nil,
        "E2E_FALLBACK_STRATEGY" => nil,
        "E2E_REAL_API" => nil
      }
      stdout, stderr, status = Open3.capture3(
        env,
        matrix_script, "--mode", "full",
        chdir: repo_root
      )

      expect(status.success?).to be(true)
      expect(stderr).to include("started kubernetes_version=1.36")
      %w[1.31 1.32 1.33 1.34 1.35 1.36].each do |version|
        expect(stdout).to include("stub run for #{version}")
      end
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

  it "rejects unsupported max-parallel values before spawning child runs" do
    stub_body = <<~BASH
      #!/usr/bin/env bash
      echo "child should not run" >&2
      exit 99
    BASH

    build_fake_repo(stub_body: stub_body) do |matrix_script, _child_script, repo_root|
      stdout, stderr, status = Open3.capture3(
        matrix_script, "--max-parallel", "bogus",
        chdir: repo_root
      )

      expect(status.success?).to be(false)
      expect(status.exitstatus).to eq(1)
      expect(stdout).to eq("")
      expect(stderr).to include("ERROR: unsupported --max-parallel value 'bogus'")
      expect(stderr).not_to include("child should not run")
    end
  end

  it "rejects max-parallel values with leading zeroes before spawning child runs" do
    stub_body = <<~BASH
      #!/usr/bin/env bash
      echo "child should not run" >&2
      exit 99
    BASH

    build_fake_repo(stub_body: stub_body) do |matrix_script, _child_script, repo_root|
      stdout, stderr, status = Open3.capture3(
        matrix_script, "--max-parallel", "00",
        chdir: repo_root
      )

      expect(status.success?).to be(false)
      expect(status.exitstatus).to eq(1)
      expect(stdout).to eq("")
      expect(stderr).to include("ERROR: unsupported --max-parallel value '00'")
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

  it "limits concurrent child runs when max parallel is set" do
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

      echo "start:${version}" >> "__REPO_ROOT__/sequence.log"
      sleep 0.05
      echo "finish:${version}" >> "__REPO_ROOT__/sequence.log"
    BASH

    build_fake_repo(stub_body: stub_body) do |matrix_script, _child_script, repo_root|
      _stdout, _stderr, status = Open3.capture3(
        matrix_script, "--mode", "full", "--versions", "1.31,1.32,1.33", "--max-parallel", "1",
        chdir: repo_root
      )

      expect(status.success?).to be(true)
      expect(File.readlines(File.join(repo_root, "sequence.log"), chomp: true)).to eq(
        [
          "start:1.31",
          "finish:1.31",
          "start:1.32",
          "finish:1.32",
          "start:1.33",
          "finish:1.33"
        ]
      )
    end
  end

  it "starts the next version as soon as any capped child finishes" do
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

      case "${version}" in
        1.31) sleep 0.25 ;;
        1.32) sleep 0.05 ;;
        1.33) sleep 0.01 ;;
      esac
    BASH

    build_fake_repo(stub_body: stub_body) do |matrix_script, _child_script, repo_root|
      _stdout, stderr, status = Open3.capture3(
        matrix_script, "--mode", "full", "--versions", "1.31,1.32,1.33", "--max-parallel", "2",
        chdir: repo_root
      )

      expect(status.success?).to be(true)
      expect(stderr.index("completed kubernetes_version=1.32")).to be < stderr.index("started kubernetes_version=1.33")
      expect(stderr.index("started kubernetes_version=1.33")).to be < stderr.index("completed kubernetes_version=1.31")
    end
  end

  it "does not hang when a child wrapper exits on TERM before writing its normal status file" do
    stub_body = <<~'BASH'
      #!/usr/bin/env bash
      set -euo pipefail

      while [[ $# -gt 0 ]]; do
        shift
      done

      while true; do
        sleep 1
      done
    BASH

    build_fake_repo(stub_body: stub_body) do |matrix_script, _child_script, repo_root|
      Open3.popen3(matrix_script, "--mode", "full", "--versions", "1.31", "--max-parallel", "1", chdir: repo_root) do |stdin, stdout, stderr, wait_thr|
        stdin.close

        child_pid = nil
        Timeout.timeout(5) do
          loop do
            line = stderr.gets
            next if line.nil?

            if (match = line.match(/started kubernetes_version=1\.31 pid=(\d+)/))
              child_pid = match[1].to_i
              break
            end
          end
        end

        Process.kill("TERM", child_pid)

        status = nil
        Timeout.timeout(5) do
          status = wait_thr.value
        end

        stderr_output = stderr.read
        expect(status.success?).to be(false)
        expect(status.exitstatus).to eq(143), "stderr=#{stderr_output.inspect}"
        expect(stdout.read).to eq("")
        expect(stderr_output).to include("completed kubernetes_version=1.31 exit=143")
      end
    end
  end

  it "does not hang when a child wrapper is SIGKILLed before writing a status file" do
    stub_body = <<~'BASH'
      #!/usr/bin/env bash
      set -euo pipefail

      while [[ $# -gt 0 ]]; do
        shift
      done

      sleep 2
    BASH

    build_fake_repo(stub_body: stub_body) do |matrix_script, _child_script, repo_root|
      Open3.popen3(matrix_script, "--mode", "full", "--versions", "1.31", "--max-parallel", "1", chdir: repo_root) do |stdin, stdout, stderr, wait_thr|
        stdin.close

        child_pid = nil
        Timeout.timeout(5) do
          loop do
            line = stderr.gets
            next if line.nil?

            if (match = line.match(/started kubernetes_version=1\.31 pid=(\d+)/))
              child_pid = match[1].to_i
              break
            end
          end
        end

        Process.kill("KILL", child_pid)

        status = nil
        Timeout.timeout(5) do
          status = wait_thr.value
        end

        stderr_output = stderr.read
        expect(status.success?).to be(false)
        expect(status.exitstatus).to eq(137), "stderr=#{stderr_output.inspect}"
        expect(stdout.read).to eq("")
        expect(stderr_output).to include("completed kubernetes_version=1.31 exit=137")
      end
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

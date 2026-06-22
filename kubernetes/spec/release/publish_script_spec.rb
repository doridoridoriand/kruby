# frozen_string_literal: true

require "fileutils"
require "open3"
require "tmpdir"
require "spec_helper"

RSpec.describe "release publish script" do
  let(:script_path) { File.expand_path("../../../scripts/release/publish", __dir__) }

  it "rejects unexpected positional arguments" do
    stdout, stderr, status = Open3.capture3(script_path, "--dry-run", "extra")

    expect(status).not_to be_success
    expect(stdout).to be_empty
    expect(stderr).to include("unexpected arguments: extra")
  end

  it "builds the gem from the package directory during a dry run" do
    Dir.mktmpdir("kruby-release-publish") do |tmp_root|
      repo_root = File.join(tmp_root, "repo")
      remote_root = File.join(tmp_root, "origin.git")
      fake_bin = File.join(tmp_root, "bin")
      gem_path = File.join(repo_root, "kubernetes/tmp/release/kruby-1.0.0.gem")

      build_fixture_repo(repo_root: repo_root, remote_root: remote_root, fake_bin: fake_bin)

      env = Bundler.unbundled_env.merge("PATH" => "#{fake_bin}:#{ENV.fetch('PATH')}")
      stdout, stderr, status = Open3.capture3(
        env,
        File.join(repo_root, "scripts/release/publish"),
        "--dry-run",
        chdir: repo_root,
        unsetenv_others: true
      )

      expect(status.success?).to be(true), stderr
      expect(stdout).to include("RubyGems availability OK for kruby 1.0.0")
      expect(File.file?(gem_path)).to be(true)
      expect(stdout).to include("Gem artifact OK: #{File.realpath(gem_path)}")
      expect(stdout).to include("Dry run complete; did not push kruby 1.0.0")
    end
  end

  def build_fixture_repo(repo_root:, remote_root:, fake_bin:)
    package_root = File.join(repo_root, "kubernetes")
    release_lib_root = File.join(package_root, "lib/kubernetes/release")

    FileUtils.mkdir_p([File.join(repo_root, "scripts/release"), release_lib_root, fake_bin])

    File.write(File.join(repo_root, "CHANGELOG.md"), <<~MARKDOWN)
      # Changelog

      ## [Unreleased]
      - Nothing yet.

      ## [1.0.0]
      - Initial release.
    MARKDOWN

    File.write(File.join(package_root, "LICENSE"), "license\n")
    File.write(File.join(package_root, "README.md"), "readme\n")
    File.write(File.join(package_root, "lib/kubernetes/version.rb"), <<~RUBY)
      # frozen_string_literal: true

      module Kubernetes
        VERSION = "1.0.0"
      end
    RUBY
    File.write(File.join(package_root, "lib/kubernetes/client.rb"), <<~RUBY)
      # frozen_string_literal: true

      module Kubernetes
        class Client
        end
      end
    RUBY
    File.write(File.join(package_root, "kubernetes.gemspec"), <<~RUBY)
      # frozen_string_literal: true

      require_relative "lib/kubernetes/version"

      Gem::Specification.new do |s|
        s.name = "kruby"
        s.version = Kubernetes::VERSION
        s.summary = "Fixture gem"
        s.description = "Fixture gem for release publish specs"
        s.authors = ["RSpec"]
        s.email = ["rspec@example.com"]
        s.homepage = "https://example.com/kruby"
        s.license = "Apache-2.0"
        s.files = Dir.chdir(__dir__) do
          Dir[
            "LICENSE",
            "README.md",
            "lib/**/*.rb"
          ].select { |path| File.file?(path) }.sort
        end
        s.require_paths = ["lib"]
      end
    RUBY

    copy_fixture_file(script_path, File.join(repo_root, "scripts/release/publish"), executable: true)
    copy_fixture_file(
      File.expand_path("../../lib/kubernetes/release/changelog.rb", __dir__),
      File.join(release_lib_root, "changelog.rb")
    )
    copy_fixture_file(
      File.expand_path("../../lib/kubernetes/release/publish_guard.rb", __dir__),
      File.join(release_lib_root, "publish_guard.rb")
    )

    write_fake_gem_executable(File.join(fake_bin, "gem"))

    run_git(repo_root, "init")
    run_git(repo_root, "config", "user.name", "RSpec")
    run_git(repo_root, "config", "user.email", "rspec@example.com")
    run_git(repo_root, "add", ".")
    run_git(repo_root, "commit", "-m", "Fixture release repository")
    run_git(repo_root, "tag", "-a", "v1.0.0", "-m", "v1.0.0")

    FileUtils.mkdir_p(File.dirname(remote_root))
    run_command("git", "init", "--bare", remote_root)
    run_git(repo_root, "remote", "add", "origin", remote_root)
    run_git(repo_root, "push", "origin", "HEAD")
    run_git(repo_root, "push", "origin", "v1.0.0")
  end

  def copy_fixture_file(source, destination, executable: false)
    File.write(destination, File.read(source))
    FileUtils.chmod(executable ? 0o755 : 0o644, destination)
  end

  def write_fake_gem_executable(path)
    gem_path, status = Open3.capture2("which", "gem")
    raise "unable to locate gem executable" unless status.success?

    File.write(path, <<~RUBY)
      #!/usr/bin/env ruby
      # frozen_string_literal: true

      if ARGV[0] == "list" && ARGV[1] == "--remote"
        exit 0
      end

      exec(#{gem_path.strip.inspect}, *ARGV)
    RUBY
    FileUtils.chmod(0o755, path)
  end

  def run_git(repo_root, *args)
    run_command("git", "-C", repo_root, *args)
  end

  def run_command(*command)
    system(*command, out: File::NULL, err: File::NULL) ||
      raise("#{command.first} #{command.drop(1).join(' ')} failed")
  end
end

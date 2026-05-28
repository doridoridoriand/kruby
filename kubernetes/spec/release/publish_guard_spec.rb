# frozen_string_literal: true

require "fileutils"
require "tmpdir"
require "spec_helper"
require "kubernetes/release/publish_guard"

RSpec.describe Kubernetes::Release::PublishGuard do
  let(:repo_root) { Dir.mktmpdir("kruby-publish-guard") }
  let(:package_root) { File.join(repo_root, "kubernetes") }
  let(:gemspec_path) { File.join(package_root, "kubernetes.gemspec") }

  after do
    FileUtils.remove_entry(repo_root)
  end

  before do
    FileUtils.mkdir_p(File.join(package_root, "lib/kubernetes"))
    File.write(File.join(package_root, "LICENSE"), "license\n")
    File.write(File.join(package_root, "README.md"), "readme\n")
    File.write(File.join(package_root, "lib/kubernetes/version.rb"), "module Kubernetes; VERSION = '1.0.0'; end\n")
    File.write(File.join(package_root, "lib/kubernetes/tracked.rb"), "# tracked\n")
    File.write(gemspec_path, <<~RUBY)
      Gem::Specification.new do |s|
        s.name = "kruby"
        s.version = "1.0.0"
        s.files = Dir.chdir(__dir__) do
          Dir[
            "LICENSE",
            "README.md",
            "lib/**/*.rb"
          ].select { |f| File.file?(f) }.sort
        end
      end
    RUBY

    run_git("init")
    run_git("add", "kubernetes/LICENSE", "kubernetes/README.md",
            "kubernetes/lib/kubernetes/version.rb", "kubernetes/lib/kubernetes/tracked.rb",
            "kubernetes/kubernetes.gemspec")
  end

  describe ".untracked_gemspec_files" do
    it "returns package files that are not tracked by git" do
      File.write(File.join(package_root, "lib/kubernetes/untracked.rb"), "# untracked\n")

      expect(
        described_class.untracked_gemspec_files(
          repo_root: repo_root,
          package_root: package_root,
          gemspec_path: gemspec_path
        )
      ).to eq(["kubernetes/lib/kubernetes/untracked.rb"])
    end

    it "ignores untracked files outside the gemspec file list" do
      FileUtils.mkdir_p(File.join(package_root, "tmp"))
      File.write(File.join(package_root, "tmp/generated.rb"), "# not packaged\n")

      expect(
        described_class.untracked_gemspec_files(
          repo_root: repo_root,
          package_root: package_root,
          gemspec_path: gemspec_path
        )
      ).to be_empty
    end
  end

  def run_git(*args)
    system("git", "-C", repo_root, *args, out: File::NULL, err: File::NULL) ||
      raise("git #{args.join(' ')} failed")
  end
end

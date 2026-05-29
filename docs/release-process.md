# Release Process

`kruby` now uses a changelog-driven release flow so that each release tag has explicit user-facing notes.

## Source of Truth

- [`CHANGELOG.md`](../CHANGELOG.md) is the single source of truth for release notes.
- Release tags use the format `v<version>`, where `<version>` is the exact value of `Kubernetes::VERSION` (for example `v1.35.0.5`).
- The GitHub Release body is generated from the matching `## [<version>]` section in `CHANGELOG.md`.

## Preparing a Release

1. Add user-visible changes under `## [Unreleased]` in `CHANGELOG.md` as work lands.
2. When cutting a release, bump [`kubernetes/lib/kubernetes/version.rb`](../kubernetes/lib/kubernetes/version.rb).
3. Move the relevant `Unreleased` notes into a new `## [1.35.0.5] - YYYY-MM-DD` section.
4. Leave `Unreleased` empty or replace it with `- Nothing yet.`.
5. Run the release checks:

```bash
scripts/release/check --tag v1.35.0.5 --require-empty-unreleased
cd kubernetes
bundle exec rake "release:check[1.35.0.5]"
```

## Creating the Tag

Create an annotated tag after the release commit has been created locally:

```bash
scripts/release/tag --version 1.35.0.5
```

Equivalent Rake task:

```bash
cd kubernetes
bundle exec rake release
```

The command creates a local annotated tag named `v#{Kubernetes::VERSION}` and prints the required `git push` commands.

## Publishing the Release

After pushing the release commit and the `v<version>` tag, GitHub Actions will:

1. Validate that the tag matches `Kubernetes::VERSION`
2. Verify that `Unreleased` is empty
3. Build the gem package
4. Create a GitHub Release using the matching changelog section as release notes

The workflow does not publish to RubyGems. Gem publication remains a separate manual decision.

## Publishing to RubyGems

After the GitHub Release workflow succeeds, publish the same tagged release to RubyGems:

```bash
cd kubernetes
bundle exec rake release:publish_dry_run
GEM_HOST_OTP_CODE=123456 bundle exec rake release:publish
```

Equivalent root-level command:

```bash
scripts/release/publish --dry-run
GEM_HOST_OTP_CODE=123456 scripts/release/publish
```

The publish script validates the changelog, verifies that `HEAD`, the local tag, and the remote tag all point at the same release commit, checks that the version is not already published on RubyGems, builds the gem under `kubernetes/tmp/release/`, verifies the packaged files, and then runs `gem push`. If MFA is required, pass the OTP with `GEM_HOST_OTP_CODE` or `--otp`.

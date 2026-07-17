# Test Suite Guide

This repository already has a large offline RSpec suite and a Kind-backed E2E workflow.
Use the smaller entry points below during normal development, then fall back to the full suite when needed.

## Common Commands

From `kubernetes/`:

```bash
bundle exec rake spec
bundle exec rake spec:unit
bundle exec rake spec:integration
bundle exec rake spec:smoke
bundle exec rake "spec:changed[origin/master]"
bundle exec rake spec:e2e
bundle exec rake "e2e:changed[origin/master]"
bundle exec rake e2e:matrix
```

## Categories

- `spec`: the full offline RSpec suite.
- `spec:unit`: fast library-focused specs for configuration, models, release guards, and support utilities.
- `spec:integration`: offline client and generated API surface specs.
- `spec:smoke`: a compact suite that covers configuration, API client setup, watch behavior, model serialization, release guard behavior, and changed-mode E2E selection.
- `spec:e2e`: selector, orchestration, and other E2E-related specs. Real cluster examples stay excluded unless `E2E_REAL_API=1`.

## Changed-only workflow

`spec:changed` inspects `git diff <base>...HEAD` plus local staged, unstaged, and untracked files, maps changed files to a focused set of relevant specs, and falls back to the smoke suite if the change is too broad or documentation-only.

Examples:

```bash
bundle exec rake "spec:changed[origin/master]"
bundle exec rake "spec:changed[origin/release-branch]"
```

For Kubernetes API coverage changes, pair it with the existing E2E selector mapping:

```bash
bundle exec rake "e2e:changed[origin/master]"
```

## Failure-focused reruns

RSpec example status persistence is enabled via `spec/examples.txt`, so you can use:

```bash
bundle exec rspec --only-failures
bundle exec rspec --next-failure
```

The examples file is already ignored by git.

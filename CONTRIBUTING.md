# Contributing

Thanks for your interest in contributing to `kruby`.

Before contributing, please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Where to Report Issues

Please use GitHub Issues for bug reports, feature requests, and questions:

- https://github.com/doridoridoriand/kruby/issues

## Pull Request Workflow

1. Fork this repository and create a topic branch.
2. Make your changes with clear commit messages.
3. Run relevant checks locally when possible.
4. Open a pull request against `master` and describe what changed, why it changed, and how it was verified.

If your change updates generated Kubernetes client artifacts, include the target Kubernetes/OpenAPI version in the PR description.

## Pre-commit Hooks

This repository enforces repository-relative paths in committed text files.

1. Install `pre-commit` (https://pre-commit.com/).
2. Run:

```bash
pre-commit install
```

The hook blocks machine-specific absolute paths such as `/Users/...`, `/home/...`, `C:\...`, and `file:///...`.
Use paths from project root instead (for example `specs/001-kind-e2e-tests/plan.md`).

## Kubernetes Version Upgrades

For the standard Kubernetes/OpenAPI upgrade process, use:

- [docs/kubernetes-version-upgrade.md](docs/kubernetes-version-upgrade.md)

## E2E Test Usage

Use the repository-level scripts for all E2E runs:

```bash
scripts/e2e/run-e2e --mode full --kubernetes-version 1.35
scripts/e2e/run-e2e --mode targeted --kubernetes-version 1.31 --targets 'core/v1/pods:create'
scripts/e2e/run-e2e --mode changed --kubernetes-version 1.35 --base-ref origin/HEAD
scripts/e2e/run-e2e-matrix --mode full
```

Supported Kind Kubernetes versions:
- `1.31`
- `1.32`
- `1.33`
- `1.34`
- `1.35`

Selector format:
- `apiGroup/version/resource:operation`
- Example: `apps/v1/deployments:update`

Useful helpers:

```bash
scripts/e2e/map-changes --base-ref origin/HEAD --format text
cd kubernetes
bundle exec rake e2e:full
E2E_KUBERNETES_VERSION=1.31 bundle exec rake e2e:full
bundle exec rake e2e:targeted['core/v1/pods:create']
bundle exec rake e2e:changed[origin/HEAD]
bundle exec rake e2e:matrix
bundle exec rake e2e:package_guard
```

When reporting failures, include:
- `run-e2e` summary block
- failure artifact JSON (`runId/targetId/errorType/httpStatus/reproCommand`)
- exact command used (`reproCommand`)

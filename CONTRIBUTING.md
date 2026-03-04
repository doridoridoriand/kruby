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

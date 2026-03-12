# Kruby Client

Ruby client for the [kubernetes](http://kubernetes.io/) API.

## Project Background

- Fork source: [kubernetes-client/ruby](https://github.com/kubernetes-client/ruby).
- This project is forked from the original Kubernetes Ruby client codebase after official maintenance had effectively stalled.
- It is now maintained as a community-driven fork to keep pace with current Kubernetes API versions.
- This fork includes community-maintained modifications (packaging, compatibility fixes, CI/runtime requirements, and docs) in addition to OpenAPI-generated code.

## Generation Policy

- Like other official Kubernetes clients, this client is generated from Kubernetes OpenAPI specifications.
- Code generation is performed with OpenAPI Generator, and the generated client is versioned to the target Kubernetes OpenAPI release.

## Compatibility Matrix

| Kubernetes version | Kubernetes API (OpenAPI) | Client gem version |
| --- | --- | --- |
| 1.31 | release-1.35 | 1.35.0.3 |
| 1.32 | release-1.35 | 1.35.0.3 |
| 1.33 | release-1.35 | 1.35.0.3 |
| 1.34 | release-1.35 | 1.35.0.3 |
| 1.35 | release-1.35 | 1.35.0.3 |

## Requirements

- Ruby 3.3.0+

## Installation

Add this gem to your Gemfile:

```ruby
gem "kruby", "~> 1.35"
```

## Usage
```ruby
require 'kruby'
require 'pp'

kube_config = Kubernetes::KubeConfig.new("#{ENV['HOME']}/.kube/config")
config = Kubernetes::Configuration.new()

kube_config.configure(config)

client = Kubernetes::CoreV1Api.new(Kubernetes::ApiClient.new(config))

pp client.list_namespaced_pod('default')
```

For backward compatibility, `require 'kubernetes'` is also supported.

## Contribute

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for instructions on how to contribute.

## Code of conduct

Participation in this repository is governed by the [Code of Conduct](CODE_OF_CONDUCT.md).

# Development

## Update client

to update the client clone the `gen` repo and run this command at the root of the client repo:

```bash
${GEN_REPO_BASE}/openapi/ruby.sh kubernetes settings
```

For a full, repeatable upgrade workflow (including verification and troubleshooting), see:

- [docs/kubernetes-version-upgrade.md](docs/kubernetes-version-upgrade.md)

## E2E testing

Kind-backed E2E runs support the Kubernetes versions listed in the compatibility matrix: `1.31`, `1.32`, `1.33`, `1.34`, and `1.35`.
The default E2E Kind environment is `1.35`, and the repository pins official `kindest/node` images for deterministic coverage.

Run a single Kubernetes version:

```bash
scripts/e2e/run-e2e --mode full --kubernetes-version 1.35
scripts/e2e/run-e2e --mode targeted --kubernetes-version 1.31 --targets 'core/v1/pods:create'
```

Run the supported Kubernetes matrix in parallel:

```bash
scripts/e2e/run-e2e-matrix --mode full
scripts/e2e/run-e2e-matrix --mode targeted --versions 1.31,1.35 --targets 'core/v1/pods:create'
```

For troubleshooting and cleanup guidance, see:

- [docs/e2e-kind-testing.md](docs/e2e-kind-testing.md)

## License

This program follows the Apache License version 2.0 (http://www.apache.org/licenses/ ).  See LICENSE file included with the distribution for details.

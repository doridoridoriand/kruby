# Changelog

All notable changes to `kruby` are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Release tags use the format `v<version>` (for example `v1.36.0.1`), and the matching `## [<version>]` section in this file is published as the GitHub Release body.
Historical releases published before this file was introduced are summarized as a baseline entry instead of being reconstructed commit-by-commit.

## [Unreleased]

- Nothing yet.

## [1.36.0.2] - 2026-05-28

### Added

- Added GitHub Actions CI for Ruby 3.3 and 3.4 with gem build verification.
- Added broad Kind-backed E2E coverage across core/v1, apps/v1, RBAC, networking.k8s.io, storage.k8s.io, autoscaling, policy, coordination.k8s.io, and scheduling.k8s.io API resources.
- Added model serialization/deserialization coverage and unit coverage for version, configuration loading, ConfigError, and ApiError behavior.

### Changed

- Expanded the E2E support layer with reusable target registration, factories, execution mapping, resource cleanup, failure artifacts, and validation documentation.
- Hardened release and CI workflows by pinning GitHub Actions and disabling persisted checkout credentials.

### Fixed

- Preserved string messages passed to `Kubernetes::ApiError.new`, so `#message` returns the caller-provided message.

## [1.36.0.1] - 2026-05-25

### Added

- Added support for Kubernetes 1.36 by regenerating the client from Kubernetes OpenAPI `release-1.36`.

### Changed

- Updated kruby package metadata and compatibility checks for release `1.36.0.1`.
- Deduplicated processed OpenAPI operation IDs during generation for Kubernetes 1.36.

## [1.35.0.6] - 2026-04-16

### Changed

- Updated dependency lockfiles in `kubernetes/` to include `addressable` 2.9.0 (and `public_suffix` 7.0.5), pulling in upstream ReDoS remediation.

## [1.35.0.5] - 2026-03-16

### Fixed

- Hardened `Kubernetes::Watch` so malformed watch events are skipped with a warning instead of aborting the stream.
- Preserved caller-visible `JSON::ParserError` exceptions from watch callbacks instead of swallowing them as malformed watch events.

### Changed

- Retried Kind cluster bootstrap when Docker host port allocation collides during multi-version E2E runs.

## [1.35.0.4] - 2026-03-15

### Added

- Introduced changelog-driven release tooling for validating version, tag, and release-note alignment.
- Added automated GitHub Release publication from pushed `v*` tags.

## [1.35.0.3]

### Added

- Established the first tracked changelog baseline for the community-maintained fork.
- Documented support for Ruby 3.3+ and Kind-backed E2E coverage across Kubernetes 1.31 through 1.35.

### Changed

- Continued shipping the client generated from Kubernetes OpenAPI `release-1.35`.

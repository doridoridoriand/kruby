# Changelog

All notable changes to `kruby` are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Release tags use the format `v<version>` (for example `v1.35.0.4`), and the matching `## [<version>]` section in this file is published as the GitHub Release body.
Historical releases published before this file was introduced are summarized as a baseline entry instead of being reconstructed commit-by-commit.

## [Unreleased]

- Nothing yet.

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

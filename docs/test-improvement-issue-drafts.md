# Test Improvement Issue Drafts

This document captures categorized GitHub issue drafts for the current test coverage gaps.

Context:
- Repository: `doridoridoriand/kruby`
- Baseline branch inspected: `origin/master` at `fcf89ae`
- Local Ruby 3.3.8 RSpec: `210 examples, 0 failures, 2 pending`
- Ruby 3.4.9 container RSpec: `210 examples, 0 failures, 2 pending`
- Kind E2E full on Kubernetes 1.35: `183 resolved`, `183 covered`, `0 failed`
- Checked-in `coverage_inventory.json`: `556` candidate methods
- Regenerated inventory from current code: `816` candidate methods
- Regenerated inventory + current gate: `135` missing candidates

## Issue 1: Fix E2E coverage inventory and gate drift

Suggested labels: `test`, `e2e`, `coverage`, `ci`

### Summary

The checked-in E2E coverage inventory is stale relative to the generated API code, and the real inventory/policy coverage gate spec is currently skipped.

Observed:
- Checked-in inventory candidate methods: `556`
- Regenerated inventory candidate methods: `816`
- Current gate against regenerated inventory: `135` missing candidates
- `coverage_gate_spec.rb` skips the real policy check because the policy path points at the wrong location.
- `CoverageGate::COVERED_METHODS` is manually maintained and can drift from `Executor` / `ModeDispatcher`.

### Scope

- Regenerate `specs/002-real-api-e2e-coverage/coverage_inventory.json` from current code.
- Fix the real policy path in `kubernetes/spec/support/e2e/coverage_gate_spec.rb`.
- Make `CoverageInventory` correctly apply string `exclude_method_patterns` and API-level exclusions from `coverage_policy.yml`.
- Replace or validate the static `CoverageGate::COVERED_METHODS` list with a source derived from runtime target definitions.
- Add a CI/local check that fails when the checked-in inventory is stale.

### Acceptance Criteria

- `bundle exec rspec spec/support/e2e/coverage_gate_spec.rb` has no pending examples.
- Regenerating coverage inventory produces no diff.
- Coverage gate passes against the regenerated inventory and current policy.
- The coverage report clearly distinguishes `covered`, `missing`, and `excluded`.

### Suggested Verification

```bash
cd kubernetes
bundle exec rspec spec/support/e2e/coverage_gate_spec.rb
cd ..
scripts/e2e/generate-coverage-inventory --output /tmp/coverage_inventory.json
```

## Issue 2: Add E2E coverage for subresources and collection operations

Suggested labels: `test`, `e2e`, `coverage`

### Summary

After regenerating the E2E inventory from current generated API code, the coverage gate reports `135` missing candidates. These are concentrated in subresource and collection-style methods.

Missing categories:
- `status` subresources: `50`
- `delete_collection`: `30`
- all-namespaces list methods: `25`
- `scale` subresources: `12`
- events: `6`
- `scheduling.k8s.io/v1alpha2`: `12`

### Scope

- Add deterministic E2E targets for all-namespaces list methods where a resource can be safely created in the test namespace.
- Add `delete_collection` coverage using dedicated labels and the per-test namespace.
- Add read coverage for safe `status` subresources first, then patch/replace where the API server allows it.
- Add `scale` coverage for Deployment/ReplicaSet/StatefulSet/ReplicationController where supported.
- Add event coverage for both `events.k8s.io` and core event method naming where applicable.
- Gate `scheduling.k8s.io/v1alpha2` by API discovery, or add explicit policy exclusions with reasons if not supported by kind 1.35.

### Acceptance Criteria

- Regenerated coverage gate missing count is reduced from `135` to `0`, or every remaining item has an explicit reasoned exclusion.
- `scripts/e2e/run-e2e --mode full --kubernetes-version 1.35` passes.
- New targets appear in coverage JSON with `status: covered`.
- Collection delete targets cannot delete resources outside the E2E namespace or label selector.

### Suggested Verification

```bash
scripts/e2e/run-e2e --mode full --kubernetes-version 1.35
cd kubernetes
bundle exec rspec spec/e2e
```

## Issue 3: Expand E2E coverage for Core, Apps, and Batch resources

Suggested labels: `test`, `e2e`, `coverage`

### Summary

The current E2E catalog covers 28 resources and 183 selectors, but several generated Core/Apps/Batch resources remain untested or explicitly excluded.

Priority resources:
- Core: `LimitRange`, `ResourceQuota`, `ServiceAccount`, `PodTemplate`, `ReplicationController`
- Apps: `ControllerRevision`
- Batch: `CronJob`

### Scope

- Add target catalog entries for each resource.
- Add factory methods for minimal valid bodies.
- Add executor definitions using existing catalog-driven CRUD helpers where possible.
- Add changed-mode mapping from generated API/model files to the new selectors.
- Add full-mode regression specs verifying selectors are registered and ordered.

### Acceptance Criteria

- Each listed resource has CRUD coverage where kind supports the operation.
- New targets are selectable with `scripts/e2e/run-e2e --mode targeted`.
- Full E2E remains stable on Kubernetes 1.35.
- Coverage policy excludes only unsupported operations with explicit reasons.

### Suggested Verification

```bash
scripts/e2e/run-e2e --mode targeted --kubernetes-version 1.35 --targets 'batch/v1/cronjobs:create'
scripts/e2e/run-e2e --mode full --kubernetes-version 1.35
```

## Issue 4: Expand E2E coverage for Storage, Networking, CustomObjects, and admission-related APIs

Suggested labels: `test`, `e2e`, `coverage`

### Summary

Large generated API groups remain outside real API-call E2E coverage. Some can be tested directly in kind, while others need API discovery gates or explicit policy exclusions.

Priority areas:
- Storage: `VolumeAttachment`, `CSINode`, `VolumeAttributesClass`
- Networking: `IPAddress`, `ServiceCIDR`
- CustomObjects: namespaced and cluster-scoped CRUD using a test CRD
- Admission / Certificates / Flowcontrol / Resource APIs: classify by kind support and runtime safety

### Scope

- Add API discovery helpers so tests only run when the resource is served by the current cluster.
- Add test CRD setup and teardown for `CustomObjectsApi`.
- Add safe CRUD/list/patch/read coverage for cluster-scoped storage/networking resources where kind permits it.
- Convert impossible or unsafe operations into policy exclusions with clear reasons.

### Acceptance Criteria

- `CustomObjectsApi` has real namespaced and cluster-scoped create/list/read/patch/replace/delete coverage.
- Kind-incompatible APIs are not silent gaps; they are discovery-gated or reasoned exclusions.
- Full E2E coverage report contains no `unsupported` or `failed` targets.

### Suggested Verification

```bash
scripts/e2e/run-e2e --mode full --kubernetes-version 1.35
scripts/e2e/run-e2e-matrix --mode targeted --versions 1.31,1.35 --targets 'custom/v1/customobjects:create'
```

## Issue 5: Add generated model serialization smoke coverage

Suggested labels: `test`, `models`, `coverage`

### Summary

The generated model surface is much larger than the representative serialization tests currently cover.

Observed:
- Model files: `757`
- Representative model serialization cases: about `31` direct cases, about `40` unique model classes referenced
- Alpha/beta and Kubernetes 1.36-specific models have limited direct smoke coverage.

### Scope

- Add a generated or reflective model smoke spec that covers every model class.
- For each model class, verify:
  - initialization accepts valid known attributes,
  - unknown attributes raise `ArgumentError`,
  - `build_from_hash` returns an instance,
  - `to_hash` / `to_body` are callable,
  - equality/hash do not crash.
- Keep existing hand-written deep serialization cases for representative nested models.

### Acceptance Criteria

- Every model file under `kubernetes/lib/kubernetes/models` is included in smoke coverage, excluding only intentional base/helper files.
- Failures identify the exact model class and attribute causing the issue.
- The smoke spec runs without requiring a Kubernetes cluster.

### Suggested Verification

```bash
cd kubernetes
bundle exec rspec spec/models/serialization_spec.rb
```

## Issue 6: Strengthen ApiClient, Configuration, and Watch unit coverage

Suggested labels: `test`, `unit`, `client`

### Summary

Core client behavior has representative tests but lacks coverage for several important edge cases.

Gaps:
- `ApiClient#call_api` timeout, libcurl code 0, 4xx, and 5xx error paths
- `ApiClient#update_params_for_auth!` header and query injection
- form body and multipart body construction
- file download callback behavior
- `Configuration#base_url` expectations are present but commented out
- `Configuration#server_url` enum/default/error handling
- real watch event behavior beyond mocked streaming

### Scope

- Add WebMock-backed `call_api` specs for success and error paths.
- Add request-building specs for auth, form params, query params, and TLS options.
- Restore meaningful assertions in `configuration_spec.rb`.
- Add `server_url` tests for defaults, valid enum values, invalid enum values, and out-of-range server indexes.
- Add a minimal real-API watch E2E target or unit-level fake stream that verifies event handling deterministically.

### Acceptance Criteria

- `api_client_spec.rb`, `configuration_spec.rb`, and `watch_spec.rb` cover the listed branches.
- Error specs assert raised `Kubernetes::ApiError` content, including HTTP status and body where applicable.
- Tests remain offline except explicitly tagged real API examples.

### Suggested Verification

```bash
cd kubernetes
bundle exec rspec spec/api_client_spec.rb spec/configuration_spec.rb spec/watch_spec.rb
```

## Issue 7: Add CI jobs for inventory drift, coverage gate, and E2E scheduling

Suggested labels: `ci`, `test`, `e2e`, `coverage`

### Summary

CI currently runs RSpec and gem build on Ruby 3.3/3.4, but does not enforce E2E inventory freshness or coverage gate health. Kind-backed full E2E is also local/documented rather than scheduled.

### Scope

- Add PR CI checks for:
  - RSpec,
  - gem build,
  - package guard,
  - coverage inventory freshness,
  - coverage gate.
- Add a scheduled/nightly workflow for `scripts/e2e/run-e2e-matrix --mode full`.
- Add release-candidate guidance or workflow gate for strict full E2E.
- Upload E2E coverage and failure artifacts on failure.

### Acceptance Criteria

- PR CI fails if regenerated `coverage_inventory.json` differs from the checked-in file.
- PR CI fails if coverage gate has missing candidates.
- Nightly E2E matrix runs across supported kind Kubernetes versions.
- E2E artifacts are retained for debugging.

### Suggested Verification

```bash
cd kubernetes
bundle exec rspec
rm -f kruby-*.gem
gem build kubernetes.gemspec
bundle exec rake e2e:package_guard
cd ..
scripts/e2e/generate-coverage-inventory --output /tmp/coverage_inventory.json
```

## Optional `gh` Commands

When GitHub CLI authentication is available, create issues from the sections above with commands like:

```bash
gh issue create --repo doridoridoriand/kruby \
  --title "Fix E2E coverage inventory and gate drift" \
  --label "test,e2e,coverage,ci" \
  --body-file /path/to/body.md
```

# E2E Kind Testing Troubleshooting

This runbook covers common flaky cases for local/CI E2E runs.

## Scope
- E2E runner: `scripts/e2e/run-e2e`
- Change mapping: `scripts/e2e/map-changes`
- Package safety: `scripts/e2e/check-gem-package`

## Quick Health Checks

```bash
docker version
kind version
kubectl version --client
(cd kubernetes && bundle exec rspec spec/e2e --format progress)
```

If any command above fails, fix it before debugging test logic.

## Flaky kind Startup

### Symptom
- `kind create cluster` intermittently fails
- Cluster creation times out in CI

### Checks

```bash
kind get clusters
docker ps --format 'table {{.Names}}\t{{.Status}}'
docker system df
```

### Mitigations
- Remove stale clusters:

```bash
kind get clusters | while IFS= read -r cluster; do
  [ -n "${cluster}" ] || continue
  kind delete cluster --name "${cluster}"
done
```

`xargs -r` is GNU-specific and not available on macOS/BSD `xargs`, so this uses a portable while-loop that safely skips empty input.

- Clean Docker resources when disk pressure is high:

```bash
docker system prune -f
```

- Retry with full mode reuse disabled for isolation:

```bash
E2E_REUSE_CLUSTER=0 scripts/e2e/run-e2e --mode full
```

## Cleanup/Leak Issues

### Symptom
- Namespace leftovers after E2E
- Re-run fails due to existing resources

### Checks

```bash
kubectl get ns | rg kruby-e2e || true
```

### Mitigations

```bash
kubectl get ns -o name | rg 'namespace/kruby-e2e' | sed 's#namespace/##' | while IFS= read -r ns; do
  [ -n "${ns}" ] || continue
  kubectl delete ns "${ns}" --wait=false
done

kind get clusters | rg '^kruby-e2e' | while IFS= read -r cluster; do
  [ -n "${cluster}" ] || continue
  kind delete cluster --name "${cluster}"
done
```

## Changed-mode Mapping Mismatch

### Symptom
- `changed` mode unexpectedly falls back

### Checks

```bash
scripts/e2e/map-changes --base-ref origin/HEAD --format json
scripts/e2e/map-changes --changed-file kubernetes/lib/kubernetes/api/core_v1_api.rb --format json
```

### Mitigations
- Confirm target definitions exist under `kubernetes/spec/support/e2e/targets`.
- Use explicit targeted run for quick isolation:

```bash
scripts/e2e/run-e2e --mode targeted --targets core/v1/pods:create
```

## Packaging Guard Failures

### Symptom
- `bundle exec rake e2e:package_guard` fails

### Checks

```bash
scripts/e2e/check-gem-package
```

### Mitigations
- Ensure gemspec whitelist still only includes runtime files (`lib`, `README`, `LICENSE`).
- Remove accidental additions under `spec/`, `test/`, `features/`, `docs/` from package inputs.

## Failure Reporting Checklist
- Include `run-e2e` summary block
- Include `repro_command` from failure artifact
- Include `mappedTargets` output from `map-changes` when mode is `changed`

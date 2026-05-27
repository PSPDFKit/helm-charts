# Changelog

- [Changelog](#changelog)
  - [0.5.0 (2026-05-27)](#050-2026-05-27)
  - [0.4.0 (2026-05-26)](#040-2026-05-26)

## 0.5.0 (2026-05-27)

### Changed

- `appVersion` bumped to `v1.1.1`.
- `startupProbe`, `livenessProbe`, and `readinessProbe` now default to HTTP
  GET on `/health` (port `http`). Set the corresponding value to `{}` to
  disable an individual probe.
  - Startup: `failureThreshold: 30`, `periodSeconds: 10`, `timeoutSeconds: 5`
    (≈ 5 min boot budget before kubelet starts liveness/readiness checks).
  - Liveness: `failureThreshold: 3`, `periodSeconds: 30`, `timeoutSeconds: 5`
    (intentionally less aggressive than readiness — a failure restarts the
    container).
  - Readiness: `failureThreshold: 3`, `periodSeconds: 10`, `timeoutSeconds: 5`.

## 0.4.0 (2026-05-26)

First public release. Value-compatible with the internal `0.3.4` chart, with
defaults reset to neutral values (set them in your values file to preserve
the old behaviour):

```yaml
image:
  repository: 111300957880.dkr.ecr.eu-west-1.amazonaws.com/maestrod  # now pspdfkit/maestrod
  tag: stable                                                          # now empty (falls back to appVersion)
  pullPolicy: Always                                                   # now IfNotPresent
imagePullSecrets: [{ name: image-registry-mcleod-ecr }]                # now []
podLabels: { component_name: maestrod, otel/logging-enabled: "true" }  # now {}
# only if restartJob.enabled: true
restartJob: { registryAuthSecretName: image-registry-mcleod-ecr }      # now ""
```

### Added

- `templates/configmap.yaml` carries `NUTRIENT_SHOW_SCALAR` /
  `NATIVESDK_VISION_LOGS`, loaded via `envFrom` with a `checksum/config`
  rollout trigger (Document Engine pattern).
- Standard public-chart knobs: `serviceAccount`, `autoscaling`,
  `podDisruptionBudget`, `startup`/`livenessProbe`, `lifecycle`,
  `topologySpreadConstraints`, `schedulerName`, `deploymentAnnotations`,
  `extraEnvs` / `extraEnvFrom` / `extraEnvFromSecrets` / `extraVolumes` /
  `extraVolumeMounts` / `sidecars` / `initContainers`. All opt-in, default
  no-op.
- Generated `README.md` (helm-docs) and `values.schema.json`
  (helm-values-schema-json).
- `helm test` connection probe; `ci/` test value files.
- `licenseSecret.name: ""` now skips the `NUTRIENT_LICENSE_KEY` env var
  (previously hard-coded).

### Changed

- `image.repository` defaults to `pspdfkit/maestrod` (and is schema-rejected
  when empty).
- Restart Job moved under `templates/restart-job/` (`configmap.yaml`,
  `cronjob.yaml`, `rbac.yaml`, `serviceaccount.yaml`).

### Fixed

- `PodDisruptionBudget` no longer renders both `minAvailable` and
  `maxUnavailable`; `maxUnavailable` wins. Integer `0` is recognised.
- `Deployment.spec.strategy` omits `rollingUpdate` when `type: Recreate`.
- `updateStrategy.rollingUpdate.{maxSurge,maxUnavailable}` accept integer or
  percentage string (`IntOrString`).
- `service.type` enum no longer advertises `ExternalName` (unsupported by
  the Service template).

### CI

- `maestrod` is excluded from `ct install` until a public maestrod image is
  available; `ct lint` still runs on every PR.

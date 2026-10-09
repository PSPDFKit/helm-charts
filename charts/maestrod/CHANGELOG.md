# Changelog

- [Changelog](#changelog)
  - [0.10.0 (2026-10-09)](#0100-2026-10-09)
    - [Added](#added)
    - [Changed](#changed)
  - [0.9.0 (2026-10-07)](#090-2026-10-07)
    - [Changed](#changed-1)
  - [0.8.0 (2026-09-30)](#080-2026-09-30)
    - [Changed](#changed-2)
  - [0.7.1 (2026-09-18)](#071-2026-09-18)
    - [Changed](#changed-3)
  - [0.7.0 (2026-09-17)](#070-2026-09-17)
    - [Changed](#changed-4)
  - [0.6.8 (2026-08-28)](#068-2026-08-28)
    - [Changed](#changed-5)
  - [0.6.7 (2026-08-19)](#067-2026-08-19)
    - [Changed](#changed-6)
  - [0.6.6 (2026-08-07)](#066-2026-08-07)
    - [Changed](#changed-7)
  - [0.6.5 (2026-08-05)](#065-2026-08-05)
    - [Changed](#changed-8)
  - [0.6.4 (2026-07-23)](#064-2026-07-23)
    - [Changed](#changed-9)
  - [0.6.3 (2026-06-23)](#063-2026-06-23)
    - [Changed](#changed-10)
  - [0.6.2 (2026-06-12)](#062-2026-06-12)
    - [Changed](#changed-11)
  - [0.6.1 (2026-05-30)](#061-2026-05-30)
    - [Changed](#changed-12)
  - [0.6.0 (2026-05-29)](#060-2026-05-29)
    - [Added](#added-1)
  - [0.5.0 (2026-05-27)](#050-2026-05-27)
    - [Added](#added-2)

## 0.10.0 (2026-10-09)

### Added

- Optional KEDA autoscaling via `keda`. When `keda.enabled` is `true`, the
  chart renders a `keda.sh/v1alpha1` ScaledObject for the Deployment, passes
  `keda.triggers`, `keda.advanced` and `keda.fallback` through verbatim, and
  omits the Deployment's `replicas`. Rendering fails when `keda.enabled` and
  `autoscaling.enabled` are both `true`, or when `keda.triggers` is empty.

### Changed

- Updated maestrod appVersion to `1.6.1`.

## 0.9.0 (2026-10-07)

### Changed

- Updated maestrod appVersion to `1.6.0`.

## 0.8.0 (2026-09-30)

### Changed

- Updated maestrod appVersion to `1.5.0`.

## 0.7.1 (2026-09-18)

### Changed

- Updated maestrod appVersion to `1.4.1`.

## 0.7.0 (2026-09-17)

### Changed

- Updated maestrod appVersion to `1.4.0`.

## 0.6.8 (2026-08-28)

### Changed

- Updated maestrod appVersion to `1.3.3`.

## 0.6.7 (2026-08-19)

### Changed

- Updated maestrod appVersion to `1.3.2`.

## 0.6.6 (2026-08-07)

### Changed

- Updated maestrod appVersion to `1.3.1`.

## 0.6.5 (2026-08-05)

### Changed

- Updated maestrod appVersion to `1.3.0`.
- Removed account-specific ECR metadata from public CI values and migration
  documentation.

## 0.6.4 (2026-07-23)

### Changed

- Updated maestrod appVersion to `1.2.0`.

## 0.6.3 (2026-06-23)

### Changed

- Updated maestrod appVersion to `1.1.5`.

## 0.6.2 (2026-06-12)

### Changed

- Updated maestrod appVersion to `1.1.3`.

## 0.6.1 (2026-05-30)

### Changed

- Updated maestrod appVersion to `1.1.2`.

## 0.6.0 (2026-05-29)

### Added

- Optional Prometheus Operator ServiceMonitor via
  `observability.metrics.serviceMonitor`.

## 0.5.0 (2026-05-27)

First public release. Value-compatible with the internal `0.3.4` chart; the
following defaults changed — set them explicitly to preserve old behaviour:

```yaml
image:
  repository: <account>.dkr.ecr.eu-west-1.amazonaws.com/maestrod  # now pspdfkit/maestrod
  tag: nightly                  # now empty (→ appVersion)
  pullPolicy: Always                                                   # now IfNotPresent
imagePullSecrets: <...>
podLabels: { component_name: maestrod }  # now {}
restartJob:
  registryAuthSecretName: "<...>" # now ""
```

### Added

- `/health` HTTP defaults for `startupProbe` / `livenessProbe` / `readinessProbe`.
- `NUTRIENT_SHOW_SCALAR` / `NATIVESDK_VISION_LOGS` via ConfigMap with
  `checksum/config` rollout trigger.
- `serviceAccount`, `autoscaling`, `podDisruptionBudget`, `deploymentAnnotations`,
  `topologySpreadConstraints`, `schedulerName`, `lifecycle`, `extra*`,
  `sidecars`, `initContainers`.
- `licenseSecret.name: ""` skips the `NUTRIENT_LICENSE_KEY` env var.
- Generated `README.md` + `values.schema.json`; `ci/` values; `helm test` probe.

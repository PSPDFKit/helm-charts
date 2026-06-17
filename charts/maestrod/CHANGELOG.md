# Changelog

- [Changelog](#changelog)
  - [0.7.0 (2026-06-17)](#070-2026-06-17)
    - [Added](#added)
  - [0.6.2 (2026-06-12)](#062-2026-06-12)
    - [Changed](#changed)
  - [0.6.1 (2026-05-30)](#061-2026-05-30)
    - [Changed](#changed-1)
  - [0.6.0 (2026-05-29)](#060-2026-05-29)
    - [Added](#added-1)
  - [0.5.0 (2026-05-27)](#050-2026-05-27)
    - [Added](#added-2)

## 0.7.0 (2026-06-17)

### Added

- Grafana dashboard for Maestrod, delivered as a sidecar-discovered ConfigMap
  (`observability.metrics.grafanaDashboard`, disabled by default). Panels cover
  per-route AI token usage (`nutrient.ai.tokens_total`), AI call latency and
  reliability, per-route HTTP RED metrics, vision quality/throughput, and process
  health. Requires the `serviceMonitor` (or another scrape path) and a Grafana
  sidecar watching the `grafana_dashboard` label.

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

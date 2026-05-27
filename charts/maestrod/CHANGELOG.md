# Changelog

- [Changelog](#changelog)
  - [0.5.0 (2026-05-27)](#050-2026-05-27)
    - [Added](#added)

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

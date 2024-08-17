# Changelog

- [Changelog](#changelog)
  - [3.0.0 (2024-08-17)](#300-2024-08-17)
    - [Added](#added)
    - [Changed](#changed)
  - [2.9.3 (2024-08-16)](#293-2024-08-16)
    - [Fixed](#fixed)
  - [2.9.2 (2024-08-13)](#292-2024-08-13)
    - [Changed](#changed-1)
  - [2.9.1 (2024-08-10)](#291-2024-08-10)
    - [Added](#added-1)
    - [Changed](#changed-2)
  - [2.9.0 (2024-08-01)](#290-2024-08-01)
    - [Added](#added-2)
    - [Changed](#changed-3)
    - [Fixed](#fixed-1)
  - [2.8.0](#280)
    - [Added](#added-3)
    - [Changed](#changed-4)
    - [Fixed](#fixed-2)
  - [2.7.3](#273)
    - [Changed](#changed-5)
    - [Fixed](#fixed-3)
  - [2.7.2](#272)
    - [Fixed](#fixed-4)
  - [2.7.0](#270)
    - [Changed](#changed-6)
  - [2.6.2](#262)
    - [Added](#added-4)
    - [Changed](#changed-7)
  - [2.6.0](#260)
    - [Added](#added-5)
  - [2.4.0](#240)
    - [Added](#added-6)
  - [2.3.0](#230)
    - [Added](#added-7)
  - [2.2.0](#220)
    - [Added](#added-8)
  - [2.1.0](#210)
    - [Changed](#changed-8)
  - [2.0.0](#200)
    - [Changed](#changed-9)

## 3.0.0 (2024-08-17)

### Added

* Health check log level as `observability.healthcheckLevel`

### Changed

* `pspdfkit.observability` section moved to the top level as `observability`.
* `pspdfkit.log.level` moved into `observability.log.level`.
* `metrics` section moved to `observability.metrics`.

## 2.9.3 (2024-08-16)

### Fixed

* Signing trust certificates configuration.

## 2.9.2 (2024-08-13)

### Changed

* Additional test to cover migration from Docker Compose by being friendly to putting _all_ into `envFrom`.

## 2.9.1 (2024-08-10)

### Added

* Support for secrets rotation enablement option. Setting `pspdfkit.replaceSecretsFromEnv` to `false` will make Document Engine to ignore `JWT_PUBLIC_KEY`, `SECRET_KEY_BASE` and `DASHBOARD_PASSWORD` environment variables, values (`pspdfkit.auth.api.jwt.publicKey`, `pspdfkit.secretKeyBase` and `pspdfkit.auth.dashboard.password`) and the corresponding secrets.

### Changed

* Minor cleanups

## 2.9.0 (2024-08-01)

### Added

* Azure blob storage support.
* Introduced `pspdfkit.signingTrustConfigMaps` for ConfigMaps to mount to `/certificate-stores/`

### Changed

* [Document Engine 1.4.1](https://pspdfkit.com/changelog/document-engine/#1.4.1)

### Fixed

* Asset storage fallback.

## 2.8.0

### Added

* Support for OpenTelemetry traces, enabled by setting `pspdfkit.observability.opentelemetry.enabled` to `true`. 
  * Unless the collector is placed as a sidecar and receives by grpc at port `4317`, other parameters are also necessary. 
  * Please note: standard OpenTelemetry environment variables are used, and the following values are just convenience wrappers, therefore other configuration approaches (e.g. setting variables through mutations or post build patches) will also work.
  * Wrapped parameters (see `values.yaml` for more details):
    * `pspdfkit.observability.opentelemetry.otlpExporterEndpoint` (`OTEL_EXPORTER_OTLP_ENDPOINT`)
    * `pspdfkit.observability.opentelemetry.otlpExporterProtocol` (`OTEL_EXPORTER_OTLP_PROTOCOL`)
    * `pspdfkit.observability.opentelemetry.otelServiceName` (`OTEL_SERVICE_NAME`)
    * `pspdfkit.observability.opentelemetry.otelResourceAttributes` (`OTEL_RESOURCE_ATTRIBUTES`)
    * `pspdfkit.observability.opentelemetry.otelPropagators` (`OTEL_PROPAGATORS`)
* Dependent charts for [MinIO](https://min.io/) and [Redis](https://redis.io/).

### Changed

* [Document Engine 1.4.0](https://pspdfkit.com/changelog/document-engine/#1.4.0)
* Changed `pspdfkit.storage.enableMigrationJobs` to `pspdfkit.storage.databaseMigrationJob.enabled`.
* Renamed `.Values.pspdfkit.storage.redis.sentinels` to `.Values.pspdfkit.storage.redis.sentinel`.
* Slight refinement of trust information parameters: all files from `pspdfkit.trustConfigMaps` are now mounted to `/certificate-stores-custom/` to avoid confusion with `/certificate-stores/` which services for document signature validation certificates.

### Fixed

* Minor cleanups.

## 2.7.3

### Changed

* Moved changes from [README.md](/charts/document-engine/README.md) here.

### Fixed

* Corrected the comment in `values.yaml` (thanks to [Blaise Schaeffer](https://github.com/blaise2s)).

## 2.7.2

### Fixed

* Installing without license.

## 2.7.0

### Changed

* [Document Engine 1.3.0](https://pspdfkit.com/changelog/document-engine/#1.3.0)

## 2.6.2

### Added

* Added `deploymentAnnotations` (courtesy of [k11h.de](https://github.com/k11h-de)).
* Added `pspdfkit.storage.cleanupJob.podAnnotations`.

### Changed

* Updated StatsD Prometheus exporter image tag.

## 2.6.0

### Added

* Added ServiceMonitor for Prometheus Operator (setting `metrics.serviceMonitor.enabled` to `true` should work in most cases).
* Added PrometheusRule for Prometheus Operator.

## 2.4.0

### Added

* Added support for NetworkPolicy.

## 2.3.0

### Added

* Added a possibility to override backend in Ingress resources, in order to enable special configurations (e.g. AWS Load Balancer Controller).

## 2.2.0

### Added

* Added `pspdfkit.trustConfigMaps`, a map of ConfigMap references for trust certificates
* Added `pspdfkit.downloaderTrustFileName` for remote file downloader certificates file from `pspdfkit.trustConfigMaps`
* Added `pspdfkit.storage.postgres.tls.verify` (defaults to `true`) to enable PostgreSQL TLS certificate validation
* Added `pspdfkit.storage.postgres.tls.trustFileName` to specify the trust certificates file from `pspdfkit.trustConfigMaps` for PostgreSQL connection

## 2.1.0

### Changed

* Value `dashboardIngress` replaced by `extraIngresses` map to accommodate to more complex endpoint scenarios.

## 2.0.0

### Changed

* No more `createSecret` values, condition for creating secret by the chart are moved into definition of the corresponding external secret names.
* Storage parameters are now expected to fully reside in `Secret` resources
  * `pspdfkit.storage.postgres.auth`, `pspdfkit.storage.s3.auth`, `pspdfkit.storage.redis.auth` maps were all merged into the corresponding `pspdfkit.storage` higher level maps
  * Redis secret is now expected to contain (if existsis) all Redis parameters, not only the password

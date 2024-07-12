# Changelog

- [Changelog](#changelog)
  - [2.7.3](#273)
    - [Changed](#changed)
  - [2.7.2](#272)
    - [Fixed](#fixed)
  - [2.7.0](#270)
    - [Changed](#changed-1)
  - [2.6.2](#262)
    - [Added](#added)
    - [Changed](#changed-2)
  - [2.6.0](#260)
    - [Added](#added-1)
  - [2.4.0](#240)
    - [Added](#added-2)
  - [2.3.0](#230)
    - [Added](#added-3)
  - [2.2.0](#220)
    - [Added](#added-4)
  - [2.1.0](#210)
    - [Changed](#changed-3)
  - [2.0.0](#200)
    - [Changed](#changed-4)

## 2.7.3

### Changed

* Moved changes from [README.md](/charts/document-engine/README.md) here.

## 2.7.2

### Fixed

* Installing without license.

## 2.7.0

### Changed

* [Document Engine 1.3.0](https://pspdfkit.com/changelog/document-engine/#1.3.0)

## 2.6.2

### Added

* Added `deploymentAnnotations` (courtesy of [@k11h-de]).
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

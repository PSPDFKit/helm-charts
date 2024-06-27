# Document Engine Helm chart

- [Document Engine Helm chart](#document-engine-helm-chart)
  - [Upgrade](#upgrade)
    - [To 2.7.0](#to-270)
    - [To 2.6.2](#to-262)
    - [To 2.6.0](#to-260)
    - [To 2.4.0](#to-240)
    - [To 2.3.0](#to-230)
    - [To 2.2.0](#to-220)
    - [To 2.1.0](#to-210)
    - [To 2.0.0](#to-200)
  - [License](#license)
  - [Support, Issues and License Questions](#support-issues-and-license-questions)

[More on Document Engine](https://pspdfkit.com/cloud/document-engine/)

## Upgrade

### To 2.7.0

* Document Engine 1.3.0

### To 2.6.2

* Added `deploymentAnnotations` (courtesy of @k11h-de).
* Added `pspdfkit.storage.cleanupJob.podAnnotations`.
* Updated StatsD Prometheus exporter image tag.

### To 2.6.0

* Added ServiceMonitor for Prometheus Operator (setting `metrics.serviceMonitor.enabled` to `true` should work in most cases).
* Added PrometheusRule for Prometheus Operator.

### To 2.4.0

* Added support for NetworkPolicy.

### To 2.3.0

* Added a possibility to override backend in Ingress resources, in order to enable special configurations (e.g. AWS Load Balancer Controller).

### To 2.2.0

* Added `pspdfkit.trustConfigMaps`, a map of ConfigMap references for trust certificates
* Added `pspdfkit.downloaderTrustFileName` for remote file downloader certificates file from `pspdfkit.trustConfigMaps`
* Added `pspdfkit.storage.postgres.tls.verify` (defaults to `true`) to enable PostgreSQL TLS certificate validation
* Added `pspdfkit.storage.postgres.tls.trustFileName` to specify the trust certificates file from `pspdfkit.trustConfigMaps` for PostgreSQL connection

### To 2.1.0

* Value `dashboardIngress` replaced by `extraIngresses` map to accommodate to more complex endpoint scenarios.

### To 2.0.0

* No more `createSecret` values, condition for creating secret by the chart are moved into definition of the corresponding external secret names.
* Storage parameters are now expected to fully reside in `Secret` resources
  * `pspdfkit.storage.postgres.auth`, `pspdfkit.storage.s3.auth`, `pspdfkit.storage.redis.auth` maps were all merged into the corresponding `pspdfkit.storage` higher level maps
  * Redis secret is now expected to contain (if existsis) all Redis parameters, not only the password

## License

This software is licensed under a [modified BSD license](LICENSE).

## Support, Issues and License Questions

PSPDFKit offers support via https://pspdfkit.com/support/request/

Are you [evaluating our SDK](https://pspdfkit.com/try/)? That's great, we're happy to help out! To make sure this is fast, please use a work email and have someone from your company fill out our sales form: https://pspdfkit.com/sales/


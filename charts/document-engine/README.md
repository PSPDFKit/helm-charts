# Document Engine Helm chart

![Version: 3.1.2](https://img.shields.io/badge/Version-3.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.4.1](https://img.shields.io/badge/AppVersion-1.4.1-informational?style=flat-square)

Document Engine is a backend software for processing documents and powering automation workflows.

**Homepage:** <https://pspdfkit.com/guides/document-engine/>

* [Using this chart](#using-this-chart)
* [Values](#values)
  * [Document Engine License](#document-engine-license)
  * [API authentication](#api-authentication)
  * [Configuration options](#configuration-options)
  * [Certificate trust](#certificate-trust)
  * [Database](#database)
  * [Document lifecycle](#document-lifecycle)
  * [Asset storage](#asset-storage)
  * [Digital signatures](#digital-signatures)
  * [Dashboard](#dashboard)
  * [Environment](#environment)
  * [Metadata](#metadata)
  * [Networking](#networking)
  * [Observability](#observability)
  * [Pod lifecycle](#pod-lifecycle)
  * [Scheduling](#scheduling)
  * [Chart dependencies](#chart-dependencies)
* [Contribution](#contribution)
* [License](#license)
* [Support, Issues and License Questions](#support-issues-and-license-questions)

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| PSPDFKit | <support@pspdfkit.com> | <https://pspdfkit.com> |

## Using this chart

### Adding the repository

```shell
helm repo add pspdfkit https://pspdfkit.github.io/helm-charts
helm repo update
```

### Installing Document Engine

```shell
helm upgrade --install -n document-engine \
     document-engine pspdfkit/document-engine \
     -f ./document-engine-values.yaml
```

### Dependencies

The chart depends upon [Bitnami](https://github.com/bitnami/charts/tree/main/bitnami) charts for PostgreSQL, [MinIO](https://min.io/) and [Redis](https://redis.io/). They are disabled by default, but can be enabled for convenience. Please consider [tests](/charts/document-engine/ci) as examples.

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | minio | 14.7.1 |
| https://charts.bitnami.com/bitnami | postgresql | 15.5.24 |
| https://charts.bitnami.com/bitnami | redis | 20.0.3 |

### Upgrade

> [!NOTE]
> Please consult the [changelog](/charts/document-engine/CHANGELOG.md)

## Values

### Document Engine License

| Key | Description | Default |
|-----|-------------|---------|
| [`documentEngineLicense`](./values.yaml#L5) | License information, see more in [our guide](https://pspdfkit.com/guides/document-engine/deployment/product-activation/) |  |
| [`documentEngineLicense.activationKey`](./values.yaml#L10) | Activation key for online activation (most common) or license key for offline activation. Results in `ACTIVATION_KEY` environment variable. | `""` |
| [`documentEngineLicense.externalSecret`](./values.yaml#L15) | Query existing secret for the activation key | [...](./values.yaml#L15) |

### API authentication

| Key | Description | Default |
|-----|-------------|---------|
| [`apiAuth`](./values.yaml#L28) | Document Enging API authentication |  |
| [`apiAuth.apiToken`](./values.yaml#L32) | `API_AUTH_TOKEN`, a universal secret with full access to the API,  should be long enough | `"secret"` |
| [`apiAuth.externalSecret`](./values.yaml#L58) | Use an external secret for API credentials | [...](./values.yaml#L58) |
| [`apiAuth.jwt`](./values.yaml#L36) | JSON Web Token (JWT) settings | [...](./values.yaml#L36) |
| [`apiAuth.jwt.algorithm`](./values.yaml#L47) | `JWT_ALGORITHM` Supported algorithms: `RS256`, `RS512`, `ES256`, `ES512`. See RFC 7518 for details about specific algorithms. | `"RS256"` |
| [`apiAuth.jwt.enabled`](./values.yaml#L39) | Enable JWT | `false` |
| [`apiAuth.jwt.publicKey`](./values.yaml#L42) | `JWT_PUBLIC_KEY` | `"none"` |
| [`apiAuth.secretKeyBase`](./values.yaml#L53) | A string used as the base key for deriving secret keys for the purposes of authentication. Choose a sufficiently long random string for this option. To generate a random string, use: `openssl rand -hex 256`. This will set `SECRET_KEY_BASE` environment variable. | `""` |

### Configuration options

| Key | Description | Default |
|-----|-------------|---------|
| [`config`](./values.yaml#L88) | General configuration, see more in [our guide](https://pspdfkit.com/guides/document-engine/configuration/overview/) |  |
| [`config.allowDocumentGeneration`](./values.yaml#L121) | `ALLOW_DOCUMENT_GENERATION` | `true` |
| [`config.allowDocumentUploads`](./values.yaml#L115) | `ALLOW_DOCUMENT_UPLOADS` | `true` |
| [`config.allowRemoteAssetsInGeneration`](./values.yaml#L124) | `ALLOW_REMOTE_ASSETS_IN_GENERATION` | `true` |
| [`config.allowRemoteDocuments`](./values.yaml#L118) | `ALLOW_REMOTE_DOCUMENTS` | `true` |
| [`config.asyncJobsTtlSeconds`](./values.yaml#L112) | `ASYNC_JOBS_TTL` | `172800` |
| [`config.automaticLinkExtraction`](./values.yaml#L130) | `AUTOMATIC_LINK_EXTRACTION` | `false` |
| [`config.generationTimeoutSeconds`](./values.yaml#L100) | `PDF_GENERATION_TIMEOUT` in seconds | `20` |
| [`config.ignoreInvalidAnnotations`](./values.yaml#L127) | `IGNORE_INVALID_ANNOTATIONS` | `true` |
| [`config.maxUploadSizeMegaBytes`](./values.yaml#L109) | `MAX_UPLOAD_SIZE_BYTES` in megabytes | `950` |
| [`config.minSearchQueryLength`](./values.yaml#L133) | `MIN_SEARCH_QUERY_LENGTH` | `3` |
| [`config.port`](./values.yaml#L144) | `PORT` for the Document Engine API | `5000` |
| [`config.proxy`](./values.yaml#L139) | Proxy settings, `HTTP_PROXY` amd `HTTPS_PROXY` | `{"http":"","https":""}` |
| [`config.readAnnotationBatchTimeoutSeconds`](./values.yaml#L106) | `READ_ANNOTATION_BATCH_TIMEOUT` in seconds | `20` |
| [`config.replaceSecretsFromEnv`](./values.yaml#L149) | `REPLACE_SECRETS_FROM_ENV` — whether to consider environment variables, values and secrets for `JWT_PUBLIC_KEY`, `SECRET_KEY_BASE` and `DASHBOARD_PASSWORD` | `true` |
| [`config.requestTimeoutSeconds`](./values.yaml#L94) | Full request timeout in seconds (`SERVER_REQUEST_TIMEOUT`) | `60` |
| [`config.trustedProxies`](./values.yaml#L136) | `TRUSTED_PROXIES` | `"default"` |
| [`config.urlFetchTimeoutSeconds`](./values.yaml#L103) | `REMOTE_URL_FETCH_TIMEOUT` in seconds | `5` |
| [`config.workerPoolSize`](./values.yaml#L91) | `PSPDFKIT_WORKER_POOL_SIZE` | `16` |
| [`config.workerTimeoutSeconds`](./values.yaml#L97) | Document processing timeout in seconds (`PSPDFKIT_WORKER_TIMEOUT`) | `60` |

### Certificate trust

| Key | Description | Default |
|-----|-------------|---------|
| [`certificateTrust`](./values.yaml#L154) | [Certificate trust](https://pspdfkit.com/guides/document-engine/configuration/certificate-trust/) |  |
| [`certificateTrust.customCertificates`](./values.yaml#L167) | ConfigMap and Secret references for trust configuration, stored in `/certificate-stores-custom` | `[]` |
| [`certificateTrust.digitalSignatures`](./values.yaml#L158) | CAs for digital signatures (`/certificate-stores/`) from ConfigMap and Secret resources. | `[]` |
| [`certificateTrust.downloaderTrustFileName`](./values.yaml#L177) | Override `DOWNLOADER_CERT_FILE_PATH` to set HTTP client trust. If empty, defaults to  Mozilla's CA bundle. | `""` |

### Database

| Key | Description | Default |
|-----|-------------|---------|
| [`database`](./values.yaml#L182) | Database |  |
| [`database.connections`](./values.yaml#L191) | `DATABASE_CONNECTIONS` | `20` |
| [`database.enabled`](./values.yaml#L185) | Persistent storage enabled | `true` |
| [`database.engine`](./values.yaml#L188) | Database engine: only `postgres` is currently supported | `"postgres"` |
| [`database.migrationJob`](./values.yaml#L255) | Database migration jobs. | [...](./values.yaml#L255) |
| [`database.migrationJob.enabled`](./values.yaml#L258) | It `true`, results in `ENABLE_DATABASE_MIGRATIONS=false` in the main Document Engine container | `false` |
| [`database.postgres`](./values.yaml#L196) | PostgreSQL database settings | [...](./values.yaml#L196) |
| [`database.postgres.adminPassword`](./values.yaml#L217) | `PG_ADMIN_PASSWORD` | `"despair"` |
| [`database.postgres.adminUsername`](./values.yaml#L214) | `PG_ADMIN_USER` | `"postgres"` |
| [`database.postgres.database`](./values.yaml#L205) | `PGDATABASE` | `"document-engine"` |
| [`database.postgres.externalAdminSecretName`](./values.yaml#L226) | External secret for administrative database credentials, used for migrations: `PG_ADMIN_USER` and `PG_ADMIN_PASSWORD` | `""` |
| [`database.postgres.externalSecretName`](./values.yaml#L222) | Use external secret for database credentials. `PGUSER` and `PGPASSWORD` must be provided and, if not defined: `PGDATABASE`, `PGHOST`, `PGPORT`, `PGSSL` | `""` |
| [`database.postgres.host`](./values.yaml#L199) | `PGHOST` | `"postgresql"` |
| [`database.postgres.password`](./values.yaml#L211) | `PGPASSWORD` | `"despair"` |
| [`database.postgres.port`](./values.yaml#L202) | `PGPORT` | `5432` |
| [`database.postgres.tls`](./values.yaml#L231) | TLS settings | [...](./values.yaml#L231) |
| [`database.postgres.tls.commonName`](./values.yaml#L244) | Common name for the certificate (`PGSSL_CERT_COMMON_NAME`), defaults to `PGHOST` value | `""` |
| [`database.postgres.tls.enabled`](./values.yaml#L234) | Enable TLS (`PGSSL`) | `false` |
| [`database.postgres.tls.hostVerify`](./values.yaml#L240) | Negated `PGSSL_DISABLE_HOSTNAME_VERIFY` | `true` |
| [`database.postgres.tls.trustBundle`](./values.yaml#L248) | Trust bundle for PostgreSQL, sets `PGSSL_CA_CERTS`, mutually exclusive with `trustFileName` and takes precedence | `""` |
| [`database.postgres.tls.trustFileName`](./values.yaml#L251) | Path from `certificateTrust.customCertificates`, wraps around `PGSSL_CA_CERT_PATH` | `""` |
| [`database.postgres.tls.verify`](./values.yaml#L237) | Negated `PGSSL_DISABLE_VERIFY` | `true` |
| [`database.postgres.username`](./values.yaml#L208) | `PGUSER` | `"de-user"` |

### Document lifecycle

| Key | Description | Default |
|-----|-------------|---------|
| [`documentLifecycle`](./values.yaml#L271) | Document lifecycle management |  |
| [`documentLifecycle.cleanupJob`](./values.yaml#L276) | Regular job to remove documents from the database. Note: currently only works with the `built-in` storage backend. | [...](./values.yaml#L276) |
| [`documentLifecycle.cleanupJob.enabled`](./values.yaml#L279) | Enable the cleanup job | `false` |
| [`documentLifecycle.cleanupJob.keepHours`](./values.yaml#L285) | Documents TTL in hours | `24` |
| [`documentLifecycle.cleanupJob.persistentLike`](./values.yaml#L288) | Keep documents with IDs beginning with `persistent` indefinitely | `"persistent%"` |
| [`documentLifecycle.cleanupJob.schedule`](./values.yaml#L282) | Cleanup job schedule in cron format | `"13 * * * *"` |

### Asset storage

| Key | Description | Default |
|-----|-------------|---------|
| [`assetStorage`](./values.yaml#L299) | Everything about storing and caching assets |  |
| [`assetStorage.azure`](./values.yaml#L363) | Azure blob storage settings, in case `assetStorage.backendType` is set to `azure` | [...](./values.yaml#L363) |
| [`assetStorage.azure.container`](./values.yaml#L374) | `AZURE_STORAGE_DEFAULT_CONTAINER` | `""` |
| [`assetStorage.backendFallback`](./values.yaml#L311) | Asset storage fallback settings | [...](./values.yaml#L311) |
| [`assetStorage.backendFallback.enabled`](./values.yaml#L314) | `ENABLE_ASSET_STORAGE_FALLBACK` | `false` |
| [`assetStorage.backendFallback.enabledAzure`](./values.yaml#L323) | `ENABLE_ASSET_STORAGE_FALLBACK_AZURE` | `false` |
| [`assetStorage.backendFallback.enabledPostgres`](./values.yaml#L317) | `ENABLE_ASSET_STORAGE_FALLBACK_POSTGRES` | `false` |
| [`assetStorage.backendFallback.enabledS3`](./values.yaml#L320) | `ENABLE_ASSET_STORAGE_FALLBACK_S3` | `false` |
| [`assetStorage.backendType`](./values.yaml#L307) | Asset storage backend is only available if `database.enabled` is `true` Sets `ASSET_STORAGE_BACKEND`: `built-in`, `s3` or `azure` | `"built-in"` |
| [`assetStorage.localCacheSizeMegabytes`](./values.yaml#L303) | Sets local asset storage value in megabytes Results in `ASSET_STORAGE_CACHE_SIZE` (in bytes) | `2000` |
| [`assetStorage.redis`](./values.yaml#L392) | Redis settings for caching and prerendering | [...](./values.yaml#L392) |
| [`assetStorage.redis.database`](./values.yaml#L410) | `REDIS_DATABASE` | `""` |
| [`assetStorage.redis.enabled`](./values.yaml#L395) | `USE_REDIS_CACHE` | `false` |
| [`assetStorage.redis.externalSecretName`](./values.yaml#L447) | External secret name. Must contain `REDIS_USERNAME` and `REDIS_PASSWORD` if they are needed, and _may_ set other values | `""` |
| [`assetStorage.redis.host`](./values.yaml#L404) | `REDIS_HOST` | `"redis"` |
| [`assetStorage.redis.password`](./values.yaml#L436) | `REDIS_PASSWORD` | `""` |
| [`assetStorage.redis.port`](./values.yaml#L407) | `REDIS_PORT` | `6379` |
| [`assetStorage.redis.sentinel`](./values.yaml#L415) | Redis Sentinel | [...](./values.yaml#L415) |
| [`assetStorage.redis.tls`](./values.yaml#L440) | TLS settings |  |
| [`assetStorage.redis.tls.enabled`](./values.yaml#L443) | Enable TLS (`REDIS_SSL`) | `false` |
| [`assetStorage.redis.ttlSeconds`](./values.yaml#L398) | `REDIS_TTL` | `86400000` |
| [`assetStorage.redis.useTtl`](./values.yaml#L401) | `USE_REDIS_TTL_FOR_PRERENDERING` | `true` |
| [`assetStorage.redis.username`](./values.yaml#L433) | `REDIS_USERNAME` | `""` |
| [`assetStorage.s3`](./values.yaml#L327) | S3 backend storage settings, in case `assetStorage.backendType` is set to `s3 | [...](./values.yaml#L327) |
| [`assetStorage.s3.bucket`](./values.yaml#L338) | `ASSET_STORAGE_S3_BUCKET` | `"document-engine-assets"` |
| [`assetStorage.s3.region`](./values.yaml#L341) | `ASSET_STORAGE_S3_REGION` | `"us-east-1"` |

### Digital signatures

| Key | Description | Default |
|-----|-------------|---------|
| [`documentSigningService`](./values.yaml#L452) | Signing service parameters |  |
| [`documentSigningService.cadesLevel`](./values.yaml#L478) | `DIGITAL_SIGNATURE_CADES_LEVEL` | `"b-lt"` |
| [`documentSigningService.certificateCheckTime`](./values.yaml#L481) | `DIGITAL_SIGNATURE_CERTIFICATE_CHECK_TIME` | `"current_time"` |
| [`documentSigningService.defaultSignatureLocation`](./values.yaml#L472) | `DEFAULT_SIGNATURE_LOCATION` | `"Head Quarters"` |
| [`documentSigningService.defaultSignatureReason`](./values.yaml#L468) | `DEFAULT_SIGNATURE_REASON` | `"approved"` |
| [`documentSigningService.defaultSignerName`](./values.yaml#L464) | `DEFAULT_SIGNER_NAME` | `"John Doe"` |
| [`documentSigningService.enabled`](./values.yaml#L455) | Enable signing service integration | `false` |
| [`documentSigningService.hashAlgorithm`](./values.yaml#L475) | `DIGITAL_SIGNATURE_HASH_ALGORITHM` | `"sha512"` |
| [`documentSigningService.timeoutSeconds`](./values.yaml#L461) | `SIGNING_SERVICE_TIMEOUT` in seconds | `10` |
| [`documentSigningService.timestampAuthority`](./values.yaml#L485) | Timestamp Authority (TSA) settings | [...](./values.yaml#L485) |
| [`documentSigningService.timestampAuthority.url`](./values.yaml#L488) | `TIMESTAMP_AUTHORITY_URL` | `"https://freetsa.org/"` |
| [`documentSigningService.url`](./values.yaml#L458) | `SIGNING_SERVICE_URL` | `"https://signing-thing.local/sign"` |

### Dashboard

| Key | Description | Default |
|-----|-------------|---------|
| [`dashboard`](./values.yaml#L501) | Document Engine Dashboard settings |  |
| [`dashboard.auth`](./values.yaml#L508) | Dashboard authentication | [...](./values.yaml#L508) |
| [`dashboard.auth.externalSecret`](./values.yaml#L518) | Use an external secret for dashboard credentials | [...](./values.yaml#L518) |
| [`dashboard.auth.externalSecret.name`](./values.yaml#L521) | External secret name | `""` |
| [`dashboard.auth.externalSecret.passwordKey`](./values.yaml#L527) | Secret key name for the password | `"DASHBOARD_PASSWORD"` |
| [`dashboard.auth.externalSecret.usernameKey`](./values.yaml#L524) | Secret key name for the username | `"DASHBOARD_USERNAME"` |
| [`dashboard.auth.password`](./values.yaml#L514) | `DASHBOARD_PASSWORD` — will generate a random password if not set | `""` |
| [`dashboard.auth.username`](./values.yaml#L511) | `DASHBOARD_USERNAME` | `"admin"` |
| [`dashboard.enabled`](./values.yaml#L504) | Enable dashboard | `true` |

### Environment

| Key | Description | Default |
|-----|-------------|---------|
| [`extraEnvFrom`](./values.yaml#L693) | Extra environment variables from resources | `[]` |
| [`extraEnvs`](./values.yaml#L690) | Extra environment variables | `[]` |
| [`extraVolumeMounts`](./values.yaml#L699) | Additional volume mounts for Document Engine container | `[]` |
| [`extraVolumes`](./values.yaml#L696) | Additional volumes | `[]` |
| [`image`](./values.yaml#L650) | Image settings | [...](./values.yaml#L650) |
| [`imagePullSecrets`](./values.yaml#L657) | Pull secrets | `[]` |
| [`initContainers`](./values.yaml#L705) | Init containers | `[]` |
| [`podSecurityContext`](./values.yaml#L676) | Pod security context | `{}` |
| [`securityContext`](./values.yaml#L680) | Security context | `{}` |
| [`serviceAccount`](./values.yaml#L669) | ServiceAccount | [...](./values.yaml#L669) |
| [`sidecars`](./values.yaml#L702) | Additional containers | `[]` |

### Metadata

| Key | Description | Default |
|-----|-------------|---------|
| [`deploymentAnnotations`](./values.yaml#L715) | Deployment annotations | `{}` |
| [`fullnameOverride`](./values.yaml#L664) | Release full name override | `""` |
| [`nameOverride`](./values.yaml#L661) | Release name override | `""` |
| [`podAnnotations`](./values.yaml#L712) | Pod annotations | `{}` |
| [`podLabels`](./values.yaml#L709) | Pod labels | `{}` |

### Networking

| Key | Description | Default |
|-----|-------------|---------|
| [`extraIngresses`](./values.yaml#L766) | Additional ingresses, e.g. for the dashboard | [...](./values.yaml#L766) |
| [`ingress`](./values.yaml#L731) | Ingress | [...](./values.yaml#L731) |
| [`ingress.annotations`](./values.yaml#L740) | Ingress annotations | `{}` |
| [`ingress.className`](./values.yaml#L737) | Ingress class name | `""` |
| [`ingress.enabled`](./values.yaml#L734) | Enable ingress | `false` |
| [`ingress.hosts`](./values.yaml#L743) | Hosts | `[]` |
| [`ingress.tls`](./values.yaml#L757) | Ingress TLS section | `[]` |
| [`networkPolicy`](./values.yaml#L783) | [Network policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/) | [...](./values.yaml#L783) |
| [`networkPolicy.allowExternal`](./values.yaml#L791) | Allow access from anywhere | `true` |
| [`networkPolicy.allowExternalEgress`](./values.yaml#L815) | Allow the pod to access any range of port and all destinations. | `true` |
| [`networkPolicy.enabled`](./values.yaml#L786) | Enable network policy | `true` |
| [`networkPolicy.extraEgress`](./values.yaml#L818) | Extra egress rules | `[]` |
| [`networkPolicy.extraIngress`](./values.yaml#L794) | Additional ingress rules | `[]` |
| [`networkPolicy.ingressMatchSelectorLabels`](./values.yaml#L809) | Allow traffic from other namespaces | `[]` |
| [`service`](./values.yaml#L720) | Service | [...](./values.yaml#L720) |
| [`service.port`](./values.yaml#L726) | Service port — see also `config.port` | `5000` |
| [`service.type`](./values.yaml#L723) | Service type | `"ClusterIP"` |

### Observability

| Key | Description | Default |
|-----|-------------|---------|
| [`observability`](./values.yaml#L532) | Observability settings |  |
| [`observability.log`](./values.yaml#L536) | Logs | [...](./values.yaml#L536) |
| [`observability.log.healthcheckLevel`](./values.yaml#L542) | `HEALTHCHECK_LOGLEVEL` — log level for health checks | `"debug"` |
| [`observability.log.level`](./values.yaml#L539) | `LOG_LEVEL` | `"info"` |
| [`observability.metrics`](./values.yaml#L577) | Metrics configuration | [...](./values.yaml#L577) |
| [`observability.metrics.enabled`](./values.yaml#L580) | Enable metrics exporting | `false` |
| [`observability.metrics.prometheusRule`](./values.yaml#L618) | Prometheus [PrometheusRule](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.PrometheusRule) | [...](./values.yaml#L618) |
| [`observability.metrics.serviceMonitor`](./values.yaml#L604) | Prometheus [ServiceMonitor](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.ServiceMonitor) | [...](./values.yaml#L604) |
| [`observability.metrics.statsd`](./values.yaml#L584) | StatsD parameters | [...](./values.yaml#L584) |
| [`observability.metrics.statsd.customTags`](./values.yaml#L600) | StatsD custom tags, `STATSD_CUSTOM_TAGS` | *generated* |
| [`observability.metrics.statsd.port`](./values.yaml#L594) | StatsD port, `STATSD_PORT` | `9125` |
| [`observability.opentelemetry`](./values.yaml#L546) | OpenTelemetry settings | [...](./values.yaml#L546) |
| [`observability.opentelemetry.enabled`](./values.yaml#L549) | Enable OpenTelemetry (`ENABLE_OPENTELEMETRY`), only tracing is currently supported | `false` |
| [`observability.opentelemetry.otelPropagators`](./values.yaml#L565) | `OTEL_PROPAGATORS`, propagators | `""` |
| [`observability.opentelemetry.otelResourceAttributes`](./values.yaml#L562) | `OTEL_RESOURCE_ATTRIBUTES`, resource attributes | `""` |
| [`observability.opentelemetry.otelServiceName`](./values.yaml#L559) | `OTEL_SERVICE_NAME`, service name | `""` |
| [`observability.opentelemetry.otelTracesSampler`](./values.yaml#L570) | `OTEL_TRACES_SAMPLER`, should normally not be touched to allow custom `parent_based` work, but something like `parentbased_traceidratio` may be considered | `""` |
| [`observability.opentelemetry.otelTracesSamplerArg`](./values.yaml#L573) | `OTEL_TRACES_SAMPLER_ARG`, argument for the sampler | `""` |
| [`observability.opentelemetry.otlpExporterEndpoint`](./values.yaml#L553) | https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/ `OTEL_EXPORTER_OTLP_ENDPOINT`, if not set, defaults to `http://localhost:4317` | `""` |
| [`observability.opentelemetry.otlpExporterProtocol`](./values.yaml#L556) | `OTEL_EXPORTER_OTLP_PROTOCOL`, if not set, defaults to `grpc` | `""` |
| [`prometheusExporter`](./values.yaml#L628) | StatsD exporter for Prometheus, not recommended for production use Requires `observability.metrics.enabled` and `observability.metrics.statsd.enabled` | [...](./values.yaml#L628) |
| [`prometheusExporter.enabled`](./values.yaml#L631) | Enable the Prometheus exporter | `false` |
| [`prometheusExporter.port`](./values.yaml#L638) | Prometheus metrics port | `10254` |

### Pod lifecycle

| Key | Description | Default |
|-----|-------------|---------|
| [`lifecycle`](./values.yaml#L874) | [Lifecycle](https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/) | `{}` |
| [`livenessProbe`](./values.yaml#L848) | [Liveness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L848) |
| [`readinessProbe`](./values.yaml#L861) | [Readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L861) |
| [`startupProbe`](./values.yaml#L835) | [Startup probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L835) |

### Scheduling

| Key | Description | Default |
|-----|-------------|---------|
| [`affinity`](./values.yaml#L931) | Node affinity | `{}` |
| [`autoscaling`](./values.yaml#L882) | [Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) | [...](./values.yaml#L882) |
| [`nodeSelector`](./values.yaml#L928) | [Node selector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) | `{}` |
| [`podDisruptionBudget`](./values.yaml#L921) | [Pod disruption budget](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) | [...](./values.yaml#L921) |
| [`priorityClassName`](./values.yaml#L940) | [Priority classs](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/) | `""` |
| [`replicaCount`](./values.yaml#L911) | Number of replicas | `1` |
| [`resources`](./values.yaml#L908) | [Resources](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) | `{}` |
| [`schedulerName`](./values.yaml#L943) | [Scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/) | `""` |
| [`terminationGracePeriodSeconds`](./values.yaml#L946) | [Termination grace period](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/) | `nil` |
| [`tolerations`](./values.yaml#L934) | [Node tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) | `[]` |
| [`topologySpreadConstraints`](./values.yaml#L937) | [Topology spread constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) | `[]` |
| [`updateStrategy`](./values.yaml#L914) | [Update strategy](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy) | `{"rollingUpdate":{},"type":"RollingUpdate"}` |

### Chart dependencies

| Key | Description | Default |
|-----|-------------|---------|
| [`minio`](./values.yaml#L973) | [External MinIO chart](https://github.com/bitnami/charts/tree/main/bitnami/minio) | [...](./values.yaml#L973) |
| [`postgresql`](./values.yaml#L951) | [External PostgreSQL database chart](https://github.com/bitnami/charts/tree/main/bitnami/postgresql) | [...](./values.yaml#L951) |
| [`redis`](./values.yaml#L985) | [External Redis chart](https://github.com/bitnami/charts/tree/main/bitnami/redis) | [...](./values.yaml#L985) |

## Contribution

The chart is validated using [ct](https://github.com/helm/chart-testing/tree/main) [lint](https://github.com/helm/chart-testing/blob/main/doc/ct_lint.md):

```shell
ct lint --target-branch "$(git rev-parse --abbrev-ref HEAD)"
```

## License

This software is licensed under a [modified BSD license](LICENSE).

## Support, Issues and License Questions

PSPDFKit offers support via https://pspdfkit.com/support/request/

Are you [evaluating our SDK](https://pspdfkit.com/try/)? That's great, we're happy to help out! To make sure this is fast, please use a work email and have someone from your company fill out our sales form: https://pspdfkit.com/sales/

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)

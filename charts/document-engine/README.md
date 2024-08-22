# Document Engine Helm chart

![Version: 3.0.5](https://img.shields.io/badge/Version-3.0.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.4.1](https://img.shields.io/badge/AppVersion-1.4.1-informational?style=flat-square)

Document Engine is a backend software for processing documents and powering automation workflows.

**Homepage:** <https://pspdfkit.com/guides/document-engine/>

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
| https://charts.bitnami.com/bitnami | minio | 14.6.29 |
| https://charts.bitnami.com/bitnami | postgresql | 15.5.20 |
| https://charts.bitnami.com/bitnami | redis | 19.6.4 |

### Upgrade

> [!NOTE]
> Please consult the [changelog](/charts/document-engine/CHANGELOG.md)

## Values

### [Document Engine License](./values.yaml#L17)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [documentEngineLicense](./values.yaml#L17) | *object* |  | License information, see more in [our guide](https://pspdfkit.com/guides/document-engine/deployment/product-activation/) |
| [documentEngineLicense.activationKey](./values.yaml#L22) | *string* | `""` | Activation key for online activation (most common) or license key for offline activation. Results in `ACTIVATION_KEY` environment variable. |
| [documentEngineLicense.externalSecret](./values.yaml#L27) | *object* | [...](./values.yaml#L27) | Query existing secret for the activation key |

### [API authentication](./values.yaml#L40)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [apiAuth](./values.yaml#L40) | *object* |  | Document Enging API authentication |
| [apiAuth.apiToken](./values.yaml#L44) | *string* | `"secret"` | `API_AUTH_TOKEN`, a universal secret with full access to the API,  should be long enough |
| [apiAuth.externalSecret](./values.yaml#L70) | *object* | [...](./values.yaml#L70) | Use an external secret for API credentials |
| [apiAuth.jwt](./values.yaml#L48) | *object* | [...](./values.yaml#L48) | JSON Web Token (JWT) settings |
| [apiAuth.jwt.algorithm](./values.yaml#L59) | *string* | `"RS256"` | `JWT_ALGORITHM` Supported algorithms: `RS256`, `RS512`, `ES256`, `ES512`. See RFC 7518 for details about specific algorithms. |
| [apiAuth.jwt.enabled](./values.yaml#L51) | *bool* | `false` | Enable JWT |
| [apiAuth.jwt.publicKey](./values.yaml#L54) | *string* | `"none"` | `JWT_PUBLIC_KEY` |
| [apiAuth.secretKeyBase](./values.yaml#L65) | *string* | `""` | A string used as the base key for deriving secret keys for the purposes of authentication. Choose a sufficiently long random string for this option. To generate a random string, use: `openssl rand -hex 256`. This will set `SECRET_KEY_BASE` environment variable. |

### [Configuration options](./values.yaml#L100)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [config](./values.yaml#L100) | *object* |  | General configuration, [see more](https://pspdfkit.com/guides/document-engine/configuration/overview/) |
| [config.allowDocumentGeneration](./values.yaml#L133) | *bool* | `true` | `ALLOW_DOCUMENT_GENERATION` |
| [config.allowDocumentUploads](./values.yaml#L127) | *bool* | `true` | `ALLOW_DOCUMENT_UPLOADS` |
| [config.allowRemoteAssetsInGeneration](./values.yaml#L136) | *bool* | `true` | `ALLOW_REMOTE_ASSETS_IN_GENERATION` |
| [config.allowRemoteDocuments](./values.yaml#L130) | *bool* | `true` | `ALLOW_REMOTE_DOCUMENTS` |
| [config.asyncJobsTtlSeconds](./values.yaml#L124) | *int* | `172800` | `ASYNC_JOBS_TTL` |
| [config.automaticLinkExtraction](./values.yaml#L142) | *bool* | `false` | `AUTOMATIC_LINK_EXTRACTION` |
| [config.generationTimeoutSeconds](./values.yaml#L112) | *int* | `20` | `PDF_GENERATION_TIMEOUT` in seconds |
| [config.ignoreInvalidAnnotations](./values.yaml#L139) | *bool* | `true` | `IGNORE_INVALID_ANNOTATIONS` |
| [config.maxUploadSizeMegaBytes](./values.yaml#L121) | *int* | `950` | `MAX_UPLOAD_SIZE_BYTES` in megabytes |
| [config.minSearchQueryLength](./values.yaml#L145) | *int* | `3` | `MIN_SEARCH_QUERY_LENGTH` |
| [config.port](./values.yaml#L156) | *int* | `5000` | `PORT` for the Document Engine API |
| [config.proxy](./values.yaml#L151) | *object* | `{"http":"","https":""}` | Proxy settings, `HTTP_PROXY` amd `HTTPS_PROXY` |
| [config.readAnnotationBatchTimeoutSeconds](./values.yaml#L118) | *int* | `20` | `READ_ANNOTATION_BATCH_TIMEOUT` in seconds |
| [config.replaceSecretsFromEnv](./values.yaml#L161) | *bool* | `true` | `REPLACE_SECRETS_FROM_ENV` — whether to consider environment variables, values and secrets for `JWT_PUBLIC_KEY`, `SECRET_KEY_BASE` and `DASHBOARD_PASSWORD` |
| [config.requestTimeoutSeconds](./values.yaml#L106) | *int* | `60` | Full request timeout in seconds (`SERVER_REQUEST_TIMEOUT`) |
| [config.trustedProxies](./values.yaml#L148) | *string* | `"default"` | `TRUSTED_PROXIES` |
| [config.urlFetchTimeoutSeconds](./values.yaml#L115) | *int* | `5` | `REMOTE_URL_FETCH_TIMEOUT` in seconds |
| [config.workerPoolSize](./values.yaml#L103) | *int* | `16` | `PSPDFKIT_WORKER_POOL_SIZE` |
| [config.workerTimeoutSeconds](./values.yaml#L109) | *int* | `60` | Document processing timeout in seconds (`PSPDFKIT_WORKER_TIMEOUT`) |

### [Certificate trust](./values.yaml#L166)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [certificateTrust](./values.yaml#L166) | *object* |  | [Certificate trust](https://pspdfkit.com/guides/document-engine/configuration/certificate-trust/) |
| [certificateTrust.customCertificates](./values.yaml#L179) | *list* | `[]` | ConfigMap and Secret references for trust configuration, stored in `/certificate-stores-custom` |
| [certificateTrust.digitalSignatures](./values.yaml#L170) | *list* | `[]` | CAs for digital signatures (`/certificate-stores/`) from ConfigMap and Secret resources. |
| [certificateTrust.downloaderTrustFileName](./values.yaml#L189) | *string* | `""` | Override `DOWNLOADER_CERT_FILE_PATH` to set HTTP client trust. If empty, defaults to  Mozilla's CA bundle. |

### [Database](./values.yaml#L194)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [database](./values.yaml#L194) | *object* |  | Database |
| [database.connections](./values.yaml#L203) | *int* | `20` | `DATABASE_CONNECTIONS` |
| [database.enabled](./values.yaml#L197) | *bool* | `true` | Persistent storage enabled |
| [database.engine](./values.yaml#L200) | *string* | `"postgres"` | Database engine: only `postgres` is currently supported |
| [database.migrationJob](./values.yaml#L267) | *object* | [...](./values.yaml#L267) | Database migration jobs. |
| [database.migrationJob.enabled](./values.yaml#L270) | *bool* | `false` | It `true`, results in `ENABLE_DATABASE_MIGRATIONS=false` in the main Document Engine container |
| [database.postgres](./values.yaml#L208) | *object* | [...](./values.yaml#L208) | PostgreSQL database settings |
| [database.postgres.adminPassword](./values.yaml#L229) | *string* | `"despair"` | `PG_ADMIN_PASSWORD` |
| [database.postgres.adminUsername](./values.yaml#L226) | *string* | `"postgres"` | `PG_ADMIN_USER` |
| [database.postgres.database](./values.yaml#L217) | *string* | `"document-engine"` | `PGDATABASE` |
| [database.postgres.externalAdminSecretName](./values.yaml#L238) | *string* | `""` | External secret for administrative database credentials, used for migrations: `PG_ADMIN_USER` and `PG_ADMIN_PASSWORD` |
| [database.postgres.externalSecretName](./values.yaml#L234) | *string* | `""` | Use external secret for database credentials. `PGUSER` and `PGPASSWORD` must be provided and, if not defined: `PGDATABASE`, `PGHOST`, `PGPORT`, `PGSSL` |
| [database.postgres.host](./values.yaml#L211) | *string* | `"postgresql"` | `PGHOST` |
| [database.postgres.password](./values.yaml#L223) | *string* | `"despair"` | `PGPASSWORD` |
| [database.postgres.port](./values.yaml#L214) | *int* | `5432` | `PGPORT` |
| [database.postgres.tls](./values.yaml#L243) | *object* | [...](./values.yaml#L243) | TLS settings |
| [database.postgres.tls.commonName](./values.yaml#L256) | *string* | `""` | Common name for the certificate (`PGSSL_CERT_COMMON_NAME`), defaults to `PGHOST` value |
| [database.postgres.tls.enabled](./values.yaml#L246) | *bool* | `false` | Enable TLS (`PGSSL`) |
| [database.postgres.tls.hostVerify](./values.yaml#L252) | *bool* | `true` | Negated `PGSSL_DISABLE_HOSTNAME_VERIFY` |
| [database.postgres.tls.trustBundle](./values.yaml#L260) | *string* | `""` | Trust bundle for PostgreSQL, sets `PGSSL_CA_CERTS`, mutually exclusive with `trustFileName` and takes precedence |
| [database.postgres.tls.trustFileName](./values.yaml#L263) | *string* | `""` | Path from `certificateTrust.customCertificates`, wraps around `PGSSL_CA_CERT_PATH` |
| [database.postgres.tls.verify](./values.yaml#L249) | *bool* | `true` | Negated `PGSSL_DISABLE_VERIFY` |
| [database.postgres.username](./values.yaml#L220) | *string* | `"de-user"` | `PGUSER` |

### [Lifecycle](./values.yaml#L283)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [documentLifecycle](./values.yaml#L283) | *object* |  | Document lifecycle management |
| [documentLifecycle.cleanupJob](./values.yaml#L288) | *object* | [...](./values.yaml#L288) | Regular job to remove documents from the database. Note: currently only works with the `built-in` storage backend. |
| [documentLifecycle.cleanupJob.enabled](./values.yaml#L291) | *bool* | `false` | Enable the cleanup job |
| [documentLifecycle.cleanupJob.keepHours](./values.yaml#L297) | *int* | `24` | Documents TTL in hours |
| [documentLifecycle.cleanupJob.persistentLike](./values.yaml#L300) | *string* | `"persistent%"` | Keep documents with IDs beginning with `persistent` indefinitely |
| [documentLifecycle.cleanupJob.schedule](./values.yaml#L294) | *string* | `"13 * * * *"` | Cleanup job schedule in cron format |

### [Asset storage](./values.yaml#L311)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [assetStorage](./values.yaml#L311) | *object* |  | Everything about storing and caching assets |
| [assetStorage.azure](./values.yaml#L375) | *object* | [...](./values.yaml#L375) | Azure blob storage settings, in case `assetStorage.backendType` is set to `azure` |
| [assetStorage.azure.container](./values.yaml#L386) | *string* | `""` | `AZURE_STORAGE_DEFAULT_CONTAINER` |
| [assetStorage.backendFallback](./values.yaml#L323) | *object* | [...](./values.yaml#L323) | Asset storage fallback settings |
| [assetStorage.backendFallback.enabled](./values.yaml#L326) | *bool* | `false` | `ENABLE_ASSET_STORAGE_FALLBACK` |
| [assetStorage.backendFallback.enabledAzure](./values.yaml#L335) | *bool* | `false` | `ENABLE_ASSET_STORAGE_FALLBACK_AZURE` |
| [assetStorage.backendFallback.enabledPostgres](./values.yaml#L329) | *bool* | `false` | `ENABLE_ASSET_STORAGE_FALLBACK_POSTGRES` |
| [assetStorage.backendFallback.enabledS3](./values.yaml#L332) | *bool* | `false` | `ENABLE_ASSET_STORAGE_FALLBACK_S3` |
| [assetStorage.backendType](./values.yaml#L319) | *string* | `"built-in"` | Asset storage backend is only available if `database.enabled` is `true` Sets `ASSET_STORAGE_BACKEND`: `built-in`, `s3` or `azure` |
| [assetStorage.localCacheSizeMegabytes](./values.yaml#L315) | *int* | `2000` | Sets local asset storage value in megabytes Results in `ASSET_STORAGE_CACHE_SIZE` (in bytes) |
| [assetStorage.redis](./values.yaml#L404) | *object* | [...](./values.yaml#L404) | Redis settings for caching and prerendering |
| [assetStorage.redis.database](./values.yaml#L422) | *string* | `""` | `REDIS_DATABASE` |
| [assetStorage.redis.enabled](./values.yaml#L407) | *bool* | `false` | `USE_REDIS_CACHE` |
| [assetStorage.redis.externalSecretName](./values.yaml#L459) | *string* | `""` | External secret name. Must contain `REDIS_USERNAME` and `REDIS_PASSWORD` if they are needed, and _may_ set other values |
| [assetStorage.redis.host](./values.yaml#L416) | *string* | `"redis"` | `REDIS_HOST` |
| [assetStorage.redis.password](./values.yaml#L448) | *string* | `""` | `REDIS_PASSWORD` |
| [assetStorage.redis.port](./values.yaml#L419) | *int* | `6379` | `REDIS_PORT` |
| [assetStorage.redis.sentinel](./values.yaml#L427) | *object* | [...](./values.yaml#L427) | Redis Sentinel |
| [assetStorage.redis.tls](./values.yaml#L452) | *object* |  | TLS settings |
| [assetStorage.redis.tls.enabled](./values.yaml#L455) | *bool* | `false` | Enable TLS (`REDIS_SSL`) |
| [assetStorage.redis.ttlSeconds](./values.yaml#L410) | *int* | `86400000` | `REDIS_TTL` |
| [assetStorage.redis.useTtl](./values.yaml#L413) | *bool* | `true` | `USE_REDIS_TTL_FOR_PRERENDERING` |
| [assetStorage.redis.username](./values.yaml#L445) | *string* | `""` | `REDIS_USERNAME` |
| [assetStorage.s3](./values.yaml#L339) | *object* | [...](./values.yaml#L339) | S3 backend storage settings, in case `assetStorage.backendType` is set to `s3 |
| [assetStorage.s3.bucket](./values.yaml#L350) | *string* | `"document-engine-assets"` | `ASSET_STORAGE_S3_BUCKET` |
| [assetStorage.s3.region](./values.yaml#L353) | *string* | `"us-east-1"` | `ASSET_STORAGE_S3_REGION` |

### [Digital signatures](./values.yaml#L464)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [documentSigningService](./values.yaml#L464) | *object* |  | Signing service parameters |
| [documentSigningService.cadesLevel](./values.yaml#L490) | *string* | `"b-lt"` | `DIGITAL_SIGNATURE_CADES_LEVEL` |
| [documentSigningService.certificateCheckTime](./values.yaml#L493) | *string* | `"current_time"` | `DIGITAL_SIGNATURE_CERTIFICATE_CHECK_TIME` |
| [documentSigningService.defaultSignatureLocation](./values.yaml#L484) | *string* | `"Head Quarters"` | `DEFAULT_SIGNATURE_LOCATION` |
| [documentSigningService.defaultSignatureReason](./values.yaml#L480) | *string* | `"approved"` | `DEFAULT_SIGNATURE_REASON` |
| [documentSigningService.defaultSignerName](./values.yaml#L476) | *string* | `"John Doe"` | `DEFAULT_SIGNER_NAME` |
| [documentSigningService.enabled](./values.yaml#L467) | *bool* | `false` | Enable signing service integration |
| [documentSigningService.hashAlgorithm](./values.yaml#L487) | *string* | `"sha512"` | `DIGITAL_SIGNATURE_HASH_ALGORITHM` |
| [documentSigningService.timeoutSeconds](./values.yaml#L473) | *int* | `10` | `SIGNING_SERVICE_TIMEOUT` in seconds |
| [documentSigningService.timestampAuthority](./values.yaml#L497) | *object* | [...](./values.yaml#L497) | Timestamp Authority (TSA) settings |
| [documentSigningService.timestampAuthority.url](./values.yaml#L500) | *string* | `"https://freetsa.org/"` | `TIMESTAMP_AUTHORITY_URL` |
| [documentSigningService.url](./values.yaml#L470) | *string* | `"https://signing-thing.local/sign"` | `SIGNING_SERVICE_URL` |

### [Observability](./values.yaml#L513)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [observability](./values.yaml#L513) | *object* |  | Observability settings |
| [observability.log](./values.yaml#L517) | *object* | [...](./values.yaml#L517) | Logs |
| [observability.log.healthcheckLevel](./values.yaml#L523) | *string* | `"debug"` | `HEALTHCHECK_LOGLEVEL` — log level for health checks |
| [observability.log.level](./values.yaml#L520) | *string* | `"info"` | `LOG_LEVEL` |
| [observability.metrics](./values.yaml#L558) | *object* | [...](./values.yaml#L558) | Metrics configuration |
| [observability.metrics.enabled](./values.yaml#L561) | *bool* | `false` | Enable metrics exporting |
| [observability.metrics.prometheusRule](./values.yaml#L599) | *object* | [...](./values.yaml#L599) | Prometheus [PrometheusRule](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.PrometheusRule) |
| [observability.metrics.serviceMonitor](./values.yaml#L585) | *object* | [...](./values.yaml#L585) | Prometheus [ServiceMonitor](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.ServiceMonitor) |
| [observability.metrics.statsd](./values.yaml#L565) | *object* | [...](./values.yaml#L565) | StatsD parameters |
| [observability.metrics.statsd.customTags](./values.yaml#L581) | *tpl/string* | *generated* | StatsD custom tags, `STATSD_CUSTOM_TAGS` |
| [observability.metrics.statsd.port](./values.yaml#L575) | *int* | `9125` | StatsD port, `STATSD_PORT` |
| [observability.opentelemetry](./values.yaml#L527) | *object* | [...](./values.yaml#L527) | OpenTelemetry settings |
| [observability.opentelemetry.enabled](./values.yaml#L530) | *bool* | `false` | Enable OpenTelemetry (`ENABLE_OPENTELEMETRY`), only tracing is currently supported |
| [observability.opentelemetry.otelPropagators](./values.yaml#L546) | *string* | `""` | `OTEL_PROPAGATORS`, propagators |
| [observability.opentelemetry.otelResourceAttributes](./values.yaml#L543) | *string* | `""` | `OTEL_RESOURCE_ATTRIBUTES`, resource attributes |
| [observability.opentelemetry.otelServiceName](./values.yaml#L540) | *string* | `""` | `OTEL_SERVICE_NAME`, service name |
| [observability.opentelemetry.otelTracesSampler](./values.yaml#L551) | *string* | `""` | `OTEL_TRACES_SAMPLER`, should normally not be touched to allow custom `parent_based` work, but something like `parentbased_traceidratio` may be considered |
| [observability.opentelemetry.otelTracesSamplerArg](./values.yaml#L554) | *string* | `""` | `OTEL_TRACES_SAMPLER_ARG`, argument for the sampler |
| [observability.opentelemetry.otlpExporterEndpoint](./values.yaml#L534) | *string* | `""` | https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/ `OTEL_EXPORTER_OTLP_ENDPOINT`, if not set, defaults to `http://localhost:4317` |
| [observability.opentelemetry.otlpExporterProtocol](./values.yaml#L537) | *string* | `""` | `OTEL_EXPORTER_OTLP_PROTOCOL`, if not set, defaults to `grpc` |
| [prometheusExporter](./values.yaml#L609) | *object* | [...](./values.yaml#L609) | StatsD exporter for Prometheus, not recommended for production use Requires `observability.metrics.enabled` and `observability.metrics.statsd.enabled` |
| [prometheusExporter.enabled](./values.yaml#L612) | *bool* | `false` | Enable the Prometheus exporter |

### [Dashboard](./values.yaml#L629)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [dashboard](./values.yaml#L629) | *object* |  | Document Engine Dashboard settings |
| [dashboard.auth](./values.yaml#L636) | *object* | [...](./values.yaml#L636) | Dashboard authentication |
| [dashboard.auth.externalSecret](./values.yaml#L646) | *object* | [...](./values.yaml#L646) | Use an external secret for dashboard credentials |
| [dashboard.auth.externalSecret.name](./values.yaml#L649) | *string* | `""` | External secret name |
| [dashboard.auth.externalSecret.passwordKey](./values.yaml#L655) | *string* | `"DASHBOARD_PASSWORD"` | Secret key name for the password |
| [dashboard.auth.externalSecret.usernameKey](./values.yaml#L652) | *string* | `"DASHBOARD_USERNAME"` | Secret key name for the username |
| [dashboard.auth.password](./values.yaml#L642) | *string* | `""` | `DASHBOARD_PASSWORD` — will generate a random password if not set |
| [dashboard.auth.username](./values.yaml#L639) | *string* | `"admin"` | `DASHBOARD_USERNAME` |
| [dashboard.enabled](./values.yaml#L632) | *bool* | `true` | Enable dashboard |

### [Dependencies](./values.yaml#L943)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [minio](./values.yaml#L943) | *reference* | [...](./values.yaml#L943) | [External MinIO chart](https://github.com/bitnami/charts/tree/main/bitnami/minio) |
| [postgresql](./values.yaml#L921) | *reference* | [...](./values.yaml#L921) | [External PostgreSQL database chart](https://github.com/bitnami/charts/tree/main/bitnami/postgresql) |
| [redis](./values.yaml#L955) | *reference* | [...](./values.yaml#L955) | [External Redis chart](https://github.com/bitnami/charts/tree/main/bitnami/redis) |

### [Kubernetes metadata](./values.yaml#L713)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [deploymentAnnotations](./values.yaml#L713) | *object* | `{}` | Deployment annotations |
| [podAnnotations](./values.yaml#L710) | *object* | `{}` | Pod annotations |
| [podLabels](./values.yaml#L707) | *object* | `{}` | Pod labels |

### [Networking](./values.yaml#L742)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [extraIngresses](./values.yaml#L742) | *object* | `map[]` | Additional ingresses, e.g. for the dashboard |
| [ingress](./values.yaml#L718) | *object* | [...](./values.yaml#L718) | Ingress |
| [networkPolicy](./values.yaml#L759) | *object* | [...](./values.yaml#L759) | [Network policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/) |
| [service](./values.yaml#L660) | *object* | [...](./values.yaml#L660) | Service |

### [Pod environment](./values.yaml#L691)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [extraEnvFrom](./values.yaml#L691) | *list* | `[]` | Extra environment variables from resources |
| [extraEnvs](./values.yaml#L688) | *list* | `[]` | Extra environment variables |
| [extraVolumeMounts](./values.yaml#L697) | *list* | `[]` | Additional volume mounts for Document Engine container |
| [extraVolumes](./values.yaml#L694) | *list* | `[]` | Additional volumes |
| [initContainers](./values.yaml#L703) | *list* | `[]` | Init containers |
| [podSecurityContext](./values.yaml#L674) | *object* | `{}` | Pod security context |
| [securityContext](./values.yaml#L678) | *object* | `{}` | Security context |
| [serviceAccount](./values.yaml#L667) | *object* | [...](./values.yaml#L667) | ServiceAccount |
| [sidecars](./values.yaml#L700) | *list* | `[]` | Additional containers |

### [Pod lifecycle](./values.yaml#L844)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [lifecycle](./values.yaml#L844) | *object* | `{}` | [Lifecycle](https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/) |
| [livenessProbe](./values.yaml#L818) | *object* | [...](./values.yaml#L818) | [Liveness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) |
| [readinessProbe](./values.yaml#L831) | *object* | [...](./values.yaml#L831) | [Readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) |
| [startupProbe](./values.yaml#L805) | *object* | [...](./values.yaml#L805) | [Startup probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) |

### [Scheduling](./values.yaml#L901)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [affinity](./values.yaml#L901) | *object* | `{}` | Node affinity |
| [autoscaling](./values.yaml#L852) | *object* | [...](./values.yaml#L852) | [Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) |
| [nodeSelector](./values.yaml#L898) | *object* | `{}` | [Node selector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) |
| [podDisruptionBudget](./values.yaml#L891) | *object* | [...](./values.yaml#L891) | [Pod disruption budget](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) |
| [priorityClassName](./values.yaml#L910) | *string* | `""` | [Priority classs](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/) |
| [replicaCount](./values.yaml#L881) | *int* | `1` | Number of replicas |
| [resources](./values.yaml#L878) | *object* | `{}` | [Resources](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| [schedulerName](./values.yaml#L913) | *string* | `""` | [Scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/) |
| [terminationGracePeriodSeconds](./values.yaml#L916) | *string* | `""` | [Termination grace period](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/) |
| [tolerations](./values.yaml#L904) | *list* | `[]` | [Node tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) |
| [topologySpreadConstraints](./values.yaml#L907) | *list* | `[]` | [Topology spread constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) |
| [updateStrategy](./values.yaml#L884) | *object* | `{"rollingUpdate":{},"type":"RollingUpdate"}` | [Update strategy](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy) |

### Other Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [fullnameOverride](./values.yaml#L11) | *string* | `""` |  |
| [image](./values.yaml#L3) | *object* |  | Image settings |
| [imagePullSecrets](./values.yaml#L9) | *list* | `[]` | Pull secrets |
| [nameOverride](./values.yaml#L10) | *string* | `""` |  |

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

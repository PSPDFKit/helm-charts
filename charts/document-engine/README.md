# Document Engine Helm chart

![Version: 3.0.4](https://img.shields.io/badge/Version-3.0.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.4.1](https://img.shields.io/badge/AppVersion-1.4.1-informational?style=flat-square)

Document Engine is a backend software for processing documents and powering automation workflows.

**Homepage:** <https://pspdfkit.com/guides/document-engine/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| PSPDFKit | <support@pspdfkit.com> | <https://pspdfkit.com> |

## Using this chart

### Adding the repository

```
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

### [Observability settings](./values.yaml#L562)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [observability.metrics.enabled](./values.yaml#L562) | *bool* | `false` | Enable metrics exporting |
| [observability.metrics.statsd](./values.yaml#L567) | *plain* | *See below* | StatsD parameters |
| [observability.metrics.statsd.customTags](./values.yaml#L583) | *tpl/string* | *generated* | StatsD custom tags, `STATSD_CUSTOM_TAGS` |
| [observability.metrics.statsd.port](./values.yaml#L577) | *int* | `9125` | StatsD port, `STATSD_PORT` |

### Other Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [affinity](./values.yaml#L800) | *object* | `{}` |  |
| [autoscaling.behavior](./values.yaml#L776) | *object* | `{}` |  |
| [autoscaling.enabled](./values.yaml#L771) | *bool* | `false` |  |
| [autoscaling.maxReplicas](./values.yaml#L773) | *int* | `100` |  |
| [autoscaling.minReplicas](./values.yaml#L772) | *int* | `1` |  |
| [autoscaling.targetCPUUtilizationPercentage](./values.yaml#L774) | *int* | `80` |  |
| [autoscaling.targetMemoryUtilizationPercentage](./values.yaml#L775) | *int* | `80` |  |
| [dashboard](./values.yaml#L511) | *object* | `{"auth":{"externalSecret":{"name":"","passwordKey":"DASHBOARD_PASSWORD","usernameKey":"DASHBOARD_USERNAME"},"password":"","username":"admin"},"enabled":true}` | Document Engine Dashboard settings |
| [dashboard.auth](./values.yaml#L515) | *object* | `{"externalSecret":{"name":"","passwordKey":"DASHBOARD_PASSWORD","usernameKey":"DASHBOARD_USERNAME"},"password":"","username":"admin"}` | Dashboard authentication |
| [dashboard.auth.externalSecret](./values.yaml#L522) | *object* | `{"name":"","passwordKey":"DASHBOARD_PASSWORD","usernameKey":"DASHBOARD_USERNAME"}` | instead of the values from `pspdfkit.auth.dashboard.*` |
| [dashboard.auth.externalSecret.name](./values.yaml#L524) | *string* | `""` | External secret name |
| [dashboard.auth.externalSecret.usernameKey](./values.yaml#L526) | *string* | `"DASHBOARD_USERNAME"` | Key names |
| [dashboard.auth.password](./values.yaml#L519) | *string* | `""` | `DASHBOARD_PASSWORD` — will generate a random password if not set |
| [dashboard.auth.username](./values.yaml#L517) | *string* | `"admin"` | `DASHBOARD_USERNAME` |
| [dashboard.enabled](./values.yaml#L513) | *bool* | `true` | Enable dashboard |
| [deploymentAnnotations](./values.yaml#L631) | *object* | `{}` |  |
| [extraEnvFrom](./values.yaml#L733) | *list* | `[]` |  |
| [extraEnvs](./values.yaml#L732) | *list* | `[]` |  |
| [extraIngresses](./values.yaml#L665) | *object* | `{}` |  |
| [extraVolumeMounts](./values.yaml#L735) | *list* | `[]` |  |
| [extraVolumes](./values.yaml#L734) | *list* | `[]` |  |
| [fullnameOverride](./values.yaml#L11) | *string* | `""` |  |
| [image](./values.yaml#L3) | *object* |  | Image settings |
| [imagePullSecrets](./values.yaml#L9) | *list* | `[]` | Pull secrets |
| [ingress.annotations](./values.yaml#L646) | *object* | `{}` |  |
| [ingress.className](./values.yaml#L645) | *string* | `""` |  |
| [ingress.enabled](./values.yaml#L644) | *bool* | `false` |  |
| [ingress.hosts](./values.yaml#L647) | *list* | `[]` |  |
| [ingress.tls](./values.yaml#L659) | *list* | `[]` |  |
| [initContainers](./values.yaml#L737) | *list* | `[]` |  |
| [lifecycle](./values.yaml#L812) | *object* | `{}` |  |
| [livenessProbe.failureThreshold](./values.yaml#L758) | *int* | `3` |  |
| [livenessProbe.httpGet.path](./values.yaml#L751) | *string* | `"/healthcheck"` |  |
| [livenessProbe.httpGet.port](./values.yaml#L752) | *string* | `"api"` |  |
| [livenessProbe.httpGet.scheme](./values.yaml#L753) | *string* | `"HTTP"` |  |
| [livenessProbe.initialDelaySeconds](./values.yaml#L754) | *int* | `0` |  |
| [livenessProbe.periodSeconds](./values.yaml#L755) | *int* | `30` |  |
| [livenessProbe.successThreshold](./values.yaml#L757) | *int* | `1` |  |
| [livenessProbe.timeoutSeconds](./values.yaml#L756) | *int* | `1` |  |
| [minio](./values.yaml#L842) | *plain* | *See below* | [External MinIO chart](https://github.com/bitnami/charts/tree/main/bitnami/minio) |
| [nameOverride](./values.yaml#L10) | *string* | `""` |  |
| [networkPolicy.allowExternal](./values.yaml#L685) | *bool* | `true` |  |
| [networkPolicy.allowExternalEgress](./values.yaml#L707) | *bool* | `true` |  |
| [networkPolicy.annotations](./values.yaml#L683) | *object* | `{}` |  |
| [networkPolicy.enabled](./values.yaml#L681) | *bool* | `true` |  |
| [networkPolicy.extraEgress](./values.yaml#L709) | *list* | `[]` |  |
| [networkPolicy.extraIngress](./values.yaml#L687) | *list* | `[]` |  |
| [networkPolicy.ingressMatchSelectorLabels](./values.yaml#L702) | *list* | `[]` |  |
| [networkPolicy.labels](./values.yaml#L682) | *object* | `{}` |  |
| [nodeSelector](./values.yaml#L799) | *object* | `{}` |  |
| [observability](./values.yaml#L530) | *object* | `{"log":{"healthcheckLevel":"debug","level":"info"},"metrics":{"enabled":false,"prometheusRule":{"enabled":false,"labels":{},"namespace":"","rules":[]},"serviceMonitor":{"enabled":false,"honorLabels":false,"interval":"30s","jobLabel":"","labels":{},"metricRelabelings":[],"namespace":"","relabelings":[],"scrapeTimeout":""},"statsd":{"customTags":"namespace={{ .Release.Namespace }},app={{ include \"document-engine.fullname\" . }}","enabled":false,"host":"localhost","port":9125}},"opentelemetry":{"enabled":false,"otelPropagators":"","otelResourceAttributes":"","otelServiceName":"","otelTracesSampler":"","otelTracesSamplerArg":"","otlpExporterEndpoint":"","otlpExporterProtocol":""}}` | Observability settings |
| [observability.log](./values.yaml#L532) | *object* | `{"healthcheckLevel":"debug","level":"info"}` | Logs |
| [observability.log.healthcheckLevel](./values.yaml#L536) | *string* | `"debug"` | `HEALTHCHECK_LOGLEVEL` — log level for health checks |
| [observability.log.level](./values.yaml#L534) | *string* | `"info"` | `LOG_LEVEL` |
| [observability.metrics](./values.yaml#L559) | *object* | `{"enabled":false,"prometheusRule":{"enabled":false,"labels":{},"namespace":"","rules":[]},"serviceMonitor":{"enabled":false,"honorLabels":false,"interval":"30s","jobLabel":"","labels":{},"metricRelabelings":[],"namespace":"","relabelings":[],"scrapeTimeout":""},"statsd":{"customTags":"namespace={{ .Release.Namespace }},app={{ include \"document-engine.fullname\" . }}","enabled":false,"host":"localhost","port":9125}}` | Metrics configuration |
| [observability.opentelemetry](./values.yaml#L538) | *object* | `{"enabled":false,"otelPropagators":"","otelResourceAttributes":"","otelServiceName":"","otelTracesSampler":"","otelTracesSamplerArg":"","otlpExporterEndpoint":"","otlpExporterProtocol":""}` | OpenTelemetry |
| [observability.opentelemetry.enabled](./values.yaml#L540) | *bool* | `false` | Enable OpenTelemetry (`ENABLE_OPENTELEMETRY`), only tracing is currently supported |
| [observability.opentelemetry.otelPropagators](./values.yaml#L551) | *string* | `""` | `OTEL_PROPAGATORS`, propagators |
| [observability.opentelemetry.otelResourceAttributes](./values.yaml#L549) | *string* | `""` | `OTEL_RESOURCE_ATTRIBUTES`, resource attributes |
| [observability.opentelemetry.otelServiceName](./values.yaml#L547) | *string* | `""` | `OTEL_SERVICE_NAME`, service name |
| [observability.opentelemetry.otelTracesSampler](./values.yaml#L555) | *string* | `""` | `OTEL_TRACES_SAMPLER`, should normally not be touched to allow custom `parent_based` work, but something like `parentbased_traceidratio` may be considered |
| [observability.opentelemetry.otelTracesSamplerArg](./values.yaml#L557) | *string* | `""` | `OTEL_TRACES_SAMPLER_ARG`, argument for the sampler |
| [observability.opentelemetry.otlpExporterEndpoint](./values.yaml#L543) | *string* | `""` | https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/ `OTEL_EXPORTER_OTLP_ENDPOINT`, if not set, defaults to `http://localhost:4317` |
| [observability.opentelemetry.otlpExporterProtocol](./values.yaml#L545) | *string* | `""` | `OTEL_EXPORTER_OTLP_PROTOCOL`, if not set, defaults to `grpc` |
| [podAnnotations](./values.yaml#L630) | *object* | `{}` |  |
| [podDisruptionBudget.create](./values.yaml#L795) | *bool* | `false` |  |
| [podDisruptionBudget.maxUnavailable](./values.yaml#L797) | *string* | `""` |  |
| [podDisruptionBudget.minAvailable](./values.yaml#L796) | *int* | `1` |  |
| [podLabels](./values.yaml#L629) | *object* | `{}` |  |
| [podSecurityContext](./values.yaml#L632) | *object* | `{}` |  |
| [postgresql](./values.yaml#L820) | *plain* | *See below* | [External PostgreSQL database chart](https://github.com/bitnami/charts/tree/main/bitnami/postgresql) |
| [priorityClassName](./values.yaml#L806) | *string* | `""` |  |
| [prometheusExporter.enabled](./values.yaml#L606) | *bool* | `false` |  |
| [prometheusExporter.image.pullPolicy](./values.yaml#L609) | *string* | `"IfNotPresent"` |  |
| [prometheusExporter.image.repository](./values.yaml#L608) | *string* | `"prom/statsd-exporter"` |  |
| [prometheusExporter.image.tag](./values.yaml#L610) | *string* | `"v0.27.1"` |  |
| [prometheusExporter.port](./values.yaml#L611) | *int* | `10254` |  |
| [prometheusExporter.resources.limits.cpu](./values.yaml#L618) | *string* | `"100m"` |  |
| [prometheusExporter.resources.limits.memory](./values.yaml#L617) | *string* | `"128Mi"` |  |
| [prometheusExporter.resources.requests.cpu](./values.yaml#L615) | *string* | `"50m"` |  |
| [prometheusExporter.resources.requests.memory](./values.yaml#L614) | *string* | `"32Mi"` |  |
| [readinessProbe.failureThreshold](./values.yaml#L768) | *int* | `3` |  |
| [readinessProbe.httpGet.path](./values.yaml#L761) | *string* | `"/healthcheck"` |  |
| [readinessProbe.httpGet.port](./values.yaml#L762) | *string* | `"api"` |  |
| [readinessProbe.httpGet.scheme](./values.yaml#L763) | *string* | `"HTTP"` |  |
| [readinessProbe.initialDelaySeconds](./values.yaml#L764) | *int* | `0` |  |
| [readinessProbe.periodSeconds](./values.yaml#L765) | *int* | `5` |  |
| [readinessProbe.successThreshold](./values.yaml#L767) | *int* | `1` |  |
| [readinessProbe.timeoutSeconds](./values.yaml#L766) | *int* | `1` |  |
| [redis](./values.yaml#L852) | *object* | `{"architecture":"standalone","auth":{"enabled":true,"password":"","sentinel":false},"enabled":false}` | [External Redis chart](https://github.com/bitnami/charts/tree/main/bitnami/redis) |
| [replicaCount](./values.yaml#L726) | *int* | `1` |  |
| [resources](./values.yaml#L724) | *object* | `{}` |  |
| [schedulerName](./values.yaml#L808) | *string* | `""` |  |
| [securityContext](./values.yaml#L635) | *object* | `{}` |  |
| [service.port](./values.yaml#L623) | *int* | `5000` |  |
| [service.type](./values.yaml#L622) | *string* | `"ClusterIP"` |  |
| [serviceAccount.annotations](./values.yaml#L627) | *object* | `{}` |  |
| [serviceAccount.create](./values.yaml#L626) | *bool* | `true` |  |
| [serviceAccount.name](./values.yaml#L628) | *string* | `""` |  |
| [sidecars](./values.yaml#L736) | *list* | `[]` |  |
| [startupProbe.failureThreshold](./values.yaml#L748) | *int* | `5` |  |
| [startupProbe.httpGet.path](./values.yaml#L741) | *string* | `"/healthcheck"` |  |
| [startupProbe.httpGet.port](./values.yaml#L742) | *string* | `"api"` |  |
| [startupProbe.httpGet.scheme](./values.yaml#L743) | *string* | `"HTTP"` |  |
| [startupProbe.initialDelaySeconds](./values.yaml#L744) | *int* | `5` |  |
| [startupProbe.periodSeconds](./values.yaml#L745) | *int* | `5` |  |
| [startupProbe.successThreshold](./values.yaml#L747) | *int* | `1` |  |
| [startupProbe.timeoutSeconds](./values.yaml#L746) | *int* | `1` |  |
| [terminationGracePeriodSeconds](./values.yaml#L810) | *string* | `""` |  |
| [tolerations](./values.yaml#L802) | *list* | `[]` |  |
| [topologySpreadConstraints](./values.yaml#L804) | *list* | `[]` |  |
| [updateStrategy.rollingUpdate](./values.yaml#L730) | *object* | `{}` |  |
| [updateStrategy.type](./values.yaml#L729) | *string* | `"RollingUpdate"` |  |

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

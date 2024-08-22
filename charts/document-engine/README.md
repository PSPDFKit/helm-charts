# Document Engine Helm chart

![Version: 3.0.6](https://img.shields.io/badge/Version-3.0.6-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.4.1](https://img.shields.io/badge/AppVersion-1.4.1-informational?style=flat-square)

Document Engine is a backend software for processing documents and powering automation workflows.

**Homepage:** <https://pspdfkit.com/guides/document-engine/>

* [Using this chart](#using-this-chart)
* [Values](#values)
  * [Document Engine License](#document-engine-license)
  * [API authentication](#api-authentication)
  * [Configuration options](#configuration-options)
  * [Certificate trust](#certificate-trust)
  * [Database](#database)
  * [Lifecycle](#lifecycle)
  * [Asset storage](#asset-storage)
  * [Digital signatures](#digital-signatures)
  * [Dashboard](#dashboard)
  * [Environment](#environment)
  * [Metadata](#metadata)
  * [Networking](#networking)
  * [Observability](#observability)
  * [Lifecycle](#lifecycle)
  * [Scheduling](#scheduling)
  * [Dependencies](#dependencies)
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
| https://charts.bitnami.com/bitnami | minio | 14.6.29 |
| https://charts.bitnami.com/bitnami | postgresql | 15.5.20 |
| https://charts.bitnami.com/bitnami | redis | 19.6.4 |

### Upgrade

> [!NOTE]
> Please consult the [changelog](/charts/document-engine/CHANGELOG.md)

## Values

### [Document Engine License](./values.yaml#L5)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [documentEngineLicense](./values.yaml#L5) | *object* |  | License information, see more in [our guide](https://pspdfkit.com/guides/document-engine/deployment/product-activation/) |
| [documentEngineLicense.activationKey](./values.yaml#L10) | *string* | `""` | Activation key for online activation (most common) or license key for offline activation. Results in `ACTIVATION_KEY` environment variable. |
| [documentEngineLicense.externalSecret](./values.yaml#L15) | *object* | [...](./values.yaml#L15) | Query existing secret for the activation key |

### [API authentication](./values.yaml#L28)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [apiAuth](./values.yaml#L28) | *object* |  | Document Enging API authentication |
| [apiAuth.apiToken](./values.yaml#L32) | *string* | `"secret"` | `API_AUTH_TOKEN`, a universal secret with full access to the API,  should be long enough |
| [apiAuth.externalSecret](./values.yaml#L58) | *object* | [...](./values.yaml#L58) | Use an external secret for API credentials |
| [apiAuth.jwt](./values.yaml#L36) | *object* | [...](./values.yaml#L36) | JSON Web Token (JWT) settings |
| [apiAuth.jwt.algorithm](./values.yaml#L47) | *string* | `"RS256"` | `JWT_ALGORITHM` Supported algorithms: `RS256`, `RS512`, `ES256`, `ES512`. See RFC 7518 for details about specific algorithms. |
| [apiAuth.jwt.enabled](./values.yaml#L39) | *bool* | `false` | Enable JWT |
| [apiAuth.jwt.publicKey](./values.yaml#L42) | *string* | `"none"` | `JWT_PUBLIC_KEY` |
| [apiAuth.secretKeyBase](./values.yaml#L53) | *string* | `""` | A string used as the base key for deriving secret keys for the purposes of authentication. Choose a sufficiently long random string for this option. To generate a random string, use: `openssl rand -hex 256`. This will set `SECRET_KEY_BASE` environment variable. |

### [Configuration options](./values.yaml#L88)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [config](./values.yaml#L88) | *object* |  | General configuration, [see more](https://pspdfkit.com/guides/document-engine/configuration/overview/) |
| [config.allowDocumentGeneration](./values.yaml#L121) | *bool* | `true` | `ALLOW_DOCUMENT_GENERATION` |
| [config.allowDocumentUploads](./values.yaml#L115) | *bool* | `true` | `ALLOW_DOCUMENT_UPLOADS` |
| [config.allowRemoteAssetsInGeneration](./values.yaml#L124) | *bool* | `true` | `ALLOW_REMOTE_ASSETS_IN_GENERATION` |
| [config.allowRemoteDocuments](./values.yaml#L118) | *bool* | `true` | `ALLOW_REMOTE_DOCUMENTS` |
| [config.asyncJobsTtlSeconds](./values.yaml#L112) | *int* | `172800` | `ASYNC_JOBS_TTL` |
| [config.automaticLinkExtraction](./values.yaml#L130) | *bool* | `false` | `AUTOMATIC_LINK_EXTRACTION` |
| [config.generationTimeoutSeconds](./values.yaml#L100) | *int* | `20` | `PDF_GENERATION_TIMEOUT` in seconds |
| [config.ignoreInvalidAnnotations](./values.yaml#L127) | *bool* | `true` | `IGNORE_INVALID_ANNOTATIONS` |
| [config.maxUploadSizeMegaBytes](./values.yaml#L109) | *int* | `950` | `MAX_UPLOAD_SIZE_BYTES` in megabytes |
| [config.minSearchQueryLength](./values.yaml#L133) | *int* | `3` | `MIN_SEARCH_QUERY_LENGTH` |
| [config.port](./values.yaml#L144) | *int* | `5000` | `PORT` for the Document Engine API |
| [config.proxy](./values.yaml#L139) | *object* | `{"http":"","https":""}` | Proxy settings, `HTTP_PROXY` amd `HTTPS_PROXY` |
| [config.readAnnotationBatchTimeoutSeconds](./values.yaml#L106) | *int* | `20` | `READ_ANNOTATION_BATCH_TIMEOUT` in seconds |
| [config.replaceSecretsFromEnv](./values.yaml#L149) | *bool* | `true` | `REPLACE_SECRETS_FROM_ENV` — whether to consider environment variables, values and secrets for `JWT_PUBLIC_KEY`, `SECRET_KEY_BASE` and `DASHBOARD_PASSWORD` |
| [config.requestTimeoutSeconds](./values.yaml#L94) | *int* | `60` | Full request timeout in seconds (`SERVER_REQUEST_TIMEOUT`) |
| [config.trustedProxies](./values.yaml#L136) | *string* | `"default"` | `TRUSTED_PROXIES` |
| [config.urlFetchTimeoutSeconds](./values.yaml#L103) | *int* | `5` | `REMOTE_URL_FETCH_TIMEOUT` in seconds |
| [config.workerPoolSize](./values.yaml#L91) | *int* | `16` | `PSPDFKIT_WORKER_POOL_SIZE` |
| [config.workerTimeoutSeconds](./values.yaml#L97) | *int* | `60` | Document processing timeout in seconds (`PSPDFKIT_WORKER_TIMEOUT`) |

### [Certificate trust](./values.yaml#L154)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [certificateTrust](./values.yaml#L154) | *object* |  | [Certificate trust](https://pspdfkit.com/guides/document-engine/configuration/certificate-trust/) |
| [certificateTrust.customCertificates](./values.yaml#L167) | *list* | `[]` | ConfigMap and Secret references for trust configuration, stored in `/certificate-stores-custom` |
| [certificateTrust.digitalSignatures](./values.yaml#L158) | *list* | `[]` | CAs for digital signatures (`/certificate-stores/`) from ConfigMap and Secret resources. |
| [certificateTrust.downloaderTrustFileName](./values.yaml#L177) | *string* | `""` | Override `DOWNLOADER_CERT_FILE_PATH` to set HTTP client trust. If empty, defaults to  Mozilla's CA bundle. |

### [Database](./values.yaml#L182)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [database](./values.yaml#L182) | *object* |  | Database |
| [database.connections](./values.yaml#L191) | *int* | `20` | `DATABASE_CONNECTIONS` |
| [database.enabled](./values.yaml#L185) | *bool* | `true` | Persistent storage enabled |
| [database.engine](./values.yaml#L188) | *string* | `"postgres"` | Database engine: only `postgres` is currently supported |
| [database.migrationJob](./values.yaml#L255) | *object* | [...](./values.yaml#L255) | Database migration jobs. |
| [database.migrationJob.enabled](./values.yaml#L258) | *bool* | `false` | It `true`, results in `ENABLE_DATABASE_MIGRATIONS=false` in the main Document Engine container |
| [database.postgres](./values.yaml#L196) | *object* | [...](./values.yaml#L196) | PostgreSQL database settings |
| [database.postgres.adminPassword](./values.yaml#L217) | *string* | `"despair"` | `PG_ADMIN_PASSWORD` |
| [database.postgres.adminUsername](./values.yaml#L214) | *string* | `"postgres"` | `PG_ADMIN_USER` |
| [database.postgres.database](./values.yaml#L205) | *string* | `"document-engine"` | `PGDATABASE` |
| [database.postgres.externalAdminSecretName](./values.yaml#L226) | *string* | `""` | External secret for administrative database credentials, used for migrations: `PG_ADMIN_USER` and `PG_ADMIN_PASSWORD` |
| [database.postgres.externalSecretName](./values.yaml#L222) | *string* | `""` | Use external secret for database credentials. `PGUSER` and `PGPASSWORD` must be provided and, if not defined: `PGDATABASE`, `PGHOST`, `PGPORT`, `PGSSL` |
| [database.postgres.host](./values.yaml#L199) | *string* | `"postgresql"` | `PGHOST` |
| [database.postgres.password](./values.yaml#L211) | *string* | `"despair"` | `PGPASSWORD` |
| [database.postgres.port](./values.yaml#L202) | *int* | `5432` | `PGPORT` |
| [database.postgres.tls](./values.yaml#L231) | *object* | [...](./values.yaml#L231) | TLS settings |
| [database.postgres.tls.commonName](./values.yaml#L244) | *string* | `""` | Common name for the certificate (`PGSSL_CERT_COMMON_NAME`), defaults to `PGHOST` value |
| [database.postgres.tls.enabled](./values.yaml#L234) | *bool* | `false` | Enable TLS (`PGSSL`) |
| [database.postgres.tls.hostVerify](./values.yaml#L240) | *bool* | `true` | Negated `PGSSL_DISABLE_HOSTNAME_VERIFY` |
| [database.postgres.tls.trustBundle](./values.yaml#L248) | *string* | `""` | Trust bundle for PostgreSQL, sets `PGSSL_CA_CERTS`, mutually exclusive with `trustFileName` and takes precedence |
| [database.postgres.tls.trustFileName](./values.yaml#L251) | *string* | `""` | Path from `certificateTrust.customCertificates`, wraps around `PGSSL_CA_CERT_PATH` |
| [database.postgres.tls.verify](./values.yaml#L237) | *bool* | `true` | Negated `PGSSL_DISABLE_VERIFY` |
| [database.postgres.username](./values.yaml#L208) | *string* | `"de-user"` | `PGUSER` |

### [Lifecycle](./values.yaml#L271)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [documentLifecycle](./values.yaml#L271) | *object* |  | Document lifecycle management |
| [documentLifecycle.cleanupJob](./values.yaml#L276) | *object* | [...](./values.yaml#L276) | Regular job to remove documents from the database. Note: currently only works with the `built-in` storage backend. |
| [documentLifecycle.cleanupJob.enabled](./values.yaml#L279) | *bool* | `false` | Enable the cleanup job |
| [documentLifecycle.cleanupJob.keepHours](./values.yaml#L285) | *int* | `24` | Documents TTL in hours |
| [documentLifecycle.cleanupJob.persistentLike](./values.yaml#L288) | *string* | `"persistent%"` | Keep documents with IDs beginning with `persistent` indefinitely |
| [documentLifecycle.cleanupJob.schedule](./values.yaml#L282) | *string* | `"13 * * * *"` | Cleanup job schedule in cron format |

### [Asset storage](./values.yaml#L299)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [assetStorage](./values.yaml#L299) | *object* |  | Everything about storing and caching assets |
| [assetStorage.azure](./values.yaml#L363) | *object* | [...](./values.yaml#L363) | Azure blob storage settings, in case `assetStorage.backendType` is set to `azure` |
| [assetStorage.azure.container](./values.yaml#L374) | *string* | `""` | `AZURE_STORAGE_DEFAULT_CONTAINER` |
| [assetStorage.backendFallback](./values.yaml#L311) | *object* | [...](./values.yaml#L311) | Asset storage fallback settings |
| [assetStorage.backendFallback.enabled](./values.yaml#L314) | *bool* | `false` | `ENABLE_ASSET_STORAGE_FALLBACK` |
| [assetStorage.backendFallback.enabledAzure](./values.yaml#L323) | *bool* | `false` | `ENABLE_ASSET_STORAGE_FALLBACK_AZURE` |
| [assetStorage.backendFallback.enabledPostgres](./values.yaml#L317) | *bool* | `false` | `ENABLE_ASSET_STORAGE_FALLBACK_POSTGRES` |
| [assetStorage.backendFallback.enabledS3](./values.yaml#L320) | *bool* | `false` | `ENABLE_ASSET_STORAGE_FALLBACK_S3` |
| [assetStorage.backendType](./values.yaml#L307) | *string* | `"built-in"` | Asset storage backend is only available if `database.enabled` is `true` Sets `ASSET_STORAGE_BACKEND`: `built-in`, `s3` or `azure` |
| [assetStorage.localCacheSizeMegabytes](./values.yaml#L303) | *int* | `2000` | Sets local asset storage value in megabytes Results in `ASSET_STORAGE_CACHE_SIZE` (in bytes) |
| [assetStorage.redis](./values.yaml#L392) | *object* | [...](./values.yaml#L392) | Redis settings for caching and prerendering |
| [assetStorage.redis.database](./values.yaml#L410) | *string* | `""` | `REDIS_DATABASE` |
| [assetStorage.redis.enabled](./values.yaml#L395) | *bool* | `false` | `USE_REDIS_CACHE` |
| [assetStorage.redis.externalSecretName](./values.yaml#L447) | *string* | `""` | External secret name. Must contain `REDIS_USERNAME` and `REDIS_PASSWORD` if they are needed, and _may_ set other values |
| [assetStorage.redis.host](./values.yaml#L404) | *string* | `"redis"` | `REDIS_HOST` |
| [assetStorage.redis.password](./values.yaml#L436) | *string* | `""` | `REDIS_PASSWORD` |
| [assetStorage.redis.port](./values.yaml#L407) | *int* | `6379` | `REDIS_PORT` |
| [assetStorage.redis.sentinel](./values.yaml#L415) | *object* | [...](./values.yaml#L415) | Redis Sentinel |
| [assetStorage.redis.tls](./values.yaml#L440) | *object* |  | TLS settings |
| [assetStorage.redis.tls.enabled](./values.yaml#L443) | *bool* | `false` | Enable TLS (`REDIS_SSL`) |
| [assetStorage.redis.ttlSeconds](./values.yaml#L398) | *int* | `86400000` | `REDIS_TTL` |
| [assetStorage.redis.useTtl](./values.yaml#L401) | *bool* | `true` | `USE_REDIS_TTL_FOR_PRERENDERING` |
| [assetStorage.redis.username](./values.yaml#L433) | *string* | `""` | `REDIS_USERNAME` |
| [assetStorage.s3](./values.yaml#L327) | *object* | [...](./values.yaml#L327) | S3 backend storage settings, in case `assetStorage.backendType` is set to `s3 |
| [assetStorage.s3.bucket](./values.yaml#L338) | *string* | `"document-engine-assets"` | `ASSET_STORAGE_S3_BUCKET` |
| [assetStorage.s3.region](./values.yaml#L341) | *string* | `"us-east-1"` | `ASSET_STORAGE_S3_REGION` |

### [Digital signatures](./values.yaml#L452)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [documentSigningService](./values.yaml#L452) | *object* |  | Signing service parameters |
| [documentSigningService.cadesLevel](./values.yaml#L478) | *string* | `"b-lt"` | `DIGITAL_SIGNATURE_CADES_LEVEL` |
| [documentSigningService.certificateCheckTime](./values.yaml#L481) | *string* | `"current_time"` | `DIGITAL_SIGNATURE_CERTIFICATE_CHECK_TIME` |
| [documentSigningService.defaultSignatureLocation](./values.yaml#L472) | *string* | `"Head Quarters"` | `DEFAULT_SIGNATURE_LOCATION` |
| [documentSigningService.defaultSignatureReason](./values.yaml#L468) | *string* | `"approved"` | `DEFAULT_SIGNATURE_REASON` |
| [documentSigningService.defaultSignerName](./values.yaml#L464) | *string* | `"John Doe"` | `DEFAULT_SIGNER_NAME` |
| [documentSigningService.enabled](./values.yaml#L455) | *bool* | `false` | Enable signing service integration |
| [documentSigningService.hashAlgorithm](./values.yaml#L475) | *string* | `"sha512"` | `DIGITAL_SIGNATURE_HASH_ALGORITHM` |
| [documentSigningService.timeoutSeconds](./values.yaml#L461) | *int* | `10` | `SIGNING_SERVICE_TIMEOUT` in seconds |
| [documentSigningService.timestampAuthority](./values.yaml#L485) | *object* | [...](./values.yaml#L485) | Timestamp Authority (TSA) settings |
| [documentSigningService.timestampAuthority.url](./values.yaml#L488) | *string* | `"https://freetsa.org/"` | `TIMESTAMP_AUTHORITY_URL` |
| [documentSigningService.url](./values.yaml#L458) | *string* | `"https://signing-thing.local/sign"` | `SIGNING_SERVICE_URL` |

### [Dashboard](./values.yaml#L501)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [dashboard](./values.yaml#L501) | *object* |  | Document Engine Dashboard settings |
| [dashboard.auth](./values.yaml#L508) | *object* | [...](./values.yaml#L508) | Dashboard authentication |
| [dashboard.auth.externalSecret](./values.yaml#L518) | *object* | [...](./values.yaml#L518) | Use an external secret for dashboard credentials |
| [dashboard.auth.externalSecret.name](./values.yaml#L521) | *string* | `""` | External secret name |
| [dashboard.auth.externalSecret.passwordKey](./values.yaml#L527) | *string* | `"DASHBOARD_PASSWORD"` | Secret key name for the password |
| [dashboard.auth.externalSecret.usernameKey](./values.yaml#L524) | *string* | `"DASHBOARD_USERNAME"` | Secret key name for the username |
| [dashboard.auth.password](./values.yaml#L514) | *string* | `""` | `DASHBOARD_PASSWORD` — will generate a random password if not set |
| [dashboard.auth.username](./values.yaml#L511) | *string* | `"admin"` | `DASHBOARD_USERNAME` |
| [dashboard.enabled](./values.yaml#L504) | *bool* | `true` | Enable dashboard |

### [Environment](./values.yaml#L693)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [extraEnvFrom](./values.yaml#L693) | *list* | `[]` | Extra environment variables from resources |
| [extraEnvs](./values.yaml#L690) | *list* | `[]` | Extra environment variables |
| [extraVolumeMounts](./values.yaml#L699) | *list* | `[]` | Additional volume mounts for Document Engine container |
| [extraVolumes](./values.yaml#L696) | *list* | `[]` | Additional volumes |
| [image](./values.yaml#L650) | *object* | [...](./values.yaml#L650) | Image settings |
| [imagePullSecrets](./values.yaml#L657) | *list* | `[]` | Pull secrets |
| [initContainers](./values.yaml#L705) | *list* | `[]` | Init containers |
| [podSecurityContext](./values.yaml#L676) | *object* | `{}` | Pod security context |
| [securityContext](./values.yaml#L680) | *object* | `{}` | Security context |
| [serviceAccount](./values.yaml#L669) | *object* | [...](./values.yaml#L669) | ServiceAccount |
| [sidecars](./values.yaml#L702) | *list* | `[]` | Additional containers |

### [Metadata](./values.yaml#L715)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [deploymentAnnotations](./values.yaml#L715) | *object* | `{}` | Deployment annotations |
| [fullnameOverride](./values.yaml#L664) | *string* | `""` | Release full name override |
| [nameOverride](./values.yaml#L661) | *string* | `""` | Release name override |
| [podAnnotations](./values.yaml#L712) | *object* | `{}` | Pod annotations |
| [podLabels](./values.yaml#L709) | *object* | `{}` | Pod labels |

### [Networking](./values.yaml#L766)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [extraIngresses](./values.yaml#L766) | *object* | [...](./values.yaml#L766) | Additional ingresses, e.g. for the dashboard |
| [ingress](./values.yaml#L731) | *object* | [...](./values.yaml#L731) | Ingress |
| [ingress.annotations](./values.yaml#L740) | *object* | `{}` | Ingress annotations |
| [ingress.className](./values.yaml#L737) | *string* | `""` | Ingress class name |
| [ingress.enabled](./values.yaml#L734) | *bool* | `false` | Enable ingress |
| [ingress.hosts](./values.yaml#L743) | *list* | `[]` | Hosts |
| [ingress.tls](./values.yaml#L757) | *list* | `[]` | Ingress TLS section |
| [networkPolicy](./values.yaml#L783) | *object* | [...](./values.yaml#L783) | [Network policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/) |
| [networkPolicy.allowExternal](./values.yaml#L791) | *bool* | `true` | Allow access from anywhere |
| [networkPolicy.allowExternalEgress](./values.yaml#L815) | *bool* | `true` | Allow the pod to access any range of port and all destinations. |
| [networkPolicy.enabled](./values.yaml#L786) | *bool* | `true` | Enable network policy |
| [networkPolicy.extraEgress](./values.yaml#L818) | *list* | `[]` | Extra egress rules |
| [networkPolicy.extraIngress](./values.yaml#L794) | *list* | `[]` | Additional ingress rules |
| [networkPolicy.ingressMatchSelectorLabels](./values.yaml#L809) | *list* | `[]` | Allow traffic from other namespaces |
| [service](./values.yaml#L720) | *object* | [...](./values.yaml#L720) | Service |
| [service.port](./values.yaml#L726) | *int* | `5000` | Service port — see also `config.port` |
| [service.type](./values.yaml#L723) | *string* | `"ClusterIP"` | Service type |

### [Observability](./values.yaml#L532)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [observability](./values.yaml#L532) | *object* |  | Observability settings |
| [observability.log](./values.yaml#L536) | *object* | [...](./values.yaml#L536) | Logs |
| [observability.log.healthcheckLevel](./values.yaml#L542) | *string* | `"debug"` | `HEALTHCHECK_LOGLEVEL` — log level for health checks |
| [observability.log.level](./values.yaml#L539) | *string* | `"info"` | `LOG_LEVEL` |
| [observability.metrics](./values.yaml#L577) | *object* | [...](./values.yaml#L577) | Metrics configuration |
| [observability.metrics.enabled](./values.yaml#L580) | *bool* | `false` | Enable metrics exporting |
| [observability.metrics.prometheusRule](./values.yaml#L618) | *object* | [...](./values.yaml#L618) | Prometheus [PrometheusRule](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.PrometheusRule) |
| [observability.metrics.serviceMonitor](./values.yaml#L604) | *object* | [...](./values.yaml#L604) | Prometheus [ServiceMonitor](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.ServiceMonitor) |
| [observability.metrics.statsd](./values.yaml#L584) | *object* | [...](./values.yaml#L584) | StatsD parameters |
| [observability.metrics.statsd.customTags](./values.yaml#L600) | *tpl/string* | *generated* | StatsD custom tags, `STATSD_CUSTOM_TAGS` |
| [observability.metrics.statsd.port](./values.yaml#L594) | *int* | `9125` | StatsD port, `STATSD_PORT` |
| [observability.opentelemetry](./values.yaml#L546) | *object* | [...](./values.yaml#L546) | OpenTelemetry settings |
| [observability.opentelemetry.enabled](./values.yaml#L549) | *bool* | `false` | Enable OpenTelemetry (`ENABLE_OPENTELEMETRY`), only tracing is currently supported |
| [observability.opentelemetry.otelPropagators](./values.yaml#L565) | *string* | `""` | `OTEL_PROPAGATORS`, propagators |
| [observability.opentelemetry.otelResourceAttributes](./values.yaml#L562) | *string* | `""` | `OTEL_RESOURCE_ATTRIBUTES`, resource attributes |
| [observability.opentelemetry.otelServiceName](./values.yaml#L559) | *string* | `""` | `OTEL_SERVICE_NAME`, service name |
| [observability.opentelemetry.otelTracesSampler](./values.yaml#L570) | *string* | `""` | `OTEL_TRACES_SAMPLER`, should normally not be touched to allow custom `parent_based` work, but something like `parentbased_traceidratio` may be considered |
| [observability.opentelemetry.otelTracesSamplerArg](./values.yaml#L573) | *string* | `""` | `OTEL_TRACES_SAMPLER_ARG`, argument for the sampler |
| [observability.opentelemetry.otlpExporterEndpoint](./values.yaml#L553) | *string* | `""` | https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/ `OTEL_EXPORTER_OTLP_ENDPOINT`, if not set, defaults to `http://localhost:4317` |
| [observability.opentelemetry.otlpExporterProtocol](./values.yaml#L556) | *string* | `""` | `OTEL_EXPORTER_OTLP_PROTOCOL`, if not set, defaults to `grpc` |
| [prometheusExporter](./values.yaml#L628) | *object* | [...](./values.yaml#L628) | StatsD exporter for Prometheus, not recommended for production use Requires `observability.metrics.enabled` and `observability.metrics.statsd.enabled` |
| [prometheusExporter.enabled](./values.yaml#L631) | *bool* | `false` | Enable the Prometheus exporter |
| [prometheusExporter.port](./values.yaml#L638) | *int* | `10254` | Prometheus metrics port |

### [Lifecycle](./values.yaml#L874)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [lifecycle](./values.yaml#L874) | *object* | `{}` | [Lifecycle](https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/) |
| [livenessProbe](./values.yaml#L848) | *object* | [...](./values.yaml#L848) | [Liveness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) |
| [readinessProbe](./values.yaml#L861) | *object* | [...](./values.yaml#L861) | [Readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) |
| [startupProbe](./values.yaml#L835) | *object* | [...](./values.yaml#L835) | [Startup probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) |

### [Scheduling](./values.yaml#L931)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [affinity](./values.yaml#L931) | *object* | `{}` | Node affinity |
| [autoscaling](./values.yaml#L882) | *object* | [...](./values.yaml#L882) | [Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) |
| [nodeSelector](./values.yaml#L928) | *object* | `{}` | [Node selector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) |
| [podDisruptionBudget](./values.yaml#L921) | *object* | [...](./values.yaml#L921) | [Pod disruption budget](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) |
| [priorityClassName](./values.yaml#L940) | *string* | `""` | [Priority classs](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/) |
| [replicaCount](./values.yaml#L911) | *int* | `1` | Number of replicas |
| [resources](./values.yaml#L908) | *object* | `{}` | [Resources](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| [schedulerName](./values.yaml#L943) | *string* | `""` | [Scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/) |
| [terminationGracePeriodSeconds](./values.yaml#L946) | *string* | `""` | [Termination grace period](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/) |
| [tolerations](./values.yaml#L934) | *list* | `[]` | [Node tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) |
| [topologySpreadConstraints](./values.yaml#L937) | *list* | `[]` | [Topology spread constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) |
| [updateStrategy](./values.yaml#L914) | *object* | `{"rollingUpdate":{},"type":"RollingUpdate"}` | [Update strategy](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy) |

### [Dependencies](./values.yaml#L973)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| [minio](./values.yaml#L973) | *reference* | [...](./values.yaml#L973) | [External MinIO chart](https://github.com/bitnami/charts/tree/main/bitnami/minio) |
| [postgresql](./values.yaml#L951) | *reference* | [...](./values.yaml#L951) | [External PostgreSQL database chart](https://github.com/bitnami/charts/tree/main/bitnami/postgresql) |
| [redis](./values.yaml#L985) | *reference* | [...](./values.yaml#L985) | [External Redis chart](https://github.com/bitnami/charts/tree/main/bitnami/redis) |

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

# Document Engine Helm chart

![Version: 3.8.7](https://img.shields.io/badge/Version-3.8.7-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.8.3](https://img.shields.io/badge/AppVersion-1.8.3-informational?style=flat-square)

Document Engine is a backend software for processing documents and powering automation workflows.

**Homepage:** <https://www.nutrient.io/sdk/document-engine>

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
  * [Document conversion](#document-conversion)
  * [Clustering](#clustering)
  * [Dashboard](#dashboard)
  * [Environment](#environment)
  * [Metadata](#metadata)
  * [Networking](#networking)
  * [Observability](#observability)
  * [Pod lifecycle](#pod-lifecycle)
  * [Scheduling](#scheduling)
  * [Chart dependencies](#chart-dependencies)
  * [Other Values](#other-values)
* [Contribution](#contribution)
* [License](#license)
* [Support, Issues and License Questions](#support-issues-and-license-questions)

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Nutrient | <support@nutrient.io> | <https://www.nutrient.io> |

## Using this chart

### Adding the repository

```shell
helm repo add nutrient https://pspdfkit.github.io/helm-charts
helm repo update
```

### Installing Document Engine

```shell
helm upgrade --install -n document-engine \
     document-engine nutrient/document-engine \
     -f ./document-engine-values.yaml
```

### Dependencies

The chart depends upon [Bitnami](https://github.com/bitnami/charts/tree/main/bitnami) charts for PostgreSQL, [MinIO](https://min.io/) and [Redis](https://redis.io/). They are disabled by default, but can be enabled for convenience. Please consider [tests](/charts/document-engine/ci) as examples.

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | minio | 14.10.3 |
| https://charts.bitnami.com/bitnami | postgresql | 16.4.2 |
| https://charts.bitnami.com/bitnami | redis | 20.6.2 |

### Upgrade

> [!NOTE]
> Please consult the [changelog](/charts/document-engine/CHANGELOG.md)

## Values

### Document Engine License

| Key | Description | Default |
|-----|-------------|---------|
| [`documentEngineLicense`](./values.yaml#L5) | License information, see more in [our guide](https://www.nutrient.io/guides/document-engine/deployment/product-activation/) |  |
| [`documentEngineLicense.activationKey`](./values.yaml#L10) | Activation key for online activation (most common) or license key for offline activation. Results in `ACTIVATION_KEY` environment variable. | `""` |
| [`documentEngineLicense.externalSecret`](./values.yaml#L15) | Query existing secret for the activation key | [...](./values.yaml#L15) |

### API authentication

| Key | Description | Default |
|-----|-------------|---------|
| [`apiAuth`](./values.yaml#L28) | Document Enging API authentication |  |
| [`apiAuth.apiToken`](./values.yaml#L32) | `API_AUTH_TOKEN`, a universal secret with full access to the API,  should be long enough | `"secret"` |
| [`apiAuth.externalSecret`](./values.yaml#L57) | Use an external secret for API credentials |  |
| [`apiAuth.externalSecret.apiTokenKey`](./values.yaml#L64) | If external secret is enabled, but `apiTokenKey` is not set, the token will be retrieved from the `apiAuth.apiToken` value | `"API_AUTH_TOKEN"` |
| [`apiAuth.externalSecret.jwtAlgorithmKey`](./values.yaml#L68) | If external secret is enabled, but `jwtAlgorithmKey` is not set, the algorithm will be retrieved from the `apiAuth.jwt.algorithm` value | `"JWT_ALGORITHM"` |
| [`apiAuth.externalSecret.jwtPublicKeyKey`](./values.yaml#L72) | If external secret is enabled, but `jwtPublicKeyKey` is not set, the public key will be retrieved from the `apiAuth.jwt.publicKey` value | `"JWT_PUBLIC_KEY"` |
| [`apiAuth.externalSecret.name`](./values.yaml#L60) | External secret name | `""` |
| [`apiAuth.externalSecret.secretKeyBaseKey`](./values.yaml#L77) | If external secret is enabled, but `secretKeyBaseKey` is not set, the secret key base will be retrieved from the `apiAuth.secretKeyBase` value or generated automatically | `"SECRET_KEY_BASE"` |
| [`apiAuth.jwt`](./values.yaml#L36) | JSON Web Token (JWT) settings | [...](./values.yaml#L36) |
| [`apiAuth.jwt.algorithm`](./values.yaml#L47) | `JWT_ALGORITHM` Supported algorithms: `RS256`, `RS512`, `ES256`, `ES512`. See RFC 7518 for details about specific algorithms. | `"RS256"` |
| [`apiAuth.jwt.enabled`](./values.yaml#L39) | Enable JWT | `false` |
| [`apiAuth.jwt.publicKey`](./values.yaml#L42) | `JWT_PUBLIC_KEY` | `"none"` |
| [`apiAuth.secretKeyBase`](./values.yaml#L53) | A string used as the base key for deriving secret keys for the purposes of authentication. Choose a sufficiently long random string for this option. To generate a random string, use: `openssl rand -hex 256`. This will set `SECRET_KEY_BASE` environment variable. | `""` |

### Configuration options

| Key | Description | Default |
|-----|-------------|---------|
| [`config`](./values.yaml#L82) | General configuration, see more in [our guide](https://www.nutrient.io/guides/document-engine/configuration/options/) |  |
| [`config.allowDocumentGeneration`](./values.yaml#L115) | `ALLOW_DOCUMENT_GENERATION` | `true` |
| [`config.allowDocumentUploads`](./values.yaml#L109) | `ALLOW_DOCUMENT_UPLOADS` | `true` |
| [`config.allowRemoteAssetsInGeneration`](./values.yaml#L118) | `ALLOW_REMOTE_ASSETS_IN_GENERATION` | `true` |
| [`config.allowRemoteDocuments`](./values.yaml#L112) | `ALLOW_REMOTE_DOCUMENTS` | `true` |
| [`config.asyncJobsTtlSeconds`](./values.yaml#L106) | `ASYNC_JOBS_TTL` | `172800` |
| [`config.automaticLinkExtraction`](./values.yaml#L124) | `AUTOMATIC_LINK_EXTRACTION` | `false` |
| [`config.generationTimeoutSeconds`](./values.yaml#L94) | `PDF_GENERATION_TIMEOUT` in seconds | `20` |
| [`config.ignoreInvalidAnnotations`](./values.yaml#L121) | `IGNORE_INVALID_ANNOTATIONS` | `true` |
| [`config.maxUploadSizeMegaBytes`](./values.yaml#L103) | `MAX_UPLOAD_SIZE_BYTES` in megabytes | `950` |
| [`config.minSearchQueryLength`](./values.yaml#L127) | `MIN_SEARCH_QUERY_LENGTH` | `3` |
| [`config.port`](./values.yaml#L138) | `PORT` for the Document Engine API | `5000` |
| [`config.proxy`](./values.yaml#L133) | Proxy settings, `HTTP_PROXY` amd `HTTPS_PROXY` | `{"http":"","https":""}` |
| [`config.readAnnotationBatchTimeoutSeconds`](./values.yaml#L100) | `READ_ANNOTATION_BATCH_TIMEOUT` in seconds | `20` |
| [`config.replaceSecretsFromEnv`](./values.yaml#L143) | `REPLACE_SECRETS_FROM_ENV` — whether to consider environment variables, values and secrets for `JWT_PUBLIC_KEY`, `SECRET_KEY_BASE` and `DASHBOARD_PASSWORD` | `true` |
| [`config.requestTimeoutSeconds`](./values.yaml#L88) | Full request timeout in seconds (`SERVER_REQUEST_TIMEOUT`) | `60` |
| [`config.trustedProxies`](./values.yaml#L130) | `TRUSTED_PROXIES` | `"default"` |
| [`config.urlFetchTimeoutSeconds`](./values.yaml#L97) | `REMOTE_URL_FETCH_TIMEOUT` in seconds | `5` |
| [`config.workerPoolSize`](./values.yaml#L85) | `PSPDFKIT_WORKER_POOL_SIZE` | `16` |
| [`config.workerTimeoutSeconds`](./values.yaml#L91) | Document processing timeout in seconds (`PSPDFKIT_WORKER_TIMEOUT`) | `60` |

### Certificate trust

| Key | Description | Default |
|-----|-------------|---------|
| [`certificateTrust`](./values.yaml#L148) | [Certificate trust](https://www.nutrient.io/guides/document-engine/configuration/certificate-trust/) |  |
| [`certificateTrust.customCertificates`](./values.yaml#L161) | ConfigMap and Secret references for trust configuration, stored in `/certificate-stores-custom` | `[]` |
| [`certificateTrust.digitalSignatures`](./values.yaml#L152) | CAs for digital signatures (`/certificate-stores/`) from ConfigMap and Secret resources. | `[]` |
| [`certificateTrust.downloaderTrustFileName`](./values.yaml#L171) | Override `DOWNLOADER_CERT_FILE_PATH` to set HTTP client trust. If empty, defaults to  Mozilla's CA bundle. | `""` |

### Database

| Key | Description | Default |
|-----|-------------|---------|
| [`database`](./values.yaml#L176) | Database |  |
| [`database.connections`](./values.yaml#L185) | `DATABASE_CONNECTIONS` | `20` |
| [`database.enabled`](./values.yaml#L179) | Persistent storage enabled | `true` |
| [`database.engine`](./values.yaml#L182) | Database engine: only `postgres` is currently supported | `"postgres"` |
| [`database.migrationJob`](./values.yaml#L249) | Database migration jobs. | [...](./values.yaml#L249) |
| [`database.migrationJob.enabled`](./values.yaml#L252) | It `true`, results in `ENABLE_DATABASE_MIGRATIONS=false` in the main Document Engine container | `false` |
| [`database.postgres`](./values.yaml#L190) | PostgreSQL database settings | [...](./values.yaml#L190) |
| [`database.postgres.adminPassword`](./values.yaml#L211) | `PG_ADMIN_PASSWORD` | `"despair"` |
| [`database.postgres.adminUsername`](./values.yaml#L208) | `PG_ADMIN_USER` | `"postgres"` |
| [`database.postgres.database`](./values.yaml#L199) | `PGDATABASE` | `"document-engine"` |
| [`database.postgres.externalAdminSecretName`](./values.yaml#L220) | External secret for administrative database credentials, used for migrations: `PG_ADMIN_USER` and `PG_ADMIN_PASSWORD` | `""` |
| [`database.postgres.externalSecretName`](./values.yaml#L216) | Use external secret for database credentials. `PGUSER` and `PGPASSWORD` must be provided and, if not defined: `PGDATABASE`, `PGHOST`, `PGPORT`, `PGSSL` | `""` |
| [`database.postgres.host`](./values.yaml#L193) | `PGHOST` | `"postgresql"` |
| [`database.postgres.password`](./values.yaml#L205) | `PGPASSWORD` | `"despair"` |
| [`database.postgres.port`](./values.yaml#L196) | `PGPORT` | `5432` |
| [`database.postgres.tls`](./values.yaml#L225) | TLS settings | [...](./values.yaml#L225) |
| [`database.postgres.tls.commonName`](./values.yaml#L238) | Common name for the certificate (`PGSSL_CERT_COMMON_NAME`), defaults to `PGHOST` value | `""` |
| [`database.postgres.tls.enabled`](./values.yaml#L228) | Enable TLS (`PGSSL`) | `false` |
| [`database.postgres.tls.hostVerify`](./values.yaml#L234) | Negated `PGSSL_DISABLE_HOSTNAME_VERIFY` | `true` |
| [`database.postgres.tls.trustBundle`](./values.yaml#L242) | Trust bundle for PostgreSQL, sets `PGSSL_CA_CERTS`, mutually exclusive with `trustFileName` and takes precedence | `""` |
| [`database.postgres.tls.trustFileName`](./values.yaml#L245) | Path from `certificateTrust.customCertificates`, wraps around `PGSSL_CA_CERT_PATH` | `""` |
| [`database.postgres.tls.verify`](./values.yaml#L231) | Negated `PGSSL_DISABLE_VERIFY` | `true` |
| [`database.postgres.username`](./values.yaml#L202) | `PGUSER` | `"de-user"` |

### Document lifecycle

| Key | Description | Default |
|-----|-------------|---------|
| [`documentLifecycle`](./values.yaml#L265) | Document lifecycle management |  |
| [`documentLifecycle.cleanupJob`](./values.yaml#L270) | Regular job to remove documents from the database. Note: currently only works with the `built-in` storage backend. | [...](./values.yaml#L270) |
| [`documentLifecycle.cleanupJob.enabled`](./values.yaml#L273) | Enable the cleanup job | `false` |
| [`documentLifecycle.cleanupJob.keepHours`](./values.yaml#L279) | Documents TTL in hours | `24` |
| [`documentLifecycle.cleanupJob.persistentLike`](./values.yaml#L282) | Keep documents with IDs beginning with `persistent` indefinitely | `"persistent%"` |
| [`documentLifecycle.cleanupJob.schedule`](./values.yaml#L276) | Cleanup job schedule in cron format | `"13 * * * *"` |

### Asset storage

| Key | Description | Default |
|-----|-------------|---------|
| [`assetStorage`](./values.yaml#L293) | Everything about storing and caching assets |  |
| [`assetStorage.azure`](./values.yaml#L360) | Azure blob storage settings, in case `assetStorage.backendType` is set to `azure` | [...](./values.yaml#L360) |
| [`assetStorage.azure.container`](./values.yaml#L371) | `AZURE_STORAGE_DEFAULT_CONTAINER` | `""` |
| [`assetStorage.backendFallback`](./values.yaml#L308) | Asset storage fallback settings | [...](./values.yaml#L308) |
| [`assetStorage.backendFallback.enabled`](./values.yaml#L311) | `ENABLE_ASSET_STORAGE_FALLBACK` | `false` |
| [`assetStorage.backendFallback.enabledAzure`](./values.yaml#L320) | `ENABLE_ASSET_STORAGE_FALLBACK_AZURE` | `false` |
| [`assetStorage.backendFallback.enabledPostgres`](./values.yaml#L314) | `ENABLE_ASSET_STORAGE_FALLBACK_POSTGRES` | `false` |
| [`assetStorage.backendFallback.enabledS3`](./values.yaml#L317) | `ENABLE_ASSET_STORAGE_FALLBACK_S3` | `false` |
| [`assetStorage.backendType`](./values.yaml#L301) | Asset storage backend is only available if `database.enabled` is `true` Sets `ASSET_STORAGE_BACKEND`: `built-in`, `s3` or `azure` | `"built-in"` |
| [`assetStorage.fileUploadTimeoutSeconds`](./values.yaml#L304) | `FILE_UPLOAD_TIMEOUT_MS` in seconds | `30` |
| [`assetStorage.localCacheSizeMegabytes`](./values.yaml#L297) | Sets local asset storage value in megabytes Results in `ASSET_STORAGE_CACHE_SIZE` (in bytes) | `2000` |
| [`assetStorage.redis`](./values.yaml#L389) | Redis settings for caching and prerendering | [...](./values.yaml#L389) |
| [`assetStorage.redis.database`](./values.yaml#L407) | `REDIS_DATABASE` | `""` |
| [`assetStorage.redis.enabled`](./values.yaml#L392) | `USE_REDIS_CACHE` | `false` |
| [`assetStorage.redis.externalSecretName`](./values.yaml#L444) | External secret name. Must contain `REDIS_USERNAME` and `REDIS_PASSWORD` if they are needed, and _may_ set other values | `""` |
| [`assetStorage.redis.host`](./values.yaml#L401) | `REDIS_HOST` | `"redis"` |
| [`assetStorage.redis.password`](./values.yaml#L433) | `REDIS_PASSWORD` | `""` |
| [`assetStorage.redis.port`](./values.yaml#L404) | `REDIS_PORT` | `6379` |
| [`assetStorage.redis.sentinel`](./values.yaml#L412) | Redis Sentinel | [...](./values.yaml#L412) |
| [`assetStorage.redis.tls`](./values.yaml#L437) | TLS settings |  |
| [`assetStorage.redis.tls.enabled`](./values.yaml#L440) | Enable TLS (`REDIS_SSL`) | `false` |
| [`assetStorage.redis.ttlSeconds`](./values.yaml#L395) | `REDIS_TTL` | `86400000` |
| [`assetStorage.redis.useTtl`](./values.yaml#L398) | `USE_REDIS_TTL_FOR_PRERENDERING` | `true` |
| [`assetStorage.redis.username`](./values.yaml#L430) | `REDIS_USERNAME` | `""` |
| [`assetStorage.s3`](./values.yaml#L324) | S3 backend storage settings, in case `assetStorage.backendType` is set to `s3 | [...](./values.yaml#L324) |
| [`assetStorage.s3.bucket`](./values.yaml#L335) | `ASSET_STORAGE_S3_BUCKET` | `"document-engine-assets"` |
| [`assetStorage.s3.region`](./values.yaml#L338) | `ASSET_STORAGE_S3_REGION` | `"us-east-1"` |

### Digital signatures

| Key | Description | Default |
|-----|-------------|---------|
| [`documentSigningService`](./values.yaml#L449) | Signing service parameters |  |
| [`documentSigningService.cadesLevel`](./values.yaml#L475) | `DIGITAL_SIGNATURE_CADES_LEVEL` | `"b-lt"` |
| [`documentSigningService.certificateCheckTime`](./values.yaml#L478) | `DIGITAL_SIGNATURE_CERTIFICATE_CHECK_TIME` | `"current_time"` |
| [`documentSigningService.defaultSignatureLocation`](./values.yaml#L469) | `DEFAULT_SIGNATURE_LOCATION` | `"Head Quarters"` |
| [`documentSigningService.defaultSignatureReason`](./values.yaml#L465) | `DEFAULT_SIGNATURE_REASON` | `"approved"` |
| [`documentSigningService.defaultSignerName`](./values.yaml#L461) | `DEFAULT_SIGNER_NAME` | `"John Doe"` |
| [`documentSigningService.enabled`](./values.yaml#L452) | Enable signing service integration | `false` |
| [`documentSigningService.hashAlgorithm`](./values.yaml#L472) | `DIGITAL_SIGNATURE_HASH_ALGORITHM` | `"sha512"` |
| [`documentSigningService.timeoutSeconds`](./values.yaml#L458) | `SIGNING_SERVICE_TIMEOUT` in seconds | `10` |
| [`documentSigningService.timestampAuthority`](./values.yaml#L482) | Timestamp Authority (TSA) settings | [...](./values.yaml#L482) |
| [`documentSigningService.timestampAuthority.url`](./values.yaml#L485) | `TIMESTAMP_AUTHORITY_URL` | `"https://freetsa.org/"` |
| [`documentSigningService.url`](./values.yaml#L455) | `SIGNING_SERVICE_URL` | `"https://signing-thing.local/sign"` |

### Document conversion

| Key | Description | Default |
|-----|-------------|---------|
| [`documentConversion`](./values.yaml#L498) | Document conversion parameters |  |
| [`documentConversion.spreadsheetMaxContentHeightMm`](./values.yaml#L502) | Maximal spreadhseet content height in millimetres (`SPREADSHEET_MAX_CONTENT_HEIGHT_MM`). Defaults to `0` for unlimited height. | `0` |
| [`documentConversion.spreadsheetMaxContentWidthMm`](./values.yaml#L506) | Maximal spreadhseet content width in millimetres (`SPREADSHEET_MAX_CONTENT_WIDTH_MM`). Defaults to `0` for unlimited width. | `0` |

### Clustering

| Key | Description | Default |
|-----|-------------|---------|
| [`clustering`](./values.yaml#L511) | Clustering settings |  |
| [`clustering.enabled`](./values.yaml#L514) | `CLUSTERING_ENABLED`, enable clustering, only works when `replicaCount` is greater than 1 | `false` |
| [`clustering.method`](./values.yaml#L517) | `CLUSTERING_METHOD`, only `kubernetes_dns` is currently supported | `"kubernetes_dns"` |

### Dashboard

| Key | Description | Default |
|-----|-------------|---------|
| [`dashboard`](./values.yaml#L528) | Document Engine Dashboard settings |  |
| [`dashboard.auth`](./values.yaml#L535) | Dashboard authentication | [...](./values.yaml#L535) |
| [`dashboard.auth.externalSecret`](./values.yaml#L545) | Use an external secret for dashboard credentials | [...](./values.yaml#L545) |
| [`dashboard.auth.externalSecret.name`](./values.yaml#L548) | External secret name | `""` |
| [`dashboard.auth.externalSecret.passwordKey`](./values.yaml#L554) | Secret key name for the password | `"DASHBOARD_PASSWORD"` |
| [`dashboard.auth.externalSecret.usernameKey`](./values.yaml#L551) | Secret key name for the username | `"DASHBOARD_USERNAME"` |
| [`dashboard.auth.password`](./values.yaml#L541) | `DASHBOARD_PASSWORD` — will generate a random password if not set | `""` |
| [`dashboard.auth.username`](./values.yaml#L538) | `DASHBOARD_USERNAME` | `"admin"` |
| [`dashboard.enabled`](./values.yaml#L531) | Enable dashboard | `true` |

### Environment

| Key | Description | Default |
|-----|-------------|---------|
| [`extraEnvFrom`](./values.yaml#L750) | Extra environment variables from resources | `[]` |
| [`extraEnvs`](./values.yaml#L747) | Extra environment variables | `[]` |
| [`extraVolumeMounts`](./values.yaml#L756) | Additional volume mounts for Document Engine container | `[]` |
| [`extraVolumes`](./values.yaml#L753) | Additional volumes | `[]` |
| [`image`](./values.yaml#L707) | Image settings | [...](./values.yaml#L707) |
| [`imagePullSecrets`](./values.yaml#L714) | Pull secrets | `[]` |
| [`initContainers`](./values.yaml#L762) | Init containers | `[]` |
| [`podSecurityContext`](./values.yaml#L733) | Pod security context | `{}` |
| [`securityContext`](./values.yaml#L737) | Security context | `{}` |
| [`serviceAccount`](./values.yaml#L726) | ServiceAccount | [...](./values.yaml#L726) |
| [`sidecars`](./values.yaml#L759) | Additional containers | `[]` |

### Metadata

| Key | Description | Default |
|-----|-------------|---------|
| [`deploymentAnnotations`](./values.yaml#L772) | Deployment annotations | `{}` |
| [`deploymentExtraSelectorLabels`](./values.yaml#L775) | Init containers | `{}` |
| [`fullnameOverride`](./values.yaml#L721) | Release full name override | `""` |
| [`nameOverride`](./values.yaml#L718) | Release name override | `""` |
| [`podAnnotations`](./values.yaml#L769) | Pod annotations | `{}` |
| [`podLabels`](./values.yaml#L766) | Pod labels | `{}` |

### Networking

| Key | Description | Default |
|-----|-------------|---------|
| [`extraIngresses`](./values.yaml#L826) | Additional ingresses, e.g. for the dashboard | [...](./values.yaml#L826) |
| [`ingress`](./values.yaml#L791) | Ingress | [...](./values.yaml#L791) |
| [`ingress.annotations`](./values.yaml#L800) | Ingress annotations | `{}` |
| [`ingress.className`](./values.yaml#L797) | Ingress class name | `""` |
| [`ingress.enabled`](./values.yaml#L794) | Enable ingress | `false` |
| [`ingress.hosts`](./values.yaml#L803) | Hosts | `[]` |
| [`ingress.tls`](./values.yaml#L817) | Ingress TLS section | `[]` |
| [`networkPolicy`](./values.yaml#L843) | [Network policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/) | [...](./values.yaml#L843) |
| [`networkPolicy.allowExternal`](./values.yaml#L851) | Allow access from anywhere | `true` |
| [`networkPolicy.allowExternalEgress`](./values.yaml#L875) | Allow the pod to access any range of port and all destinations. | `true` |
| [`networkPolicy.enabled`](./values.yaml#L846) | Enable network policy | `true` |
| [`networkPolicy.extraEgress`](./values.yaml#L878) | Extra egress rules | `[]` |
| [`networkPolicy.extraIngress`](./values.yaml#L854) | Additional ingress rules | `[]` |
| [`networkPolicy.ingressMatchSelectorLabels`](./values.yaml#L869) | Allow traffic from other namespaces | `[]` |
| [`service`](./values.yaml#L780) | Service | [...](./values.yaml#L780) |
| [`service.port`](./values.yaml#L786) | Service port — see also `config.port` | `5000` |
| [`service.type`](./values.yaml#L783) | Service type | `"ClusterIP"` |

### Observability

| Key | Description | Default |
|-----|-------------|---------|
| [`observability`](./values.yaml#L559) | Observability settings |  |
| [`observability.log`](./values.yaml#L563) | Logs | [...](./values.yaml#L563) |
| [`observability.log.healthcheckLevel`](./values.yaml#L569) | `HEALTHCHECK_LOGLEVEL` — log level for health checks | `"debug"` |
| [`observability.log.level`](./values.yaml#L566) | `LOG_LEVEL` | `"info"` |
| [`observability.metrics`](./values.yaml#L604) | Metrics configuration | [...](./values.yaml#L604) |
| [`observability.metrics.enabled`](./values.yaml#L607) | Enable metrics exporting | `false` |
| [`observability.metrics.grafanaDashboard`](./values.yaml#L653) | Grafana dashboard | [...](./values.yaml#L653) |
| [`observability.metrics.grafanaDashboard.allNamespaces`](./values.yaml#L679) | Whether to cover all namespaces | `false` |
| [`observability.metrics.grafanaDashboard.configMap`](./values.yaml#L661) | ConfigMap parameters | [...](./values.yaml#L661) |
| [`observability.metrics.grafanaDashboard.configMap.labels`](./values.yaml#L664) | ConfigMap labels | `{"grafana_dashboard":"1"}` |
| [`observability.metrics.grafanaDashboard.enabled`](./values.yaml#L657) | Enable Grafana dashboard. Currently requires `prometheusExporter.enabled` | `false` |
| [`observability.metrics.grafanaDashboard.tags`](./values.yaml#L674) | Dashboard tags | `["Nutrient","document-engine"]` |
| [`observability.metrics.grafanaDashboard.title`](./values.yaml#L671) | Dashboard title | *generated* |
| [`observability.metrics.prometheusRule`](./values.yaml#L645) | Prometheus [PrometheusRule](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.PrometheusRule) | [...](./values.yaml#L645) |
| [`observability.metrics.serviceMonitor`](./values.yaml#L631) | Prometheus [ServiceMonitor](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.ServiceMonitor) | [...](./values.yaml#L631) |
| [`observability.metrics.statsd`](./values.yaml#L611) | StatsD parameters | [...](./values.yaml#L611) |
| [`observability.metrics.statsd.customTags`](./values.yaml#L627) | StatsD custom tags, `STATSD_CUSTOM_TAGS` | *generated* |
| [`observability.metrics.statsd.port`](./values.yaml#L621) | StatsD port, `STATSD_PORT` | `9125` |
| [`observability.opentelemetry`](./values.yaml#L573) | OpenTelemetry settings | [...](./values.yaml#L573) |
| [`observability.opentelemetry.enabled`](./values.yaml#L576) | Enable OpenTelemetry (`ENABLE_OPENTELEMETRY`), only tracing is currently supported | `false` |
| [`observability.opentelemetry.otelPropagators`](./values.yaml#L592) | `OTEL_PROPAGATORS`, propagators | `""` |
| [`observability.opentelemetry.otelResourceAttributes`](./values.yaml#L589) | `OTEL_RESOURCE_ATTRIBUTES`, resource attributes | `""` |
| [`observability.opentelemetry.otelServiceName`](./values.yaml#L586) | `OTEL_SERVICE_NAME`, service name | `""` |
| [`observability.opentelemetry.otelTracesSampler`](./values.yaml#L597) | `OTEL_TRACES_SAMPLER`, should normally not be touched to allow custom `parent_based` work, but something like `parentbased_traceidratio` may be considered | `""` |
| [`observability.opentelemetry.otelTracesSamplerArg`](./values.yaml#L600) | `OTEL_TRACES_SAMPLER_ARG`, argument for the sampler | `""` |
| [`observability.opentelemetry.otlpExporterEndpoint`](./values.yaml#L580) | https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/ `OTEL_EXPORTER_OTLP_ENDPOINT`, if not set, defaults to `http://localhost:4317` | `""` |
| [`observability.opentelemetry.otlpExporterProtocol`](./values.yaml#L583) | `OTEL_EXPORTER_OTLP_PROTOCOL`, if not set, defaults to `grpc` | `""` |
| [`prometheusExporter`](./values.yaml#L685) | StatsD exporter for Prometheus, not recommended for production use Requires `observability.metrics.enabled` and `observability.metrics.statsd.enabled` | [...](./values.yaml#L685) |
| [`prometheusExporter.enabled`](./values.yaml#L688) | Enable the Prometheus exporter | `false` |
| [`prometheusExporter.port`](./values.yaml#L695) | Prometheus metrics port | `10254` |

### Pod lifecycle

| Key | Description | Default |
|-----|-------------|---------|
| [`lifecycle`](./values.yaml#L937) | [Lifecycle](https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/) | `map[]` |
| [`livenessProbe`](./values.yaml#L908) | [Liveness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L908) |
| [`readinessProbe`](./values.yaml#L921) | [Readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L921) |
| [`startupProbe`](./values.yaml#L895) | [Startup probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L895) |
| [`terminationGracePeriodSeconds`](./values.yaml#L933) | [Termination grace period](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/) | `30` |

### Scheduling

| Key | Description | Default |
|-----|-------------|---------|
| [`affinity`](./values.yaml#L993) | Node affinity | `{}` |
| [`autoscaling`](./values.yaml#L942) | [Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) | [...](./values.yaml#L942) |
| [`nodeSelector`](./values.yaml#L990) | [Node selector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) | `{}` |
| [`podDisruptionBudget`](./values.yaml#L983) | [Pod disruption budget](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) | [...](./values.yaml#L983) |
| [`priorityClassName`](./values.yaml#L1002) | [Priority classs](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/) | `""` |
| [`replicaCount`](./values.yaml#L971) | Number of replicas | `1` |
| [`resources`](./values.yaml#L968) | [Resources](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) | `{}` |
| [`schedulerName`](./values.yaml#L1005) | [Scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/) | `""` |
| [`tolerations`](./values.yaml#L996) | [Node tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) | `[]` |
| [`topologySpreadConstraints`](./values.yaml#L999) | [Topology spread constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) | `[]` |
| [`updateStrategy`](./values.yaml#L974) | [Update strategy](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy) | `{"rollingUpdate":{},"type":"RollingUpdate"}` |

### Chart dependencies

| Key | Description | Default |
|-----|-------------|---------|
| [`minio`](./values.yaml#L1032) | [External MinIO chart](https://github.com/bitnami/charts/tree/main/bitnami/minio) | [...](./values.yaml#L1032) |
| [`postgresql`](./values.yaml#L1010) | [External PostgreSQL database chart](https://github.com/bitnami/charts/tree/main/bitnami/postgresql) | [...](./values.yaml#L1010) |
| [`redis`](./values.yaml#L1044) | [External Redis chart](https://github.com/bitnami/charts/tree/main/bitnami/redis) | [...](./values.yaml#L1044) |

### Other Values

| Key | Description | Default |
|-----|-------------|---------|
| [`revisionHistoryLimit`](./values.yaml#L978) | [Revision history limit](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#clean-up-policy) | `10` |

## Contribution

The chart is validated using [ct](https://github.com/helm/chart-testing/tree/main) [lint](https://github.com/helm/chart-testing/blob/main/doc/ct_lint.md):

```shell
ct lint --target-branch "$(git rev-parse --abbrev-ref HEAD)"
```

## License

This software is licensed under a [modified BSD license](LICENSE).

## Support, Issues and License Questions

Nutrient offers support via https://support.nutrient.io/hc/en-us/requests/new

Are you [evaluating our SDK](https://www.nutrient.io/sdk/)? That's great, we're happy to help out! To make sure this is fast, please use a work email and have someone from your company fill out our sales form: https://www.nutrient.io/contact-sales/

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)

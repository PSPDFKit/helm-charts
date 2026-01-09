# Document Engine Helm chart

![Version: 7.5.0](https://img.shields.io/badge/Version-7.5.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.13.0](https://img.shields.io/badge/AppVersion-1.13.0-informational?style=flat-square)

Document Engine is a backend software for processing documents and powering automation workflows.

**Homepage:** <https://www.nutrient.io/sdk/document-engine>

* [Using this chart](#using-this-chart)
* [Database and asset storage](#database-and-asset-storage)
  * [PostgreSQL](#postgresql)
  * [Object storage](#object-storage)
  * [Rendering cache](#rendering-cache)
* [Integrations](#integrations)
  * [AWS ALB](#aws-alb-integration)
  * [CloudNativePG operator](#cloudnativepg-operator)
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
  * [Storage resource definitions](#storage-resource-definitions)
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
helm upgrade --install \
     --namespace document-engine --create-namespace \
     document-engine nutrient/document-engine \
     -f ./document-engine-values.yaml
```

### Dependencies

Schema is generated using [helm values schema json plugin](https://github.com/losisin/helm-values-schema-json).

`README.md` is generated with [helm-docs](https://github.com/norwoodj/helm-docs).

### Upgrade

> [!NOTE]
> Please consult the [changelog](/charts/document-engine/CHANGELOG.md)

## Database and asset storage

### PostgreSQL

In order to have full Document Engine API supported, be able to integrate with Nutrient Web SDK, a database is necessary.

The chart does not provide means to install PostgreSQL database, object storage or Redis for rendering cache.

Instead, we recommend to manage these resources externally, e.g., on the cloud provider level.

However, the chart suggests generation of PostgreSQL Cluster custom resource provided by [CloudNativePG](https://cloudnative-pg.io/) operator.

CloudNativePG is not the only possible solution, and we recommend to also consider [StackGres](https://stackgres.io/), [Zalando Postgres Operator](https://github.com/zalando/postgres-operator).

## Object storage

To offload the bulk of binary storage from the database,
Document Engine can [utilise](https://www.nutrient.io/guides/document-engine/configuration/asset-storage/) S3-compatible object storage or Azure Blob Storage.

In addition to the managed services (Amazon S3, Google Cloud Storage, many others), there are also options for self-hosting, including, but not limited to [Ceph](https://ceph.io/en/), [MinIO](https://www.min.io/).

The latter is a popular way to implement S3-compatible buckets in a vendor-agnostic way.
However, due to very limited Custom Resource Definitions ecosystem in MinIO, this chart is not attempting to provide a plug-in support for it.

## Rendering cache

Rendering of frequently accessed files can be optimised using [Redis cache](https://www.nutrient.io/guides/document-engine/configuration/cache/).

Public cloud vendors offer managed services (e.g., Amazon ElastiCache),
but there are also well known open source alternatives for Redis clusters operations,
e.g., [Redis operator](https://ot-container-kit.github.io/redis-operator/guide/).

## Integrations

### AWS ALB integration

When using an Application Load Balancer in front of Document Engine, it needs to have the pod lifecycle aligned with Document Engine.

Specifically:

* A pod needs to stay alive longer than [target group deregistration delay](https://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_TargetGroupAttribute.html). This can be achieved using `lifecycle` and `terminationGracePeriodSeconds` values.
* As in any other case for Document Engine, all timeouts should be smaller than `terminationGracePeriodSeconds`, especially `config.requestTimeoutSeconds`.
* As common for ALB, [load balancer idle timeout](https://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_LoadBalancerAttribute.html) should be greater than the target group deregistration delay.

Here's an example of configuration subset to use with [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/), passing platform service parameters as [ingress annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/ingress/annotations/):

```yaml
config:
  requestTimeoutSeconds: 180
  urlFetchTimeoutSeconds: 120
  generationTimeoutSeconds: 120
  workerTimeoutSeconds: 150
  readAnnotationBatchTimeoutSeconds: 120
terminationGracePeriodSeconds: 330
lifecycle:
  preStop:
    sleep:
      seconds: 305
ingress:
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/ssl-redirect: '443'
    alb.ingress.kubernetes.io/healthcheck-path: /healthcheck
    alb.ingress.kubernetes.io/success-codes: '200'
    alb.ingress.kubernetes.io/healthy-threshold-count: '2'
    alb.ingress.kubernetes.io/healthcheck-interval-seconds: '5'
    alb.ingress.kubernetes.io/healthcheck-timeout-seconds: '2'
    alb.ingress.kubernetes.io/load-balancer-attributes: >-
      routing.http2.enabled=true,
      idle_timeout.timeout_seconds=600,
      routing.http.desync_mitigation_mode=defensive
    alb.ingress.kubernetes.io/target-group-attributes: >-
      deregistration_delay.timeout_seconds=300,
      load_balancing.algorithm.type=least_outstanding_requests,
      load_balancing.algorithm.anomaly_mitigation=off
    alb.ingress.kubernetes.io/listener-attributes.HTTPS-443: >-
      routing.http.response.server.enabled=false,
      routing.http.response.strict_transport_security.header_value=max-age=31536000;includeSubDomains;preload;
```

### CloudNativePG operator

A prerequisite is a running operator, which can be installed into namespace `cnpg-system` in a Kubernetes cluster like this:

```shell
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg \
  --namespace cnpg-system --create-namespace \
  cnpg/cloudnative-pg
```

Then, a configuration subset to create a single node PostgreSQL database with hardcoded credentials and connect it to Document Engine:

```yaml
database:
  enabled: true
  postgres:
    host: "{{ .Release.Name }}-postgres-rw"
    database: document-engine
    username: postgres
    password: nutrientDocumentEngine
    adminUsername: postgres
    adminPassword: nutrientDocumentEngine
cloudNativePG:
  enabled: true
  operatorNamespace: cnpg-system
  operatorReleaseName: cloudnative-pg
  clusterSpec:
    instances: 1
    storage:
      size: 512Mi
      storageClass: standard
    enableSuperuserAccess: true
    bootstrap:
      initdb:
        database: nutrient
        owner: whatever
    logLevel: warning
  superuserSecret:
    create: true
    username: postgres
    password: nutrientDocumentEngine
  networkPolicy:
    enabled: true
```

Note:
* `cloudNativePG.clusterSpec` map, it propagates the content of a [Cluster resource `spec`](https://cloudnative-pg.io/documentation/current/cloudnative-pg.v1/#postgresql-cnpg-io-v1-ClusterSpec).
* `cloudNativePG.clusterSpec.storage` map, it sets the size and StorageClass name of the persistent volume.

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
| [`apiAuth`](./values.yaml#L28) | Document Engine API authentication |  |
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
| [`config.hoard`](./values.yaml#L132) | Hoard — internal caching service parameters | [...](./values.yaml#L132) |
| [`config.hoard.maxSizeMegaBytes`](./values.yaml#L135) | `HOARD_MAX_SIZE` — maximum size in millions of bytes | `100` |
| [`config.http2SharedRendering`](./values.yaml#L144) | Optimised rendering relying on HTTP/2 | [...](./values.yaml#L144) |
| [`config.http2SharedRendering.enabled`](./values.yaml#L147) | `HTTP2_SHARED_RENDERING_PROCESS_ENABLE` — enable shared rendering processes | `false` |
| [`config.ignoreInvalidAnnotations`](./values.yaml#L121) | `IGNORE_INVALID_ANNOTATIONS` | `true` |
| [`config.maxUploadSizeMegaBytes`](./values.yaml#L103) | `MAX_UPLOAD_SIZE_BYTES` in megabytes | `950` |
| [`config.minSearchQueryLength`](./values.yaml#L127) | `MIN_SEARCH_QUERY_LENGTH` | `3` |
| [`config.port`](./values.yaml#L165) | `PORT` for the Document Engine API | `5000` |
| [`config.proxy`](./values.yaml#L160) | Proxy settings, `HTTP_PROXY` amd `HTTPS_PROXY` | `{"http":"","https":""}` |
| [`config.readAnnotationBatchTimeoutSeconds`](./values.yaml#L100) | `READ_ANNOTATION_BATCH_TIMEOUT` in seconds | `20` |
| [`config.replaceSecretsFromEnv`](./values.yaml#L170) | `REPLACE_SECRETS_FROM_ENV` — whether to consider environment variables, values and secrets for `JWT_PUBLIC_KEY`, `SECRET_KEY_BASE` and `DASHBOARD_PASSWORD` | `true` |
| [`config.requestTimeoutSeconds`](./values.yaml#L88) | Full request timeout in seconds (`SERVER_REQUEST_TIMEOUT`). Should be lesser than `terminationGracePeriodSeconds`. | `60` |
| [`config.trustedProxies`](./values.yaml#L157) | `TRUSTED_PROXIES` — comma-separated list of IP addresses or IP address ranges of trusted proxies. Setting to `default` will use the default will use private IP ranges. | `"default"` |
| [`config.urlFetchTimeoutSeconds`](./values.yaml#L97) | `REMOTE_URL_FETCH_TIMEOUT` in seconds | `5` |
| [`config.workerPoolSize`](./values.yaml#L85) | `PSPDFKIT_WORKER_POOL_SIZE` | `16` |
| [`config.workerTimeoutSeconds`](./values.yaml#L91) | Document processing timeout in seconds (`PSPDFKIT_WORKER_TIMEOUT`). Should not be greater than `config.requestTimeoutSeconds`. | `60` |

### Certificate trust

| Key | Description | Default |
|-----|-------------|---------|
| [`certificateTrust`](./values.yaml#L175) | [Certificate trust](https://www.nutrient.io/guides/document-engine/configuration/certificate-trust/) |  |
| [`certificateTrust.customCertificates`](./values.yaml#L188) | ConfigMap and Secret references for trust configuration, stored in `/certificate-stores-custom` | `[]` |
| [`certificateTrust.digitalSignatures`](./values.yaml#L179) | CAs for digital signatures (`/certificate-stores/`) from ConfigMap and Secret resources. | `[]` |
| [`certificateTrust.downloaderTrustFileName`](./values.yaml#L198) | Override `DOWNLOADER_CERT_FILE_PATH` to set HTTP client trust. If empty, defaults to  Mozilla's CA bundle. | `""` |

### Database

| Key | Description | Default |
|-----|-------------|---------|
| [`database`](./values.yaml#L203) | Database |  |
| [`database.connections`](./values.yaml#L212) | `DATABASE_CONNECTIONS` | `20` |
| [`database.enabled`](./values.yaml#L206) | Persistent storage enabled | `true` |
| [`database.engine`](./values.yaml#L209) | Database engine: only `postgres` is currently supported | `"postgres"` |
| [`database.migrationJob`](./values.yaml#L276) | Database migration jobs. | [...](./values.yaml#L276) |
| [`database.migrationJob.enabled`](./values.yaml#L279) | It `true`, results in `ENABLE_DATABASE_MIGRATIONS=false` in the main Document Engine container | `false` |
| [`database.postgres`](./values.yaml#L217) | PostgreSQL database settings | [...](./values.yaml#L217) |
| [`database.postgres.adminPassword`](./values.yaml#L238) | `PG_ADMIN_PASSWORD` | `"despair"` |
| [`database.postgres.adminUsername`](./values.yaml#L235) | `PG_ADMIN_USER` | `"postgres"` |
| [`database.postgres.database`](./values.yaml#L226) | `PGDATABASE` | `"document-engine"` |
| [`database.postgres.externalAdminSecretName`](./values.yaml#L247) | External secret for administrative database credentials, used for migrations: `PG_ADMIN_USER` and `PG_ADMIN_PASSWORD` | `""` |
| [`database.postgres.externalSecretName`](./values.yaml#L243) | Use external secret for database credentials. `PGUSER` and `PGPASSWORD` must be provided and, if not defined: `PGDATABASE`, `PGHOST`, `PGPORT`, `PGSSL` | `""` |
| [`database.postgres.host`](./values.yaml#L220) | `PGHOST`, if not set, and `cloudNativePG.enabled`, will rely on the Cluster | `""` |
| [`database.postgres.password`](./values.yaml#L232) | `PGPASSWORD` | `"despair"` |
| [`database.postgres.port`](./values.yaml#L223) | `PGPORT` | `5432` |
| [`database.postgres.tls`](./values.yaml#L252) | TLS settings | [...](./values.yaml#L252) |
| [`database.postgres.tls.commonName`](./values.yaml#L265) | Common name for the certificate (`PGSSL_CERT_COMMON_NAME`), defaults to `PGHOST` value | `""` |
| [`database.postgres.tls.enabled`](./values.yaml#L255) | Enable TLS (`PGSSL`) | `false` |
| [`database.postgres.tls.hostVerify`](./values.yaml#L261) | Negated `PGSSL_DISABLE_HOSTNAME_VERIFY` | `true` |
| [`database.postgres.tls.trustBundle`](./values.yaml#L269) | Trust bundle for PostgreSQL, sets `PGSSL_CA_CERTS`, mutually exclusive with `trustFileName` and takes precedence | `""` |
| [`database.postgres.tls.trustFileName`](./values.yaml#L272) | Path from `certificateTrust.customCertificates`, wraps around `PGSSL_CA_CERT_PATH` | `""` |
| [`database.postgres.tls.verify`](./values.yaml#L258) | Negated `PGSSL_DISABLE_VERIFY` | `true` |
| [`database.postgres.username`](./values.yaml#L229) | `PGUSER` | `"postgres"` |

### Document lifecycle

| Key | Description | Default |
|-----|-------------|---------|
| [`documentLifecycle`](./values.yaml#L292) | Document lifecycle management |  |
| [`documentLifecycle.bulkDocumentDeletionEnabled`](./values.yaml#L295) | `ENABLE_BULK_DOCUMENT_DELETION`: enable `/api/async/delete_documents` API endpoint | `false` |
| [`documentLifecycle.expirationJob`](./values.yaml#L299) | Regular job to remove documents from the database, requires `documentLifecycle.bulkDocumentDeletionEnabled` to be `true` | [...](./values.yaml#L299) |
| [`documentLifecycle.expirationJob.enabled`](./values.yaml#L302) | Enable the document expiration job | `false` |
| [`documentLifecycle.expirationJob.keepHours`](./values.yaml#L308) | Documents TTL in hours | `24` |
| [`documentLifecycle.expirationJob.persistentLike`](./values.yaml#L312) | Keep documents with IDs beginning with `persistent` indefinitely WARNING: does not currently work | `"persistent%"` |
| [`documentLifecycle.expirationJob.schedule`](./values.yaml#L305) | Expiration job schedule in cron format | `"13 * * * *"` |
| [`documentLifecycle.expirationJob.serviceAccountName`](./values.yaml#L323) | Service account name to specify for the expiration jobs | `""` |

### Asset storage

| Key | Description | Default |
|-----|-------------|---------|
| [`assetStorage`](./values.yaml#L334) | Everything about storing and caching assets |  |
| [`assetStorage.azure`](./values.yaml#L406) | Azure blob storage settings, in case `assetStorage.backendType` is set to `azure` | [...](./values.yaml#L406) |
| [`assetStorage.azure.container`](./values.yaml#L417) | `AZURE_STORAGE_DEFAULT_CONTAINER` | `""` |
| [`assetStorage.backendFallback`](./values.yaml#L353) | Asset storage fallback settings | [...](./values.yaml#L353) |
| [`assetStorage.backendFallback.enabled`](./values.yaml#L356) | `ENABLE_ASSET_STORAGE_FALLBACK` | `false` |
| [`assetStorage.backendFallback.enabledAzure`](./values.yaml#L365) | `ENABLE_ASSET_STORAGE_FALLBACK_AZURE` | `false` |
| [`assetStorage.backendFallback.enabledPostgres`](./values.yaml#L359) | `ENABLE_ASSET_STORAGE_FALLBACK_POSTGRES` | `false` |
| [`assetStorage.backendFallback.enabledS3`](./values.yaml#L362) | `ENABLE_ASSET_STORAGE_FALLBACK_S3` | `false` |
| [`assetStorage.backendType`](./values.yaml#L346) | Asset storage backend is only available if `database.enabled` is `true` Sets `ASSET_STORAGE_BACKEND`: `built-in`, `s3` or `azure` | `"built-in"` |
| [`assetStorage.fileUploadTimeoutSeconds`](./values.yaml#L349) | `FILE_UPLOAD_TIMEOUT_MS` in seconds | `30` |
| [`assetStorage.localCacheSizeMegabytes`](./values.yaml#L338) | Sets local asset storage value in megabytes Results in `ASSET_STORAGE_CACHE_SIZE` (in bytes) | `2000` |
| [`assetStorage.localCacheTimeoutSeconds`](./values.yaml#L342) | Sets local asset storage cache timeout in seconds Results in `ASSET_STORAGE_CACHE_TIMEOUT` (in milliseconds) | `5` |
| [`assetStorage.redis`](./values.yaml#L435) | Redis settings for caching and prerendering | [...](./values.yaml#L435) |
| [`assetStorage.redis.database`](./values.yaml#L453) | `REDIS_DATABASE` | `""` |
| [`assetStorage.redis.enabled`](./values.yaml#L438) | `USE_REDIS_CACHE` | `false` |
| [`assetStorage.redis.externalSecretName`](./values.yaml#L490) | External secret name. Must contain `REDIS_USERNAME` and `REDIS_PASSWORD` if they are needed, and _may_ set other values | `""` |
| [`assetStorage.redis.host`](./values.yaml#L447) | `REDIS_HOST` | `"{{ .Release.Name }}-redis-master"` |
| [`assetStorage.redis.password`](./values.yaml#L479) | `REDIS_PASSWORD` | `""` |
| [`assetStorage.redis.port`](./values.yaml#L450) | `REDIS_PORT` | `6379` |
| [`assetStorage.redis.sentinel`](./values.yaml#L458) | Redis Sentinel | [...](./values.yaml#L458) |
| [`assetStorage.redis.tls`](./values.yaml#L483) | TLS settings |  |
| [`assetStorage.redis.tls.enabled`](./values.yaml#L486) | Enable TLS (`REDIS_SSL`) | `false` |
| [`assetStorage.redis.ttlSeconds`](./values.yaml#L444) | `REDIS_TTL` Time to live in seconds | `86400` |
| [`assetStorage.redis.useTtl`](./values.yaml#L441) | `USE_REDIS_TTL_FOR_PRERENDERING` | `true` |
| [`assetStorage.redis.username`](./values.yaml#L476) | `REDIS_USERNAME` | `""` |
| [`assetStorage.s3`](./values.yaml#L369) | S3 backend storage settings, in case `assetStorage.backendType` is set to `s3 | [...](./values.yaml#L369) |
| [`assetStorage.s3.bucket`](./values.yaml#L380) | `ASSET_STORAGE_S3_BUCKET` | `"document-engine-assets"` |
| [`assetStorage.s3.region`](./values.yaml#L383) | `ASSET_STORAGE_S3_REGION` | `"us-east-1"` |

### Digital signatures

| Key | Description | Default |
|-----|-------------|---------|
| [`documentSigningService`](./values.yaml#L495) | Signing service parameters |  |
| [`documentSigningService.cadesLevel`](./values.yaml#L521) | `DIGITAL_SIGNATURE_CADES_LEVEL` | `"b-lt"` |
| [`documentSigningService.certificateCheckTime`](./values.yaml#L524) | `DIGITAL_SIGNATURE_CERTIFICATE_CHECK_TIME` | `"current_time"` |
| [`documentSigningService.defaultSignatureLocation`](./values.yaml#L515) | `DEFAULT_SIGNATURE_LOCATION` | `"Head Quarters"` |
| [`documentSigningService.defaultSignatureReason`](./values.yaml#L511) | `DEFAULT_SIGNATURE_REASON` | `"approved"` |
| [`documentSigningService.defaultSignerName`](./values.yaml#L507) | `DEFAULT_SIGNER_NAME` | `"John Doe"` |
| [`documentSigningService.enabled`](./values.yaml#L498) | Enable signing service integration | `false` |
| [`documentSigningService.hashAlgorithm`](./values.yaml#L518) | `DIGITAL_SIGNATURE_HASH_ALGORITHM` | `"sha512"` |
| [`documentSigningService.timeoutSeconds`](./values.yaml#L504) | `SIGNING_SERVICE_TIMEOUT` in seconds | `10` |
| [`documentSigningService.timestampAuthority`](./values.yaml#L528) | Timestamp Authority (TSA) settings | [...](./values.yaml#L528) |
| [`documentSigningService.timestampAuthority.url`](./values.yaml#L531) | `TIMESTAMP_AUTHORITY_URL` | `"https://freetsa.org/"` |
| [`documentSigningService.url`](./values.yaml#L501) | `SIGNING_SERVICE_URL` | `"https://signing-thing.local/sign"` |

### Document conversion

| Key | Description | Default |
|-----|-------------|---------|
| [`documentConversion`](./values.yaml#L544) | Document conversion parameters |  |
| [`documentConversion.spreadsheetMaxContentHeightMm`](./values.yaml#L548) | Maximal spreadhseet content height in millimetres (`SPREADSHEET_MAX_CONTENT_HEIGHT_MM`). Defaults to `0` for unlimited height. | `0` |
| [`documentConversion.spreadsheetMaxContentWidthMm`](./values.yaml#L552) | Maximal spreadhseet content width in millimetres (`SPREADSHEET_MAX_CONTENT_WIDTH_MM`). Defaults to `0` for unlimited width. | `0` |

### Clustering

| Key | Description | Default |
|-----|-------------|---------|
| [`clustering`](./values.yaml#L557) | Clustering settings |  |
| [`clustering.enabled`](./values.yaml#L560) | `CLUSTERING_ENABLED`, enable clustering, only works when `replicaCount` is greater than 1 | `false` |
| [`clustering.method`](./values.yaml#L563) | `CLUSTERING_METHOD`, only `kubernetes_dns` is currently supported | `"kubernetes_dns"` |

### Dashboard

| Key | Description | Default |
|-----|-------------|---------|
| [`dashboard`](./values.yaml#L574) | Document Engine Dashboard settings |  |
| [`dashboard.auth`](./values.yaml#L586) | Dashboard authentication | [...](./values.yaml#L586) |
| [`dashboard.auth.externalSecret`](./values.yaml#L596) | Use an external secret for dashboard credentials | [...](./values.yaml#L596) |
| [`dashboard.auth.externalSecret.name`](./values.yaml#L599) | External secret name | `""` |
| [`dashboard.auth.externalSecret.passwordKey`](./values.yaml#L605) | Secret key name for the password | `"DASHBOARD_PASSWORD"` |
| [`dashboard.auth.externalSecret.usernameKey`](./values.yaml#L602) | Secret key name for the username | `"DASHBOARD_USERNAME"` |
| [`dashboard.auth.password`](./values.yaml#L592) | `DASHBOARD_PASSWORD` — will generate a random password if not set | `""` |
| [`dashboard.auth.username`](./values.yaml#L589) | `DASHBOARD_USERNAME` | `"admin"` |
| [`dashboard.enabled`](./values.yaml#L577) | Enable dashboard | `true` |
| [`dashboard.rateLimitingEnabled`](./values.yaml#L582) | `DASHBOARD_RATE_LIMITING_ENABLED` — enables rate limiting for dashboard authentication to prevent brute force attacks. When enabled, failed authentication attempts are limited to 5 per minute per IP address. | `true` |

### Environment

| Key | Description | Default |
|-----|-------------|---------|
| [`extraEnvFrom`](./values.yaml#L794) | Extra environment variables from resources | `[]` |
| [`extraEnvs`](./values.yaml#L791) | Extra environment variables | `[]` |
| [`extraVolumeMounts`](./values.yaml#L800) | Additional volume mounts for Document Engine container | `[]` |
| [`extraVolumes`](./values.yaml#L797) | Additional volumes | `[]` |
| [`image`](./values.yaml#L751) | Image settings | [...](./values.yaml#L751) |
| [`imagePullSecrets`](./values.yaml#L758) | Pull secrets | `[]` |
| [`initContainers`](./values.yaml#L806) | Init containers | `[]` |
| [`podSecurityContext`](./values.yaml#L777) | Pod security context | `{}` |
| [`securityContext`](./values.yaml#L781) | Security context | `{}` |
| [`serviceAccount`](./values.yaml#L770) | ServiceAccount | [...](./values.yaml#L770) |
| [`sidecars`](./values.yaml#L803) | Additional containers | `[]` |

### Metadata

| Key | Description | Default |
|-----|-------------|---------|
| [`deploymentAnnotations`](./values.yaml#L816) | Deployment annotations | `{}` |
| [`deploymentExtraSelectorLabels`](./values.yaml#L819) | Additional label selector for the deployment | `{}` |
| [`fullnameOverride`](./values.yaml#L765) | Release full name override | `""` |
| [`nameOverride`](./values.yaml#L762) | Release name override | `""` |
| [`podAnnotations`](./values.yaml#L813) | Pod annotations | `{}` |
| [`podLabels`](./values.yaml#L810) | Pod labels | `{}` |

### Networking

| Key | Description | Default |
|-----|-------------|---------|
| [`envoySidecar`](./values.yaml#L895) | Envoy sidecar for consistent hashing by document ID | [...](./values.yaml#L895) |
| [`envoySidecar.adminPort`](./values.yaml#L911) | Admin port for Envoy | `9901` |
| [`envoySidecar.enabled`](./values.yaml#L898) | Enable Envoy sidecar for consistent hashing | `false` |
| [`envoySidecar.healthCheck`](./values.yaml#L915) | Health check configuration for upstream cluster | [...](./values.yaml#L915) |
| [`envoySidecar.healthCheck.healthyThreshold`](./values.yaml#L927) | Healthy threshold | `2` |
| [`envoySidecar.healthCheck.interval`](./values.yaml#L921) | Health check interval | `"10s"` |
| [`envoySidecar.healthCheck.timeout`](./values.yaml#L918) | Health check timeout | `"5s"` |
| [`envoySidecar.healthCheck.unhealthyThreshold`](./values.yaml#L924) | Unhealthy threshold | `2` |
| [`envoySidecar.image`](./values.yaml#L902) | Envoy sidecar image configuration | [...](./values.yaml#L902) |
| [`envoySidecar.port`](./values.yaml#L908) | Port where Envoy sidecar listens | `8080` |
| [`envoySidecar.resources`](./values.yaml#L931) | Resource limits for Envoy sidecar | [...](./values.yaml#L931) |
| [`extraIngresses`](./values.yaml#L879) | Additional ingresses, e.g. for the dashboard | [...](./values.yaml#L879) |
| [`ingress`](./values.yaml#L844) | Ingress | [...](./values.yaml#L844) |
| [`ingress.annotations`](./values.yaml#L853) | Ingress annotations | `{}` |
| [`ingress.className`](./values.yaml#L850) | Ingress class name | `""` |
| [`ingress.enabled`](./values.yaml#L847) | Enable ingress | `false` |
| [`ingress.hosts`](./values.yaml#L856) | Hosts | `[]` |
| [`ingress.tls`](./values.yaml#L870) | Ingress TLS section | `[]` |
| [`networkPolicy`](./values.yaml#L943) | [Network policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/) | [...](./values.yaml#L943) |
| [`networkPolicy.allowExternal`](./values.yaml#L951) | Allow access from anywhere | `true` |
| [`networkPolicy.allowExternalEgress`](./values.yaml#L975) | Allow the pod to access any range of port and all destinations. | `true` |
| [`networkPolicy.enabled`](./values.yaml#L946) | Enable network policy | `true` |
| [`networkPolicy.extraEgress`](./values.yaml#L978) | Extra egress rules | `[]` |
| [`networkPolicy.extraIngress`](./values.yaml#L954) | Additional ingress rules | `[]` |
| [`networkPolicy.ingressMatchSelectorLabels`](./values.yaml#L969) | Allow traffic from other namespaces | `[]` |
| [`service`](./values.yaml#L824) | Service | [...](./values.yaml#L824) |
| [`service.annotations`](./values.yaml#L833) | Service annotations | `{}` |
| [`service.internalTrafficPolicy`](./values.yaml#L836) | Service internal traffic policy | `"Cluster"` |
| [`service.port`](./values.yaml#L830) | Service port — see also `config.port` | `5000` |
| [`service.trafficDistribution`](./values.yaml#L839) | Service [traffic distribution policy](https://kubernetes.io/docs/concepts/services-networking/service/#traffic-distribution) | `nil` |
| [`service.type`](./values.yaml#L827) | Service type | `"ClusterIP"` |

### Observability

| Key | Description | Default |
|-----|-------------|---------|
| [`observability`](./values.yaml#L610) | Observability settings |  |
| [`observability.log`](./values.yaml#L614) | Logs | [...](./values.yaml#L614) |
| [`observability.log.healthcheckLevel`](./values.yaml#L623) | `HEALTHCHECK_LOGLEVEL` — log level for health checks | `"debug"` |
| [`observability.log.level`](./values.yaml#L617) | `LOG_LEVEL` | `"info"` |
| [`observability.log.structured`](./values.yaml#L620) | `LOG_STRUCTURED` — enable structured logging in JSON format | `false` |
| [`observability.metrics`](./values.yaml#L658) | Metrics configuration | [...](./values.yaml#L658) |
| [`observability.metrics.customTags`](./values.yaml#L667) | Prometheus metrics endpoint settings | `namespace={{ .Release.Namespace }},app={{ include "document-engine.fullname" . }}` |
| [`observability.metrics.grafanaDashboard`](./values.yaml#L706) | Grafana dashboard | [...](./values.yaml#L706) |
| [`observability.metrics.grafanaDashboard.configMap`](./values.yaml#L714) | ConfigMap parameters | [...](./values.yaml#L714) |
| [`observability.metrics.grafanaDashboard.configMap.labels`](./values.yaml#L717) | ConfigMap labels | `{"grafana_dashboard":"1"}` |
| [`observability.metrics.grafanaDashboard.enabled`](./values.yaml#L710) | Enable Grafana dashboard. To work, requires Prometheus metrics enabled in `observability.metrics.prometheusEndpoint.enabled` | `false` |
| [`observability.metrics.grafanaDashboard.tags`](./values.yaml#L727) | Dashboard tags | `["Nutrient","document-engine"]` |
| [`observability.metrics.grafanaDashboard.title`](./values.yaml#L724) | Dashboard title | *generated* |
| [`observability.metrics.prometheusEndpoint.enabled`](./values.yaml#L671) | Enable Prometheus metrics endpoint, `ENABLE_PROMETHEUS` | `false` |
| [`observability.metrics.prometheusEndpoint.port`](./values.yaml#L674) | Port for the Prometheus metrics endpoint, `PROMETHEUS_PORT` | `10254` |
| [`observability.metrics.prometheusRule`](./values.yaml#L698) | Prometheus [PrometheusRule](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.PrometheusRule) Requires `observability.metrics.prometheusEndpoint.enabled` to be `true` | [...](./values.yaml#L698) |
| [`observability.metrics.serviceMonitor`](./values.yaml#L683) | Prometheus [ServiceMonitor](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.ServiceMonitor) Requires `observability.metrics.prometheusEndpoint.enabled` to be `true` | [...](./values.yaml#L683) |
| [`observability.metrics.statsd`](./values.yaml#L733) | StatsD parameters | [...](./values.yaml#L733) |
| [`observability.metrics.statsd.customTags`](./values.yaml#L746) | StatsD custom tags, `STATSD_CUSTOM_TAGS` | `` |
| [`observability.metrics.statsd.port`](./values.yaml#L742) | StatsD port, `STATSD_PORT` | `9125` |
| [`observability.opentelemetry`](./values.yaml#L627) | OpenTelemetry settings | [...](./values.yaml#L627) |
| [`observability.opentelemetry.enabled`](./values.yaml#L630) | Enable OpenTelemetry (`ENABLE_OPENTELEMETRY`), only tracing is currently supported | `false` |
| [`observability.opentelemetry.otelPropagators`](./values.yaml#L646) | `OTEL_PROPAGATORS`, propagators | `""` |
| [`observability.opentelemetry.otelResourceAttributes`](./values.yaml#L643) | `OTEL_RESOURCE_ATTRIBUTES`, resource attributes | `""` |
| [`observability.opentelemetry.otelServiceName`](./values.yaml#L640) | `OTEL_SERVICE_NAME`, service name | `""` |
| [`observability.opentelemetry.otelTracesSampler`](./values.yaml#L651) | `OTEL_TRACES_SAMPLER`, should normally not be touched to allow custom `parent_based` work, but something like `parentbased_traceidratio` may be considered | `""` |
| [`observability.opentelemetry.otelTracesSamplerArg`](./values.yaml#L654) | `OTEL_TRACES_SAMPLER_ARG`, argument for the sampler | `""` |
| [`observability.opentelemetry.otlpExporterEndpoint`](./values.yaml#L634) | https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/ `OTEL_EXPORTER_OTLP_ENDPOINT`, if not set, defaults to `http://localhost:4317` | `""` |
| [`observability.opentelemetry.otlpExporterProtocol`](./values.yaml#L637) | `OTEL_EXPORTER_OTLP_PROTOCOL`, if not set, defaults to `grpc` | `""` |

### Pod lifecycle

| Key | Description | Default |
|-----|-------------|---------|
| [`lifecycle`](./values.yaml#L1038) | [Lifecycle](https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/) | `map[]` |
| [`livenessProbe`](./values.yaml#L1008) | [Liveness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L1008) |
| [`readinessProbe`](./values.yaml#L1021) | [Readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L1021) |
| [`startupProbe`](./values.yaml#L995) | [Startup probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L995) |
| [`terminationGracePeriodSeconds`](./values.yaml#L1034) | [Termination grace period](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/). Should be greater than the longest expected request processing time (`config.requestTimeoutSeconds`). | `65` |

### Scheduling

| Key | Description | Default |
|-----|-------------|---------|
| [`affinity`](./values.yaml#L1093) | Node affinity | `{}` |
| [`autoscaling`](./values.yaml#L1046) | [Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) | [...](./values.yaml#L1046) |
| [`nodeSelector`](./values.yaml#L1090) | [Node selector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) | `{}` |
| [`podDisruptionBudget`](./values.yaml#L1083) | [Pod disruption budget](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) | [...](./values.yaml#L1083) |
| [`priorityClassName`](./values.yaml#L1102) | [Priority classs](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/) | `""` |
| [`replicaCount`](./values.yaml#L1071) | Number of replicas | `1` |
| [`resources`](./values.yaml#L1068) | [Resources](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) | `{}` |
| [`schedulerName`](./values.yaml#L1105) | [Scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/) | `""` |
| [`tolerations`](./values.yaml#L1096) | [Node tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) | `[]` |
| [`topologySpreadConstraints`](./values.yaml#L1099) | [Topology spread constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) | `[]` |
| [`updateStrategy`](./values.yaml#L1074) | [Update strategy](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy) | `{"rollingUpdate":{},"type":"RollingUpdate"}` |

### Storage resource definitions

| Key | Description | Default |
|-----|-------------|---------|
| [`cloudNativePG`](./values.yaml#L1110) | [CloudNativePG](https://cloudnative-pg.io/) resources | [...](./values.yaml#L1110) |
| [`cloudNativePG.clusterAnnotations`](./values.yaml#L1145) | Cluster annotations | `{}` |
| [`cloudNativePG.clusterLabels`](./values.yaml#L1142) | Cluster labels | `{}` |
| [`cloudNativePG.clusterName`](./values.yaml#L1122) | CloudNativePG custom Cluster name | `"{{ .Release.Name }}-postgres"` |
| [`cloudNativePG.clusterSpec`](./values.yaml#L1126) | CloudNativePG [cluster spec](https://cloudnative-pg.io/documentation/current/cloudnative-pg.v1/#postgresql-cnpg-io-v1-ClusterSpec) | [...](./values.yaml#L1126) |
| [`cloudNativePG.enabled`](./values.yaml#L1113) | Enable CloudNativePG resources | `false` |
| [`cloudNativePG.networkPolicy`](./values.yaml#L1154) | Network policy to allow access to the cluster | `{"enabled":true}` |
| [`cloudNativePG.operatorNamespace`](./values.yaml#L1116) | CloudNativePG operator namespace | `"cnpg-system"` |
| [`cloudNativePG.operatorReleaseName`](./values.yaml#L1119) | CloudNativePG operator release name | `"cloudnative-pg"` |
| [`cloudNativePG.superuserSecret`](./values.yaml#L1148) | Superuser secret to use with the cluster | `{"create":true,"password":"despair","username":"postgres"}` |

### Other Values

| Key | Description | Default |
|-----|-------------|---------|
| [`config.hoard.binaryCopyEnabled`](./values.yaml#L137) | `HOARD_BINARY_COPY_ENABLED` — internal parameter, do not change unless explicitly recommended by Nutrient support. | `true` |
| [`config.hoard.binaryCopyThreshold`](./values.yaml#L139) | `HOARD_BINARY_COPY_THRESHOLD` — internal parameter, do not change unless explicitly recommended by Nutrient support. | `2` |
| [`config.http2SharedRendering.checkinTimeoutMilliseconds`](./values.yaml#L150) | `HTTP2_SHARED_RENDERING_PROCESS_CHECKIN_TIMEOUT` — document processing daemon checkin timeout. Do not change unless explicitly recommended by Nutrient support. | `0` |
| [`config.http2SharedRendering.checkoutTimeoutMilliseconds`](./values.yaml#L153) | `HTTP2_SHARED_RENDERING_PROCESS_CHECKOUT_TIMEOUT` — document processing daemon checkout timeout. Do not change unless explicitly recommended by Nutrient support. | `5000` |
| [`revisionHistoryLimit`](./values.yaml#L1078) | [Revision history limit](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#clean-up-policy) | `10` |

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

# Document Engine Helm chart

![Version: 8.0.0](https://img.shields.io/badge/Version-8.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.14.0](https://img.shields.io/badge/AppVersion-1.14.0-informational?style=flat-square)

Document Engine is a backend software for processing documents and powering automation workflows.

**Homepage:** <https://www.nutrient.io/sdk/document-engine>

* [Using this chart](#using-this-chart)
* [Database and asset storage](#database-and-asset-storage)
  * [PostgreSQL](#postgresql)
  * [Object storage](#object-storage)
  * [Rendering cache](#rendering-cache)
  * [Persistent local cache](#persistent-local-cache)
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
  * [Persistence](#persistence)
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

## Persistent local cache

It is possible to improve "warm up" time of restarted and new Document Engine pods by enabling [persistent local cache](#persistence).
Note that the size of the volumes (`persistence.size`) must be larger than the local cache size limit (`assetStorage.localCacheSizeMegabytes`).

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
| [`documentLifecycle.expirationJob.deletionPrefix`](./values.yaml#L312) | Only delete documents with IDs beginning with this prefix. Leave empty to delete all documents matching the time filter. | `"ephemeral"` |
| [`documentLifecycle.expirationJob.enabled`](./values.yaml#L302) | Enable the document expiration job | `false` |
| [`documentLifecycle.expirationJob.keepHours`](./values.yaml#L308) | Documents TTL in hours | `24` |
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

### Persistence

| Key | Description | Default |
|-----|-------------|---------|
| [`persistence`](./values.yaml#L508) | Persistent storage settings for StatefulSet pods. Only used when `workloadType` is `StatefulSet`. | [...](./values.yaml#L508) |
| [`persistence.accessModes`](./values.yaml#L514) | PVC access modes | `["ReadWriteOnce"]` |
| [`persistence.annotations`](./values.yaml#L524) | Annotations for each PVC | `{}` |
| [`persistence.mountPath`](./values.yaml#L521) | Mount path inside the container | `"/srv/pspdfkit/assets/cache"` |
| [`persistence.size`](./values.yaml#L518) | PVC storage size | `"10Gi"` |
| [`persistence.storageClassName`](./values.yaml#L511) | Storage class for PVCs. Empty string uses cluster default. | `""` |
| [`podManagementPolicy`](./values.yaml#L502) | Pod management policy for StatefulSet: `OrderedReady` or `Parallel`. Only used when `workloadType` is `StatefulSet`. | `"OrderedReady"` |
| [`workloadType`](./values.yaml#L497) | Workload type: `Deployment` or `StatefulSet`. When `StatefulSet`, persistent storage is provisioned per pod via volumeClaimTemplates. **Note:** Switching an existing release from Deployment to StatefulSet requires deleting the existing Deployment first, as Kubernetes cannot change a resource kind in-place. | `"Deployment"` |

### Digital signatures

| Key | Description | Default |
|-----|-------------|---------|
| [`documentSigningService`](./values.yaml#L529) | Signing service parameters |  |
| [`documentSigningService.cadesLevel`](./values.yaml#L555) | `DIGITAL_SIGNATURE_CADES_LEVEL` | `"b-lt"` |
| [`documentSigningService.certificateCheckTime`](./values.yaml#L558) | `DIGITAL_SIGNATURE_CERTIFICATE_CHECK_TIME` | `"current_time"` |
| [`documentSigningService.defaultSignatureLocation`](./values.yaml#L549) | `DEFAULT_SIGNATURE_LOCATION` | `"Head Quarters"` |
| [`documentSigningService.defaultSignatureReason`](./values.yaml#L545) | `DEFAULT_SIGNATURE_REASON` | `"approved"` |
| [`documentSigningService.defaultSignerName`](./values.yaml#L541) | `DEFAULT_SIGNER_NAME` | `"John Doe"` |
| [`documentSigningService.enabled`](./values.yaml#L532) | Enable signing service integration | `false` |
| [`documentSigningService.hashAlgorithm`](./values.yaml#L552) | `DIGITAL_SIGNATURE_HASH_ALGORITHM` | `"sha512"` |
| [`documentSigningService.timeoutSeconds`](./values.yaml#L538) | `SIGNING_SERVICE_TIMEOUT` in seconds | `10` |
| [`documentSigningService.timestampAuthority`](./values.yaml#L562) | Timestamp Authority (TSA) settings | [...](./values.yaml#L562) |
| [`documentSigningService.timestampAuthority.url`](./values.yaml#L565) | `TIMESTAMP_AUTHORITY_URL` | `"https://freetsa.org/"` |
| [`documentSigningService.url`](./values.yaml#L535) | `SIGNING_SERVICE_URL` | `"https://signing-thing.local/sign"` |

### Document conversion

| Key | Description | Default |
|-----|-------------|---------|
| [`documentConversion`](./values.yaml#L578) | Document conversion parameters |  |
| [`documentConversion.spreadsheetMaxContentHeightMm`](./values.yaml#L582) | Maximal spreadhseet content height in millimetres (`SPREADSHEET_MAX_CONTENT_HEIGHT_MM`). Defaults to `0` for unlimited height. | `0` |
| [`documentConversion.spreadsheetMaxContentWidthMm`](./values.yaml#L586) | Maximal spreadhseet content width in millimetres (`SPREADSHEET_MAX_CONTENT_WIDTH_MM`). Defaults to `0` for unlimited width. | `0` |

### Clustering

| Key | Description | Default |
|-----|-------------|---------|
| [`clustering`](./values.yaml#L591) | Clustering settings |  |
| [`clustering.enabled`](./values.yaml#L594) | `CLUSTERING_ENABLED`, enable clustering, only works when `replicaCount` is greater than 1 | `false` |
| [`clustering.method`](./values.yaml#L597) | `CLUSTERING_METHOD`, only `kubernetes_dns` is currently supported | `"kubernetes_dns"` |

### Dashboard

| Key | Description | Default |
|-----|-------------|---------|
| [`dashboard`](./values.yaml#L608) | Document Engine Dashboard settings |  |
| [`dashboard.auth`](./values.yaml#L628) | Dashboard authentication | [...](./values.yaml#L628) |
| [`dashboard.auth.externalSecret`](./values.yaml#L638) | Use an external secret for dashboard credentials | [...](./values.yaml#L638) |
| [`dashboard.auth.externalSecret.name`](./values.yaml#L641) | External secret name | `""` |
| [`dashboard.auth.externalSecret.passwordKey`](./values.yaml#L647) | Secret key name for the password | `"DASHBOARD_PASSWORD"` |
| [`dashboard.auth.externalSecret.usernameKey`](./values.yaml#L644) | Secret key name for the username | `"DASHBOARD_USERNAME"` |
| [`dashboard.auth.password`](./values.yaml#L634) | `DASHBOARD_PASSWORD` — will generate a random password if not set | `""` |
| [`dashboard.auth.username`](./values.yaml#L631) | `DASHBOARD_USERNAME` | `"admin"` |
| [`dashboard.enabled`](./values.yaml#L611) | Enable dashboard | `true` |
| [`dashboard.rateLimitingEnabled`](./values.yaml#L616) | `DASHBOARD_RATE_LIMITING_ENABLED` — enables rate limiting for dashboard authentication to prevent brute force attacks. When enabled, failed authentication attempts are tracked per IP address. | `true` |
| [`dashboard.rateLimitingMaxRequests`](./values.yaml#L620) | `DASHBOARD_RATE_LIMITING_MAX_REQUESTS` — maximum number of failed authentication attempts allowed per IP address within the time window before blocking. | `5` |
| [`dashboard.rateLimitingWindowMs`](./values.yaml#L624) | `DASHBOARD_RATE_LIMITING_WINDOW_MS` — time window in milliseconds for tracking failed authentication attempts. After this period, the counter resets. | `60000` |

### Environment

| Key | Description | Default |
|-----|-------------|---------|
| [`extraEnvFrom`](./values.yaml#L836) | Extra environment variables from resources | `[]` |
| [`extraEnvs`](./values.yaml#L833) | Extra environment variables | `[]` |
| [`extraVolumeMounts`](./values.yaml#L842) | Additional volume mounts for Document Engine container | `[]` |
| [`extraVolumes`](./values.yaml#L839) | Additional volumes | `[]` |
| [`image`](./values.yaml#L793) | Image settings | [...](./values.yaml#L793) |
| [`imagePullSecrets`](./values.yaml#L800) | Pull secrets | `[]` |
| [`initContainers`](./values.yaml#L848) | Init containers | `[]` |
| [`podSecurityContext`](./values.yaml#L819) | Pod security context | `{}` |
| [`securityContext`](./values.yaml#L823) | Security context | `{}` |
| [`serviceAccount`](./values.yaml#L812) | ServiceAccount | [...](./values.yaml#L812) |
| [`sidecars`](./values.yaml#L845) | Additional containers | `[]` |

### Metadata

| Key | Description | Default |
|-----|-------------|---------|
| [`deploymentAnnotations`](./values.yaml#L858) | Workload annotations (`Deployment`/`StatefulSet`) | `{}` |
| [`deploymentExtraSelectorLabels`](./values.yaml#L863) | Additional selector labels for the workload (`Deployment`/`StatefulSet`) **Note:** Kubernetes selectors are immutable. Changing this value after first install may require recreating the workload. | `{}` |
| [`fullnameOverride`](./values.yaml#L807) | Release full name override | `""` |
| [`nameOverride`](./values.yaml#L804) | Release name override | `""` |
| [`podAnnotations`](./values.yaml#L855) | Pod annotations | `{}` |
| [`podLabels`](./values.yaml#L852) | Pod labels | `{}` |

### Networking

| Key | Description | Default |
|-----|-------------|---------|
| [`envoySidecar`](./values.yaml#L939) | Envoy sidecar for consistent hashing by document ID | [...](./values.yaml#L939) |
| [`envoySidecar.adminPort`](./values.yaml#L955) | Admin port for Envoy | `9901` |
| [`envoySidecar.enabled`](./values.yaml#L942) | Enable Envoy sidecar for consistent hashing | `false` |
| [`envoySidecar.healthCheck`](./values.yaml#L959) | Health check configuration for upstream cluster | [...](./values.yaml#L959) |
| [`envoySidecar.healthCheck.healthyThreshold`](./values.yaml#L971) | Healthy threshold | `2` |
| [`envoySidecar.healthCheck.interval`](./values.yaml#L965) | Health check interval | `"10s"` |
| [`envoySidecar.healthCheck.timeout`](./values.yaml#L962) | Health check timeout | `"5s"` |
| [`envoySidecar.healthCheck.unhealthyThreshold`](./values.yaml#L968) | Unhealthy threshold | `2` |
| [`envoySidecar.image`](./values.yaml#L946) | Envoy sidecar image configuration | [...](./values.yaml#L946) |
| [`envoySidecar.port`](./values.yaml#L952) | Port where Envoy sidecar listens | `8080` |
| [`envoySidecar.resources`](./values.yaml#L975) | Resource limits for Envoy sidecar | [...](./values.yaml#L975) |
| [`extraIngresses`](./values.yaml#L923) | Additional ingresses, e.g. for the dashboard | [...](./values.yaml#L923) |
| [`ingress`](./values.yaml#L888) | Ingress | [...](./values.yaml#L888) |
| [`ingress.annotations`](./values.yaml#L897) | Ingress annotations | `{}` |
| [`ingress.className`](./values.yaml#L894) | Ingress class name | `""` |
| [`ingress.enabled`](./values.yaml#L891) | Enable ingress | `false` |
| [`ingress.hosts`](./values.yaml#L900) | Hosts | `[]` |
| [`ingress.tls`](./values.yaml#L914) | Ingress TLS section | `[]` |
| [`networkPolicy`](./values.yaml#L987) | [Network policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/) | [...](./values.yaml#L987) |
| [`networkPolicy.allowExternal`](./values.yaml#L995) | Allow access from anywhere | `true` |
| [`networkPolicy.allowExternalEgress`](./values.yaml#L1019) | Allow the pod to access any range of port and all destinations. | `true` |
| [`networkPolicy.enabled`](./values.yaml#L990) | Enable network policy | `true` |
| [`networkPolicy.extraEgress`](./values.yaml#L1022) | Extra egress rules | `[]` |
| [`networkPolicy.extraIngress`](./values.yaml#L998) | Additional ingress rules | `[]` |
| [`networkPolicy.ingressMatchSelectorLabels`](./values.yaml#L1013) | Allow traffic from other namespaces | `[]` |
| [`service`](./values.yaml#L868) | Service | [...](./values.yaml#L868) |
| [`service.annotations`](./values.yaml#L877) | Service annotations | `{}` |
| [`service.internalTrafficPolicy`](./values.yaml#L880) | Service internal traffic policy | `"Cluster"` |
| [`service.port`](./values.yaml#L874) | Service port — see also `config.port` | `5000` |
| [`service.trafficDistribution`](./values.yaml#L883) | Service [traffic distribution policy](https://kubernetes.io/docs/concepts/services-networking/service/#traffic-distribution) | `nil` |
| [`service.type`](./values.yaml#L871) | Service type | `"ClusterIP"` |

### Observability

| Key | Description | Default |
|-----|-------------|---------|
| [`observability`](./values.yaml#L652) | Observability settings |  |
| [`observability.log`](./values.yaml#L656) | Logs | [...](./values.yaml#L656) |
| [`observability.log.healthcheckLevel`](./values.yaml#L665) | `HEALTHCHECK_LOGLEVEL` — log level for health checks | `"debug"` |
| [`observability.log.level`](./values.yaml#L659) | `LOG_LEVEL` | `"info"` |
| [`observability.log.structured`](./values.yaml#L662) | `LOG_STRUCTURED` — enable structured logging in JSON format | `false` |
| [`observability.metrics`](./values.yaml#L700) | Metrics configuration | [...](./values.yaml#L700) |
| [`observability.metrics.customTags`](./values.yaml#L709) | Prometheus metrics endpoint settings | `namespace={{ .Release.Namespace }},app={{ include "document-engine.fullname" . }}` |
| [`observability.metrics.grafanaDashboard`](./values.yaml#L748) | Grafana dashboard | [...](./values.yaml#L748) |
| [`observability.metrics.grafanaDashboard.configMap`](./values.yaml#L756) | ConfigMap parameters | [...](./values.yaml#L756) |
| [`observability.metrics.grafanaDashboard.configMap.labels`](./values.yaml#L759) | ConfigMap labels | `{"grafana_dashboard":"1"}` |
| [`observability.metrics.grafanaDashboard.enabled`](./values.yaml#L752) | Enable Grafana dashboard. To work, requires Prometheus metrics enabled in `observability.metrics.prometheusEndpoint.enabled` | `false` |
| [`observability.metrics.grafanaDashboard.tags`](./values.yaml#L769) | Dashboard tags | `["Nutrient","document-engine"]` |
| [`observability.metrics.grafanaDashboard.title`](./values.yaml#L766) | Dashboard title | *generated* |
| [`observability.metrics.prometheusEndpoint.enabled`](./values.yaml#L713) | Enable Prometheus metrics endpoint, `ENABLE_PROMETHEUS` | `false` |
| [`observability.metrics.prometheusEndpoint.port`](./values.yaml#L716) | Port for the Prometheus metrics endpoint, `PROMETHEUS_PORT` | `10254` |
| [`observability.metrics.prometheusRule`](./values.yaml#L740) | Prometheus [PrometheusRule](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.PrometheusRule) Requires `observability.metrics.prometheusEndpoint.enabled` to be `true` | [...](./values.yaml#L740) |
| [`observability.metrics.serviceMonitor`](./values.yaml#L725) | Prometheus [ServiceMonitor](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.ServiceMonitor) Requires `observability.metrics.prometheusEndpoint.enabled` to be `true` | [...](./values.yaml#L725) |
| [`observability.metrics.statsd`](./values.yaml#L775) | StatsD parameters | [...](./values.yaml#L775) |
| [`observability.metrics.statsd.customTags`](./values.yaml#L788) | StatsD custom tags, `STATSD_CUSTOM_TAGS` | `` |
| [`observability.metrics.statsd.port`](./values.yaml#L784) | StatsD port, `STATSD_PORT` | `9125` |
| [`observability.opentelemetry`](./values.yaml#L669) | OpenTelemetry settings | [...](./values.yaml#L669) |
| [`observability.opentelemetry.enabled`](./values.yaml#L672) | Enable OpenTelemetry (`ENABLE_OPENTELEMETRY`), only tracing is currently supported | `false` |
| [`observability.opentelemetry.otelPropagators`](./values.yaml#L688) | `OTEL_PROPAGATORS`, propagators | `""` |
| [`observability.opentelemetry.otelResourceAttributes`](./values.yaml#L685) | `OTEL_RESOURCE_ATTRIBUTES`, resource attributes | `""` |
| [`observability.opentelemetry.otelServiceName`](./values.yaml#L682) | `OTEL_SERVICE_NAME`, service name | `""` |
| [`observability.opentelemetry.otelTracesSampler`](./values.yaml#L693) | `OTEL_TRACES_SAMPLER`, should normally not be touched to allow custom `parent_based` work, but something like `parentbased_traceidratio` may be considered | `""` |
| [`observability.opentelemetry.otelTracesSamplerArg`](./values.yaml#L696) | `OTEL_TRACES_SAMPLER_ARG`, argument for the sampler | `""` |
| [`observability.opentelemetry.otlpExporterEndpoint`](./values.yaml#L676) | https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/ `OTEL_EXPORTER_OTLP_ENDPOINT`, if not set, defaults to `http://localhost:4317` | `""` |
| [`observability.opentelemetry.otlpExporterProtocol`](./values.yaml#L679) | `OTEL_EXPORTER_OTLP_PROTOCOL`, if not set, defaults to `grpc` | `""` |

### Pod lifecycle

| Key | Description | Default |
|-----|-------------|---------|
| [`lifecycle`](./values.yaml#L1082) | [Lifecycle](https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/) | `map[]` |
| [`livenessProbe`](./values.yaml#L1052) | [Liveness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L1052) |
| [`readinessProbe`](./values.yaml#L1065) | [Readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L1065) |
| [`startupProbe`](./values.yaml#L1039) | [Startup probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L1039) |
| [`terminationGracePeriodSeconds`](./values.yaml#L1078) | [Termination grace period](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/). Should be greater than the longest expected request processing time (`config.requestTimeoutSeconds`). | `65` |

### Scheduling

| Key | Description | Default |
|-----|-------------|---------|
| [`affinity`](./values.yaml#L1137) | Node affinity | `{}` |
| [`autoscaling`](./values.yaml#L1090) | [Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) | [...](./values.yaml#L1090) |
| [`nodeSelector`](./values.yaml#L1134) | [Node selector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) | `{}` |
| [`podDisruptionBudget`](./values.yaml#L1127) | [Pod disruption budget](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) | [...](./values.yaml#L1127) |
| [`priorityClassName`](./values.yaml#L1146) | [Priority classs](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/) | `""` |
| [`replicaCount`](./values.yaml#L1115) | Number of replicas | `1` |
| [`resources`](./values.yaml#L1112) | [Resources](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) | `{}` |
| [`schedulerName`](./values.yaml#L1149) | [Scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/) | `""` |
| [`tolerations`](./values.yaml#L1140) | [Node tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) | `[]` |
| [`topologySpreadConstraints`](./values.yaml#L1143) | [Topology spread constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) | `[]` |
| [`updateStrategy`](./values.yaml#L1118) | [Update strategy](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy) | `{"rollingUpdate":{},"type":"RollingUpdate"}` |

### Storage resource definitions

| Key | Description | Default |
|-----|-------------|---------|
| [`cloudNativePG`](./values.yaml#L1154) | [CloudNativePG](https://cloudnative-pg.io/) resources | [...](./values.yaml#L1154) |
| [`cloudNativePG.clusterAnnotations`](./values.yaml#L1189) | Cluster annotations | `{}` |
| [`cloudNativePG.clusterLabels`](./values.yaml#L1186) | Cluster labels | `{}` |
| [`cloudNativePG.clusterName`](./values.yaml#L1166) | CloudNativePG custom Cluster name | `"{{ .Release.Name }}-postgres"` |
| [`cloudNativePG.clusterSpec`](./values.yaml#L1170) | CloudNativePG [cluster spec](https://cloudnative-pg.io/documentation/current/cloudnative-pg.v1/#postgresql-cnpg-io-v1-ClusterSpec) | [...](./values.yaml#L1170) |
| [`cloudNativePG.enabled`](./values.yaml#L1157) | Enable CloudNativePG resources | `false` |
| [`cloudNativePG.networkPolicy`](./values.yaml#L1198) | Network policy to allow access to the cluster | `{"enabled":true}` |
| [`cloudNativePG.operatorNamespace`](./values.yaml#L1160) | CloudNativePG operator namespace | `"cnpg-system"` |
| [`cloudNativePG.operatorReleaseName`](./values.yaml#L1163) | CloudNativePG operator release name | `"cloudnative-pg"` |
| [`cloudNativePG.superuserSecret`](./values.yaml#L1192) | Superuser secret to use with the cluster | `{"create":true,"password":"despair","username":"postgres"}` |

### Other Values

| Key | Description | Default |
|-----|-------------|---------|
| [`config.hoard.binaryCopyEnabled`](./values.yaml#L137) | `HOARD_BINARY_COPY_ENABLED` — internal parameter, do not change unless explicitly recommended by Nutrient support. | `true` |
| [`config.hoard.binaryCopyThreshold`](./values.yaml#L139) | `HOARD_BINARY_COPY_THRESHOLD` — internal parameter, do not change unless explicitly recommended by Nutrient support. | `2` |
| [`config.http2SharedRendering.checkinTimeoutMilliseconds`](./values.yaml#L150) | `HTTP2_SHARED_RENDERING_PROCESS_CHECKIN_TIMEOUT` — document processing daemon checkin timeout. Do not change unless explicitly recommended by Nutrient support. | `0` |
| [`config.http2SharedRendering.checkoutTimeoutMilliseconds`](./values.yaml#L153) | `HTTP2_SHARED_RENDERING_PROCESS_CHECKOUT_TIMEOUT` — document processing daemon checkout timeout. Do not change unless explicitly recommended by Nutrient support. | `5000` |
| [`revisionHistoryLimit`](./values.yaml#L1122) | [Revision history limit](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#clean-up-policy) | `10` |

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

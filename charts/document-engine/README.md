# Document Engine Helm chart

![Version: 5.0.2](https://img.shields.io/badge/Version-5.0.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.10.0](https://img.shields.io/badge/AppVersion-1.10.0-informational?style=flat-square)

Document Engine is a backend software for processing documents and powering automation workflows.

**Homepage:** <https://www.nutrient.io/sdk/document-engine>

* [Using this chart](#using-this-chart)
* [Integrations](#integrations)
  * [AWS ALB](#aws-alb-integration)
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
| https://charts.bitnami.com/bitnami | minio | 17.0.5 |
| https://charts.bitnami.com/bitnami | postgresql | 16.7.13 |
| https://charts.bitnami.com/bitnami | redis | 21.2.5 |

Schema is generated using [helm values schema json plugin](https://github.com/losisin/helm-values-schema-json).

`README.md` is generated with [helm-docs](https://github.com/norwoodj/helm-docs).

### Upgrade

> [!NOTE]
> Please consult the [changelog](/charts/document-engine/CHANGELOG.md)

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
| [`config.http2SharedRendering`](./values.yaml#L132) | Optimised rendering relying on HTTP/2 | [...](./values.yaml#L132) |
| [`config.http2SharedRendering.enabled`](./values.yaml#L135) | `HTTP2_SHARED_RENDERING_PROCESS_ENABLE` — enable shared rendering processes | `false` |
| [`config.ignoreInvalidAnnotations`](./values.yaml#L121) | `IGNORE_INVALID_ANNOTATIONS` | `true` |
| [`config.maxUploadSizeMegaBytes`](./values.yaml#L103) | `MAX_UPLOAD_SIZE_BYTES` in megabytes | `950` |
| [`config.minSearchQueryLength`](./values.yaml#L127) | `MIN_SEARCH_QUERY_LENGTH` | `3` |
| [`config.port`](./values.yaml#L147) | `PORT` for the Document Engine API | `5000` |
| [`config.proxy`](./values.yaml#L142) | Proxy settings, `HTTP_PROXY` amd `HTTPS_PROXY` | `{"http":"","https":""}` |
| [`config.readAnnotationBatchTimeoutSeconds`](./values.yaml#L100) | `READ_ANNOTATION_BATCH_TIMEOUT` in seconds | `20` |
| [`config.replaceSecretsFromEnv`](./values.yaml#L152) | `REPLACE_SECRETS_FROM_ENV` — whether to consider environment variables, values and secrets for `JWT_PUBLIC_KEY`, `SECRET_KEY_BASE` and `DASHBOARD_PASSWORD` | `true` |
| [`config.requestTimeoutSeconds`](./values.yaml#L88) | Full request timeout in seconds (`SERVER_REQUEST_TIMEOUT`). Should be lesser than `terminationGracePeriodSeconds`. | `60` |
| [`config.trustedProxies`](./values.yaml#L139) | `TRUSTED_PROXIES` — comma-separated list of IP addresses or IP address ranges of trusted proxies. Setting to `default` will use the default will use private IP ranges. | `"default"` |
| [`config.urlFetchTimeoutSeconds`](./values.yaml#L97) | `REMOTE_URL_FETCH_TIMEOUT` in seconds | `5` |
| [`config.workerPoolSize`](./values.yaml#L85) | `PSPDFKIT_WORKER_POOL_SIZE` | `16` |
| [`config.workerTimeoutSeconds`](./values.yaml#L91) | Document processing timeout in seconds (`PSPDFKIT_WORKER_TIMEOUT`). Should not be greater than `config.requestTimeoutSeconds`. | `60` |

### Certificate trust

| Key | Description | Default |
|-----|-------------|---------|
| [`certificateTrust`](./values.yaml#L157) | [Certificate trust](https://www.nutrient.io/guides/document-engine/configuration/certificate-trust/) |  |
| [`certificateTrust.customCertificates`](./values.yaml#L170) | ConfigMap and Secret references for trust configuration, stored in `/certificate-stores-custom` | `[]` |
| [`certificateTrust.digitalSignatures`](./values.yaml#L161) | CAs for digital signatures (`/certificate-stores/`) from ConfigMap and Secret resources. | `[]` |
| [`certificateTrust.downloaderTrustFileName`](./values.yaml#L180) | Override `DOWNLOADER_CERT_FILE_PATH` to set HTTP client trust. If empty, defaults to  Mozilla's CA bundle. | `""` |

### Database

| Key | Description | Default |
|-----|-------------|---------|
| [`database`](./values.yaml#L185) | Database |  |
| [`database.connections`](./values.yaml#L194) | `DATABASE_CONNECTIONS` | `20` |
| [`database.enabled`](./values.yaml#L188) | Persistent storage enabled | `true` |
| [`database.engine`](./values.yaml#L191) | Database engine: only `postgres` is currently supported | `"postgres"` |
| [`database.migrationJob`](./values.yaml#L258) | Database migration jobs. | [...](./values.yaml#L258) |
| [`database.migrationJob.enabled`](./values.yaml#L261) | It `true`, results in `ENABLE_DATABASE_MIGRATIONS=false` in the main Document Engine container | `false` |
| [`database.postgres`](./values.yaml#L199) | PostgreSQL database settings | [...](./values.yaml#L199) |
| [`database.postgres.adminPassword`](./values.yaml#L220) | `PG_ADMIN_PASSWORD` | `"despair"` |
| [`database.postgres.adminUsername`](./values.yaml#L217) | `PG_ADMIN_USER` | `"postgres"` |
| [`database.postgres.database`](./values.yaml#L208) | `PGDATABASE` | `"document-engine"` |
| [`database.postgres.externalAdminSecretName`](./values.yaml#L229) | External secret for administrative database credentials, used for migrations: `PG_ADMIN_USER` and `PG_ADMIN_PASSWORD` | `""` |
| [`database.postgres.externalSecretName`](./values.yaml#L225) | Use external secret for database credentials. `PGUSER` and `PGPASSWORD` must be provided and, if not defined: `PGDATABASE`, `PGHOST`, `PGPORT`, `PGSSL` | `""` |
| [`database.postgres.host`](./values.yaml#L202) | `PGHOST` | `"{{ .Release.Name }}-postgresql"` |
| [`database.postgres.password`](./values.yaml#L214) | `PGPASSWORD` | `"despair"` |
| [`database.postgres.port`](./values.yaml#L205) | `PGPORT` | `5432` |
| [`database.postgres.tls`](./values.yaml#L234) | TLS settings | [...](./values.yaml#L234) |
| [`database.postgres.tls.commonName`](./values.yaml#L247) | Common name for the certificate (`PGSSL_CERT_COMMON_NAME`), defaults to `PGHOST` value | `""` |
| [`database.postgres.tls.enabled`](./values.yaml#L237) | Enable TLS (`PGSSL`) | `false` |
| [`database.postgres.tls.hostVerify`](./values.yaml#L243) | Negated `PGSSL_DISABLE_HOSTNAME_VERIFY` | `true` |
| [`database.postgres.tls.trustBundle`](./values.yaml#L251) | Trust bundle for PostgreSQL, sets `PGSSL_CA_CERTS`, mutually exclusive with `trustFileName` and takes precedence | `""` |
| [`database.postgres.tls.trustFileName`](./values.yaml#L254) | Path from `certificateTrust.customCertificates`, wraps around `PGSSL_CA_CERT_PATH` | `""` |
| [`database.postgres.tls.verify`](./values.yaml#L240) | Negated `PGSSL_DISABLE_VERIFY` | `true` |
| [`database.postgres.username`](./values.yaml#L211) | `PGUSER` | `"de-user"` |

### Document lifecycle

| Key | Description | Default |
|-----|-------------|---------|
| [`documentLifecycle`](./values.yaml#L274) | Document lifecycle management |  |
| [`documentLifecycle.cleanupJob`](./values.yaml#L278) | Regular job to remove documents from the database. | [...](./values.yaml#L278) |
| [`documentLifecycle.cleanupJob.enabled`](./values.yaml#L281) | Enable the cleanup job | `false` |
| [`documentLifecycle.cleanupJob.image`](./values.yaml#L302) | Image used for running the cleanup job API calls | `{"pullPolicy":"IfNotPresent","repository":"curlimages/curl","tag":"8.14.1"}` |
| [`documentLifecycle.cleanupJob.keepHours`](./values.yaml#L287) | Documents TTL in hours | `24` |
| [`documentLifecycle.cleanupJob.persistentLike`](./values.yaml#L291) | Keep documents with IDs beginning with `persistent` indefinitely WARNING: does not currently work | `"persistent%"` |
| [`documentLifecycle.cleanupJob.schedule`](./values.yaml#L284) | Cleanup job schedule in cron format | `"13 * * * *"` |
| [`documentLifecycle.cleanupJob.serviceAccountName`](./values.yaml#L308) | Service account name to specify for the cleanup jobs | `""` |

### Asset storage

| Key | Description | Default |
|-----|-------------|---------|
| [`assetStorage`](./values.yaml#L319) | Everything about storing and caching assets |  |
| [`assetStorage.azure`](./values.yaml#L387) | Azure blob storage settings, in case `assetStorage.backendType` is set to `azure` | [...](./values.yaml#L387) |
| [`assetStorage.azure.container`](./values.yaml#L398) | `AZURE_STORAGE_DEFAULT_CONTAINER` | `""` |
| [`assetStorage.backendFallback`](./values.yaml#L334) | Asset storage fallback settings | [...](./values.yaml#L334) |
| [`assetStorage.backendFallback.enabled`](./values.yaml#L337) | `ENABLE_ASSET_STORAGE_FALLBACK` | `false` |
| [`assetStorage.backendFallback.enabledAzure`](./values.yaml#L346) | `ENABLE_ASSET_STORAGE_FALLBACK_AZURE` | `false` |
| [`assetStorage.backendFallback.enabledPostgres`](./values.yaml#L340) | `ENABLE_ASSET_STORAGE_FALLBACK_POSTGRES` | `false` |
| [`assetStorage.backendFallback.enabledS3`](./values.yaml#L343) | `ENABLE_ASSET_STORAGE_FALLBACK_S3` | `false` |
| [`assetStorage.backendType`](./values.yaml#L327) | Asset storage backend is only available if `database.enabled` is `true` Sets `ASSET_STORAGE_BACKEND`: `built-in`, `s3` or `azure` | `"built-in"` |
| [`assetStorage.fileUploadTimeoutSeconds`](./values.yaml#L330) | `FILE_UPLOAD_TIMEOUT_MS` in seconds | `30` |
| [`assetStorage.localCacheSizeMegabytes`](./values.yaml#L323) | Sets local asset storage value in megabytes Results in `ASSET_STORAGE_CACHE_SIZE` (in bytes) | `2000` |
| [`assetStorage.redis`](./values.yaml#L416) | Redis settings for caching and prerendering | [...](./values.yaml#L416) |
| [`assetStorage.redis.database`](./values.yaml#L434) | `REDIS_DATABASE` | `""` |
| [`assetStorage.redis.enabled`](./values.yaml#L419) | `USE_REDIS_CACHE` | `false` |
| [`assetStorage.redis.externalSecretName`](./values.yaml#L471) | External secret name. Must contain `REDIS_USERNAME` and `REDIS_PASSWORD` if they are needed, and _may_ set other values | `""` |
| [`assetStorage.redis.host`](./values.yaml#L428) | `REDIS_HOST` | `"{{ .Release.Name }}-redis-master"` |
| [`assetStorage.redis.password`](./values.yaml#L460) | `REDIS_PASSWORD` | `""` |
| [`assetStorage.redis.port`](./values.yaml#L431) | `REDIS_PORT` | `6379` |
| [`assetStorage.redis.sentinel`](./values.yaml#L439) | Redis Sentinel | [...](./values.yaml#L439) |
| [`assetStorage.redis.tls`](./values.yaml#L464) | TLS settings |  |
| [`assetStorage.redis.tls.enabled`](./values.yaml#L467) | Enable TLS (`REDIS_SSL`) | `false` |
| [`assetStorage.redis.ttlSeconds`](./values.yaml#L422) | `REDIS_TTL` | `86400000` |
| [`assetStorage.redis.useTtl`](./values.yaml#L425) | `USE_REDIS_TTL_FOR_PRERENDERING` | `true` |
| [`assetStorage.redis.username`](./values.yaml#L457) | `REDIS_USERNAME` | `""` |
| [`assetStorage.s3`](./values.yaml#L350) | S3 backend storage settings, in case `assetStorage.backendType` is set to `s3 | [...](./values.yaml#L350) |
| [`assetStorage.s3.bucket`](./values.yaml#L361) | `ASSET_STORAGE_S3_BUCKET` | `"document-engine-assets"` |
| [`assetStorage.s3.region`](./values.yaml#L364) | `ASSET_STORAGE_S3_REGION` | `"us-east-1"` |

### Digital signatures

| Key | Description | Default |
|-----|-------------|---------|
| [`documentSigningService`](./values.yaml#L476) | Signing service parameters |  |
| [`documentSigningService.cadesLevel`](./values.yaml#L502) | `DIGITAL_SIGNATURE_CADES_LEVEL` | `"b-lt"` |
| [`documentSigningService.certificateCheckTime`](./values.yaml#L505) | `DIGITAL_SIGNATURE_CERTIFICATE_CHECK_TIME` | `"current_time"` |
| [`documentSigningService.defaultSignatureLocation`](./values.yaml#L496) | `DEFAULT_SIGNATURE_LOCATION` | `"Head Quarters"` |
| [`documentSigningService.defaultSignatureReason`](./values.yaml#L492) | `DEFAULT_SIGNATURE_REASON` | `"approved"` |
| [`documentSigningService.defaultSignerName`](./values.yaml#L488) | `DEFAULT_SIGNER_NAME` | `"John Doe"` |
| [`documentSigningService.enabled`](./values.yaml#L479) | Enable signing service integration | `false` |
| [`documentSigningService.hashAlgorithm`](./values.yaml#L499) | `DIGITAL_SIGNATURE_HASH_ALGORITHM` | `"sha512"` |
| [`documentSigningService.timeoutSeconds`](./values.yaml#L485) | `SIGNING_SERVICE_TIMEOUT` in seconds | `10` |
| [`documentSigningService.timestampAuthority`](./values.yaml#L509) | Timestamp Authority (TSA) settings | [...](./values.yaml#L509) |
| [`documentSigningService.timestampAuthority.url`](./values.yaml#L512) | `TIMESTAMP_AUTHORITY_URL` | `"https://freetsa.org/"` |
| [`documentSigningService.url`](./values.yaml#L482) | `SIGNING_SERVICE_URL` | `"https://signing-thing.local/sign"` |

### Document conversion

| Key | Description | Default |
|-----|-------------|---------|
| [`documentConversion`](./values.yaml#L525) | Document conversion parameters |  |
| [`documentConversion.spreadsheetMaxContentHeightMm`](./values.yaml#L529) | Maximal spreadhseet content height in millimetres (`SPREADSHEET_MAX_CONTENT_HEIGHT_MM`). Defaults to `0` for unlimited height. | `0` |
| [`documentConversion.spreadsheetMaxContentWidthMm`](./values.yaml#L533) | Maximal spreadhseet content width in millimetres (`SPREADSHEET_MAX_CONTENT_WIDTH_MM`). Defaults to `0` for unlimited width. | `0` |

### Clustering

| Key | Description | Default |
|-----|-------------|---------|
| [`clustering`](./values.yaml#L538) | Clustering settings |  |
| [`clustering.enabled`](./values.yaml#L541) | `CLUSTERING_ENABLED`, enable clustering, only works when `replicaCount` is greater than 1 | `false` |
| [`clustering.method`](./values.yaml#L544) | `CLUSTERING_METHOD`, only `kubernetes_dns` is currently supported | `"kubernetes_dns"` |

### Dashboard

| Key | Description | Default |
|-----|-------------|---------|
| [`dashboard`](./values.yaml#L555) | Document Engine Dashboard settings |  |
| [`dashboard.auth`](./values.yaml#L562) | Dashboard authentication | [...](./values.yaml#L562) |
| [`dashboard.auth.externalSecret`](./values.yaml#L572) | Use an external secret for dashboard credentials | [...](./values.yaml#L572) |
| [`dashboard.auth.externalSecret.name`](./values.yaml#L575) | External secret name | `""` |
| [`dashboard.auth.externalSecret.passwordKey`](./values.yaml#L581) | Secret key name for the password | `"DASHBOARD_PASSWORD"` |
| [`dashboard.auth.externalSecret.usernameKey`](./values.yaml#L578) | Secret key name for the username | `"DASHBOARD_USERNAME"` |
| [`dashboard.auth.password`](./values.yaml#L568) | `DASHBOARD_PASSWORD` — will generate a random password if not set | `""` |
| [`dashboard.auth.username`](./values.yaml#L565) | `DASHBOARD_USERNAME` | `"admin"` |
| [`dashboard.enabled`](./values.yaml#L558) | Enable dashboard | `true` |

### Environment

| Key | Description | Default |
|-----|-------------|---------|
| [`extraEnvFrom`](./values.yaml#L770) | Extra environment variables from resources | `[]` |
| [`extraEnvs`](./values.yaml#L767) | Extra environment variables | `[]` |
| [`extraVolumeMounts`](./values.yaml#L776) | Additional volume mounts for Document Engine container | `[]` |
| [`extraVolumes`](./values.yaml#L773) | Additional volumes | `[]` |
| [`image`](./values.yaml#L727) | Image settings | [...](./values.yaml#L727) |
| [`imagePullSecrets`](./values.yaml#L734) | Pull secrets | `[]` |
| [`initContainers`](./values.yaml#L782) | Init containers | `[]` |
| [`podSecurityContext`](./values.yaml#L753) | Pod security context | `{}` |
| [`securityContext`](./values.yaml#L757) | Security context | `{}` |
| [`serviceAccount`](./values.yaml#L746) | ServiceAccount | [...](./values.yaml#L746) |
| [`sidecars`](./values.yaml#L779) | Additional containers | `[]` |

### Metadata

| Key | Description | Default |
|-----|-------------|---------|
| [`deploymentAnnotations`](./values.yaml#L792) | Deployment annotations | `{}` |
| [`deploymentExtraSelectorLabels`](./values.yaml#L795) | Additional label selector for the deployment | `{}` |
| [`fullnameOverride`](./values.yaml#L741) | Release full name override | `""` |
| [`nameOverride`](./values.yaml#L738) | Release name override | `""` |
| [`podAnnotations`](./values.yaml#L789) | Pod annotations | `{}` |
| [`podLabels`](./values.yaml#L786) | Pod labels | `{}` |

### Networking

| Key | Description | Default |
|-----|-------------|---------|
| [`extraIngresses`](./values.yaml#L846) | Additional ingresses, e.g. for the dashboard | [...](./values.yaml#L846) |
| [`ingress`](./values.yaml#L811) | Ingress | [...](./values.yaml#L811) |
| [`ingress.annotations`](./values.yaml#L820) | Ingress annotations | `{}` |
| [`ingress.className`](./values.yaml#L817) | Ingress class name | `""` |
| [`ingress.enabled`](./values.yaml#L814) | Enable ingress | `false` |
| [`ingress.hosts`](./values.yaml#L823) | Hosts | `[]` |
| [`ingress.tls`](./values.yaml#L837) | Ingress TLS section | `[]` |
| [`networkPolicy`](./values.yaml#L863) | [Network policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/) | [...](./values.yaml#L863) |
| [`networkPolicy.allowExternal`](./values.yaml#L871) | Allow access from anywhere | `true` |
| [`networkPolicy.allowExternalEgress`](./values.yaml#L895) | Allow the pod to access any range of port and all destinations. | `true` |
| [`networkPolicy.enabled`](./values.yaml#L866) | Enable network policy | `true` |
| [`networkPolicy.extraEgress`](./values.yaml#L898) | Extra egress rules | `[]` |
| [`networkPolicy.extraIngress`](./values.yaml#L874) | Additional ingress rules | `[]` |
| [`networkPolicy.ingressMatchSelectorLabels`](./values.yaml#L889) | Allow traffic from other namespaces | `[]` |
| [`service`](./values.yaml#L800) | Service | [...](./values.yaml#L800) |
| [`service.port`](./values.yaml#L806) | Service port — see also `config.port` | `5000` |
| [`service.type`](./values.yaml#L803) | Service type | `"ClusterIP"` |

### Observability

| Key | Description | Default |
|-----|-------------|---------|
| [`observability`](./values.yaml#L586) | Observability settings |  |
| [`observability.log`](./values.yaml#L590) | Logs | [...](./values.yaml#L590) |
| [`observability.log.healthcheckLevel`](./values.yaml#L596) | `HEALTHCHECK_LOGLEVEL` — log level for health checks | `"debug"` |
| [`observability.log.level`](./values.yaml#L593) | `LOG_LEVEL` | `"info"` |
| [`observability.metrics`](./values.yaml#L631) | Metrics configuration | [...](./values.yaml#L631) |
| [`observability.metrics.customTags`](./values.yaml#L640) | Prometheus metrics endpoint settings | `namespace={{ .Release.Namespace }},app={{ include "document-engine.fullname" . }}` |
| [`observability.metrics.grafanaDashboard`](./values.yaml#L679) | Grafana dashboard | [...](./values.yaml#L679) |
| [`observability.metrics.grafanaDashboard.allNamespaces`](./values.yaml#L705) | Whether to cover all namespaces | `false` |
| [`observability.metrics.grafanaDashboard.configMap`](./values.yaml#L687) | ConfigMap parameters | [...](./values.yaml#L687) |
| [`observability.metrics.grafanaDashboard.configMap.labels`](./values.yaml#L690) | ConfigMap labels | `{"grafana_dashboard":"1"}` |
| [`observability.metrics.grafanaDashboard.enabled`](./values.yaml#L683) | Enable Grafana dashboard. To work, requires Prometheus metrics enabled in `observability.metrics.prometheusEndpoint.enabled` | `false` |
| [`observability.metrics.grafanaDashboard.tags`](./values.yaml#L700) | Dashboard tags | `["Nutrient","document-engine"]` |
| [`observability.metrics.grafanaDashboard.title`](./values.yaml#L697) | Dashboard title | *generated* |
| [`observability.metrics.prometheusEndpoint.enabled`](./values.yaml#L644) | Enable Prometheus metrics endpoint, `ENABLE_PROMETHEUS` | `false` |
| [`observability.metrics.prometheusEndpoint.port`](./values.yaml#L647) | Port for the Prometheus metrics endpoint, `PROMETHEUS_PORT` | `10254` |
| [`observability.metrics.prometheusRule`](./values.yaml#L671) | Prometheus [PrometheusRule](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.PrometheusRule) Requires `observability.metrics.prometheusEndpoint.enabled` to be `true` | [...](./values.yaml#L671) |
| [`observability.metrics.serviceMonitor`](./values.yaml#L656) | Prometheus [ServiceMonitor](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.ServiceMonitor) Requires `observability.metrics.prometheusEndpoint.enabled` to be `true` | [...](./values.yaml#L656) |
| [`observability.metrics.statsd`](./values.yaml#L709) | StatsD parameters | [...](./values.yaml#L709) |
| [`observability.metrics.statsd.customTags`](./values.yaml#L722) | StatsD custom tags, `STATSD_CUSTOM_TAGS` | `` |
| [`observability.metrics.statsd.port`](./values.yaml#L718) | StatsD port, `STATSD_PORT` | `9125` |
| [`observability.opentelemetry`](./values.yaml#L600) | OpenTelemetry settings | [...](./values.yaml#L600) |
| [`observability.opentelemetry.enabled`](./values.yaml#L603) | Enable OpenTelemetry (`ENABLE_OPENTELEMETRY`), only tracing is currently supported | `false` |
| [`observability.opentelemetry.otelPropagators`](./values.yaml#L619) | `OTEL_PROPAGATORS`, propagators | `""` |
| [`observability.opentelemetry.otelResourceAttributes`](./values.yaml#L616) | `OTEL_RESOURCE_ATTRIBUTES`, resource attributes | `""` |
| [`observability.opentelemetry.otelServiceName`](./values.yaml#L613) | `OTEL_SERVICE_NAME`, service name | `""` |
| [`observability.opentelemetry.otelTracesSampler`](./values.yaml#L624) | `OTEL_TRACES_SAMPLER`, should normally not be touched to allow custom `parent_based` work, but something like `parentbased_traceidratio` may be considered | `""` |
| [`observability.opentelemetry.otelTracesSamplerArg`](./values.yaml#L627) | `OTEL_TRACES_SAMPLER_ARG`, argument for the sampler | `""` |
| [`observability.opentelemetry.otlpExporterEndpoint`](./values.yaml#L607) | https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/ `OTEL_EXPORTER_OTLP_ENDPOINT`, if not set, defaults to `http://localhost:4317` | `""` |
| [`observability.opentelemetry.otlpExporterProtocol`](./values.yaml#L610) | `OTEL_EXPORTER_OTLP_PROTOCOL`, if not set, defaults to `grpc` | `""` |

### Pod lifecycle

| Key | Description | Default |
|-----|-------------|---------|
| [`lifecycle`](./values.yaml#L958) | [Lifecycle](https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/) | `map[]` |
| [`livenessProbe`](./values.yaml#L928) | [Liveness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L928) |
| [`readinessProbe`](./values.yaml#L941) | [Readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L941) |
| [`startupProbe`](./values.yaml#L915) | [Startup probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L915) |
| [`terminationGracePeriodSeconds`](./values.yaml#L954) | [Termination grace period](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/). Should be greater than the longest expected request processing time (`config.requestTimeoutSeconds`). | `65` |

### Scheduling

| Key | Description | Default |
|-----|-------------|---------|
| [`affinity`](./values.yaml#L1013) | Node affinity | `{}` |
| [`autoscaling`](./values.yaml#L966) | [Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) | [...](./values.yaml#L966) |
| [`nodeSelector`](./values.yaml#L1010) | [Node selector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) | `{}` |
| [`podDisruptionBudget`](./values.yaml#L1003) | [Pod disruption budget](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) | [...](./values.yaml#L1003) |
| [`priorityClassName`](./values.yaml#L1022) | [Priority classs](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/) | `""` |
| [`replicaCount`](./values.yaml#L991) | Number of replicas | `1` |
| [`resources`](./values.yaml#L988) | [Resources](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) | `{}` |
| [`schedulerName`](./values.yaml#L1025) | [Scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/) | `""` |
| [`tolerations`](./values.yaml#L1016) | [Node tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) | `[]` |
| [`topologySpreadConstraints`](./values.yaml#L1019) | [Topology spread constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) | `[]` |
| [`updateStrategy`](./values.yaml#L994) | [Update strategy](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy) | `{"rollingUpdate":{},"type":"RollingUpdate"}` |

### Chart dependencies

| Key | Description | Default |
|-----|-------------|---------|
| [`minio`](./values.yaml#L1052) | [External MinIO chart](https://github.com/bitnami/charts/tree/main/bitnami/minio) | [...](./values.yaml#L1052) |
| [`postgresql`](./values.yaml#L1030) | [External PostgreSQL database chart](https://github.com/bitnami/charts/tree/main/bitnami/postgresql) | [...](./values.yaml#L1030) |
| [`redis`](./values.yaml#L1064) | [External Redis chart](https://github.com/bitnami/charts/tree/main/bitnami/redis) | [...](./values.yaml#L1064) |

### Other Values

| Key | Description | Default |
|-----|-------------|---------|
| [`revisionHistoryLimit`](./values.yaml#L998) | [Revision history limit](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#clean-up-policy) | `10` |

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

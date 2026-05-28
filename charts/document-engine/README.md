# Document Engine Helm chart

![Version: 8.4.0](https://img.shields.io/badge/Version-8.4.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

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
  * [Gateway API](#gateway-api)
    * [AWS ALB Controller with Gateway API](#aws-alb-controller-with-gateway-api)
    * [AWS VPC Lattice](#aws-vpc-lattice)
  * [CloudNativePG operator](#cloudnativepg-operator)
* [Values](#values)
  * [Document Engine License](#document-engine-license)
  * [API authentication](#api-authentication)
  * [Configuration options](#configuration-options)
  * [Certificate trust](#certificate-trust)
  * [Database](#database)
  * [Document lifecycle](#document-lifecycle)
  * [Asset storage](#asset-storage)
  * [Statefulness](#statefulness)
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

In addition to the managed services (Amazon S3, Google Cloud Storage, many others), there are also options for self-hosting, including, but not limited to [Ceph](https://ceph.io/en/), [Garage](https://garagehq.deuxfleurs.fr/).

The latter is a lightweight way to implement S3-compatible buckets in a vendor-agnostic way.
However, this chart does not attempt to manage Garage resources directly.

## Rendering cache

Rendering of frequently accessed files can be optimised using [Redis cache](https://www.nutrient.io/guides/document-engine/configuration/cache/).

Public cloud vendors offer managed services (e.g., Amazon ElastiCache),
but there are also well known open source alternatives for Redis clusters operations,
e.g., [Redis operator](https://ot-container-kit.github.io/redis-operator/guide/).

## Persistent local cache

It is possible to improve "warm up" time of restarted and new Document Engine pods by enabling [statefulness](#statefulness).
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

### Gateway API

As an alternative to Ingress, the chart supports the [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/) by creating [HTTPRoute](https://gateway-api.sigs.k8s.io/api-types/httproute/) and optionally [Gateway](https://gateway-api.sigs.k8s.io/api-types/gateway/) resources.

The Gateway API separates infrastructure concerns (the `Gateway` resource, typically managed by platform teams) from application routing (the `HTTPRoute`, managed by this chart). Both `ingress` and `gateway` can be enabled simultaneously.

> [!NOTE]
> TLS termination in Gateway API is configured on the Gateway Listener, not on the HTTPRoute. This differs from Ingress, where TLS is specified per-Ingress resource.

Basic configuration (referencing an existing Gateway):

```yaml
gateway:
  enabled: true
  parentRefs:
    - name: my-gateway
      namespace: gateway-infra
      sectionName: https
  hostnames:
    - document-engine.example.com
```

With custom routing rules:

```yaml
gateway:
  enabled: true
  parentRefs:
    - name: my-gateway
  hostnames:
    - document-engine.example.com
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /api
    - matches:
        - path:
            type: PathPrefix
            value: /dashboard
```

Creating a Gateway resource alongside the HTTPRoute (the HTTPRoute auto-wires `parentRefs` when `gateway.gateway.enabled` is true and `parentRefs` is empty):

```yaml
gateway:
  enabled: true
  hostnames:
    - document-engine.example.com
  gateway:
    enabled: true
    gatewayClassName: my-gateway-class
    listeners:
      - name: https
        protocol: HTTPS
        port: 443
        tls:
          mode: Terminate
          certificateRefs:
            - name: my-cert
```

Additional HTTPRoutes (e.g., for the dashboard) can be created using `gateway.extraHTTPRoutes`, following the same pattern as `extraIngresses`.

#### AWS ALB Controller with Gateway API

The [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/) supports Gateway API and allows managing ALBs through `Gateway` and `HTTPRoute` resources instead of Ingress annotations. Refer to the [Current Support](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/gateway/gateway/#current-support) matrix for minimum supported versions (for L7 `HTTPRoute`, use a release with `ALBGatewayAPI` support).

A `LoadBalancerConfiguration` CRD (from the ALB controller) is used to pass load balancer settings that were previously specified as Ingress annotations. For HTTPS listeners, configure certificates in `LoadBalancerConfiguration.spec.listenerConfigurations` (for example via `defaultCertificate`) instead of `certificateRefs` on the Gateway listener. Refer to the [ALB Gateway API documentation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/gateway/gateway/) for full details.

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
gateway:
  enabled: true
  hostnames:
    - document-engine.example.com
  gateway:
    enabled: true
    gatewayClassName: amazon-alb
    listeners:
      - name: http
        protocol: HTTP
        port: 80
      - name: https
        protocol: HTTPS
        port: 443
    infrastructure:
      parametersRef:
        group: gateway.k8s.aws
        kind: LoadBalancerConfiguration
        name: document-engine-lbconfig
```

The `LoadBalancerConfiguration` resource is not managed by this chart and must be created separately:

```yaml
apiVersion: gateway.k8s.aws/v1beta1
kind: LoadBalancerConfiguration
metadata:
  name: document-engine-lbconfig
spec:
  scheme: internet-facing
  listenerConfigurations:
    - protocolPort: HTTPS:443
      defaultCertificate: arn:aws:acm:us-east-1:123456789012:certificate/abc-123
  loadBalancerAttributes:
    - key: routing.http2.enabled
      value: "true"
    - key: idle_timeout.timeout_seconds
      value: "600"
  targetGroupAttributes:
    - key: deregistration_delay.timeout_seconds
      value: "300"
    - key: load_balancing.algorithm.type
      value: least_outstanding_requests
  healthCheck:
    path: /healthcheck
    intervalSeconds: 5
    timeoutSeconds: 2
    healthyThresholdCount: 2
    successCodes: "200"
```

#### AWS VPC Lattice

[Amazon VPC Lattice](https://aws.amazon.com/vpc/lattice/) is a service-to-service networking layer. The [AWS Gateway API Controller](https://www.gateway-api-controller.eks.aws.dev/) implements Gateway API for VPC Lattice, using `amazon-vpc-lattice` as the GatewayClass.

> [!NOTE]
> VPC Lattice operates at the service network level and does not provision traditional load balancers. Some Gateway API fields (e.g., `addresses`, `infrastructure`) are not applicable.

```yaml
gateway:
  enabled: true
  hostnames:
    - document-engine.example.com
  gateway:
    enabled: true
    gatewayClassName: amazon-vpc-lattice
    listeners:
      - name: https
        protocol: HTTPS
        port: 443
        tls:
          mode: Terminate
          options:
            application-networking.k8s.aws/certificate-arn: arn:aws:acm:us-east-1:123456789012:certificate/abc-123
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
| [`config.allowDocumentGeneration`](./values.yaml#L127) | `ALLOW_DOCUMENT_GENERATION` | `true` |
| [`config.allowDocumentUploads`](./values.yaml#L121) | `ALLOW_DOCUMENT_UPLOADS` | `true` |
| [`config.allowRemoteAssetsInGeneration`](./values.yaml#L130) | `ALLOW_REMOTE_ASSETS_IN_GENERATION` | `true` |
| [`config.allowRemoteDocuments`](./values.yaml#L124) | `ALLOW_REMOTE_DOCUMENTS` | `true` |
| [`config.asyncJobsTtlSeconds`](./values.yaml#L118) | `ASYNC_JOBS_TTL` | `172800` |
| [`config.automaticLinkExtraction`](./values.yaml#L136) | `AUTOMATIC_LINK_EXTRACTION` | `false` |
| [`config.daemonReadTimeoutSeconds`](./values.yaml#L100) | `PSPDFKITD_READ_TIMEOUT` in seconds | `120` |
| [`config.daemonWriteTimeoutSeconds`](./values.yaml#L103) | `PSPDFKITD_WRITE_TIMEOUT` in seconds | `10` |
| [`config.generationTimeoutSeconds`](./values.yaml#L106) | `PDF_GENERATION_TIMEOUT` in seconds | `20` |
| [`config.hoard`](./values.yaml#L149) | Hoard — internal caching service parameters | [...](./values.yaml#L149) |
| [`config.hoard.maxSizeMegaBytes`](./values.yaml#L152) | `HOARD_MAX_SIZE` — maximum size in millions of bytes | `100` |
| [`config.http2SharedRendering`](./values.yaml#L161) | Optimised rendering relying on HTTP/2 | [...](./values.yaml#L161) |
| [`config.http2SharedRendering.enabled`](./values.yaml#L164) | `HTTP2_SHARED_RENDERING_PROCESS_ENABLE` — enable shared rendering processes | `false` |
| [`config.ignoreInvalidAnnotations`](./values.yaml#L133) | `IGNORE_INVALID_ANNOTATIONS` | `true` |
| [`config.maxUploadSizeMegaBytes`](./values.yaml#L115) | `MAX_UPLOAD_SIZE_BYTES` in megabytes | `950` |
| [`config.minSearchQueryLength`](./values.yaml#L139) | `MIN_SEARCH_QUERY_LENGTH` | `3` |
| [`config.port`](./values.yaml#L182) | `PORT` for the Document Engine API | `5000` |
| [`config.proxy`](./values.yaml#L177) | Proxy settings, `HTTP_PROXY` and `HTTPS_PROXY` | `{"http":"","https":""}` |
| [`config.readAnnotationBatchTimeoutSeconds`](./values.yaml#L112) | `READ_ANNOTATION_BATCH_TIMEOUT` in seconds | `20` |
| [`config.replaceSecretsFromEnv`](./values.yaml#L187) | `REPLACE_SECRETS_FROM_ENV` — whether to consider environment variables, values and secrets for `JWT_PUBLIC_KEY`, `SECRET_KEY_BASE` and `DASHBOARD_PASSWORD` | `true` |
| [`config.requestTimeoutSeconds`](./values.yaml#L88) | Full request timeout in seconds (`SERVER_REQUEST_TIMEOUT`). Should be lesser than `terminationGracePeriodSeconds`. | `60` |
| [`config.tileMaxScale`](./values.yaml#L144) | `TILE_MAX_SCALE` — maximum allowed tile scale, calculated as requested tile size divided by actual page size. Must be greater than 1. When unset, no limit is enforced. | `unlimited` |
| [`config.trustedProxies`](./values.yaml#L174) | `TRUSTED_PROXIES` — comma-separated list of IP addresses or IP address ranges of trusted proxies. Setting to `default` will use private IP ranges. | `"default"` |
| [`config.urlFetchTimeoutSeconds`](./values.yaml#L109) | `REMOTE_URL_FETCH_TIMEOUT` in seconds | `5` |
| [`config.workerPoolMaxRestarts`](./values.yaml#L94) | Maximum number of restarts (`PSPDFKIT_WORKER_POOL_MAX_RESTARTS`) before supervisor starts throttling them. | `20` |
| [`config.workerPoolMaxSeconds`](./values.yaml#L97) | Time window in which the supervisor monitors the number of restarts (`PSPDFKIT_WORKER_POOL_MAX_SECONDS`). | `60` |
| [`config.workerPoolSize`](./values.yaml#L85) | `PSPDFKIT_WORKER_POOL_SIZE` | `16` |
| [`config.workerTimeoutSeconds`](./values.yaml#L91) | Document processing timeout in seconds (`PSPDFKIT_WORKER_TIMEOUT`). Should not be greater than `config.requestTimeoutSeconds`. | `60` |

### Certificate trust

| Key | Description | Default |
|-----|-------------|---------|
| [`certificateTrust`](./values.yaml#L192) | [Certificate trust](https://www.nutrient.io/guides/document-engine/configuration/certificate-trust/) |  |
| [`certificateTrust.customCertificates`](./values.yaml#L205) | ConfigMap and Secret references for trust configuration, stored in `/certificate-stores-custom` | `[]` |
| [`certificateTrust.digitalSignatures`](./values.yaml#L196) | CAs for digital signatures (`/certificate-stores/`) from ConfigMap and Secret resources. | `[]` |
| [`certificateTrust.downloaderTrustFileName`](./values.yaml#L215) | Override `DOWNLOADER_CERT_FILE_PATH` to set HTTP client trust. If empty, defaults to  Mozilla's CA bundle. | `""` |

### Database

| Key | Description | Default |
|-----|-------------|---------|
| [`database`](./values.yaml#L220) | Database |  |
| [`database.connections`](./values.yaml#L229) | `DATABASE_CONNECTIONS` | `20` |
| [`database.enabled`](./values.yaml#L223) | Persistent storage enabled | `true` |
| [`database.engine`](./values.yaml#L226) | Database engine: only `postgres` is currently supported | `"postgres"` |
| [`database.migrationJob`](./values.yaml#L293) | Database migration jobs. | [...](./values.yaml#L293) |
| [`database.migrationJob.enabled`](./values.yaml#L296) | It `true`, results in `ENABLE_DATABASE_MIGRATIONS=false` in the main Document Engine container | `false` |
| [`database.postgres`](./values.yaml#L234) | PostgreSQL database settings | [...](./values.yaml#L234) |
| [`database.postgres.adminPassword`](./values.yaml#L255) | `PG_ADMIN_PASSWORD` | `"despair"` |
| [`database.postgres.adminUsername`](./values.yaml#L252) | `PG_ADMIN_USER` | `"postgres"` |
| [`database.postgres.database`](./values.yaml#L243) | `PGDATABASE` | `"document-engine"` |
| [`database.postgres.externalAdminSecretName`](./values.yaml#L264) | External secret for administrative database credentials, used for migrations: `PG_ADMIN_USER` and `PG_ADMIN_PASSWORD` | `""` |
| [`database.postgres.externalSecretName`](./values.yaml#L260) | Use external secret for database credentials. `PGUSER` and `PGPASSWORD` must be provided and, if not defined: `PGDATABASE`, `PGHOST`, `PGPORT`, `PGSSL` | `""` |
| [`database.postgres.host`](./values.yaml#L237) | `PGHOST`, if not set, and `cloudNativePG.enabled`, will rely on the Cluster | `""` |
| [`database.postgres.password`](./values.yaml#L249) | `PGPASSWORD` | `"despair"` |
| [`database.postgres.port`](./values.yaml#L240) | `PGPORT` | `5432` |
| [`database.postgres.tls`](./values.yaml#L269) | TLS settings | [...](./values.yaml#L269) |
| [`database.postgres.tls.commonName`](./values.yaml#L282) | Common name for the certificate (`PGSSL_CERT_COMMON_NAME`), defaults to `PGHOST` value | `""` |
| [`database.postgres.tls.enabled`](./values.yaml#L272) | Enable TLS (`PGSSL`) | `false` |
| [`database.postgres.tls.hostVerify`](./values.yaml#L278) | Negated `PGSSL_DISABLE_HOSTNAME_VERIFY` | `true` |
| [`database.postgres.tls.trustBundle`](./values.yaml#L286) | Trust bundle for PostgreSQL, sets `PGSSL_CA_CERTS`, mutually exclusive with `trustFileName` and takes precedence | `""` |
| [`database.postgres.tls.trustFileName`](./values.yaml#L289) | Path from `certificateTrust.customCertificates`, wraps around `PGSSL_CA_CERT_PATH` | `""` |
| [`database.postgres.tls.verify`](./values.yaml#L275) | Negated `PGSSL_DISABLE_VERIFY` | `true` |
| [`database.postgres.username`](./values.yaml#L246) | `PGUSER` | `"postgres"` |

### Document lifecycle

| Key | Description | Default |
|-----|-------------|---------|
| [`documentLifecycle`](./values.yaml#L309) | Document lifecycle management |  |
| [`documentLifecycle.bulkDocumentDeletionEnabled`](./values.yaml#L312) | `ENABLE_BULK_DOCUMENT_DELETION`: enable `/api/async/delete_documents` API endpoint | `false` |
| [`documentLifecycle.expirationJob`](./values.yaml#L316) | Regular job to remove documents from the database, requires `documentLifecycle.bulkDocumentDeletionEnabled` to be `true` | [...](./values.yaml#L316) |
| [`documentLifecycle.expirationJob.deletionPrefix`](./values.yaml#L329) | Only delete documents with IDs beginning with this prefix. Leave empty to delete all documents matching the time filter. | `"ephemeral"` |
| [`documentLifecycle.expirationJob.enabled`](./values.yaml#L319) | Enable the document expiration job | `false` |
| [`documentLifecycle.expirationJob.keepHours`](./values.yaml#L325) | Documents TTL in hours | `24` |
| [`documentLifecycle.expirationJob.schedule`](./values.yaml#L322) | Expiration job schedule in cron format | `"13 * * * *"` |
| [`documentLifecycle.expirationJob.serviceAccountName`](./values.yaml#L340) | Service account name to specify for the expiration jobs | `""` |

### Asset storage

| Key | Description | Default |
|-----|-------------|---------|
| [`assetStorage`](./values.yaml#L351) | Everything about storing and caching assets |  |
| [`assetStorage.azure`](./values.yaml#L423) | Azure blob storage settings, in case `assetStorage.backendType` is set to `azure` | [...](./values.yaml#L423) |
| [`assetStorage.azure.container`](./values.yaml#L434) | `AZURE_STORAGE_DEFAULT_CONTAINER` | `""` |
| [`assetStorage.backendFallback`](./values.yaml#L370) | Asset storage fallback settings | [...](./values.yaml#L370) |
| [`assetStorage.backendFallback.enabled`](./values.yaml#L373) | `ENABLE_ASSET_STORAGE_FALLBACK` | `false` |
| [`assetStorage.backendFallback.enabledAzure`](./values.yaml#L382) | `ENABLE_ASSET_STORAGE_FALLBACK_AZURE` | `false` |
| [`assetStorage.backendFallback.enabledPostgres`](./values.yaml#L376) | `ENABLE_ASSET_STORAGE_FALLBACK_POSTGRES` | `false` |
| [`assetStorage.backendFallback.enabledS3`](./values.yaml#L379) | `ENABLE_ASSET_STORAGE_FALLBACK_S3` | `false` |
| [`assetStorage.backendType`](./values.yaml#L363) | Asset storage backend is only available if `database.enabled` is `true` Sets `ASSET_STORAGE_BACKEND`: `built-in`, `s3` or `azure` | `"built-in"` |
| [`assetStorage.fileUploadTimeoutSeconds`](./values.yaml#L366) | `FILE_UPLOAD_TIMEOUT_MS` in seconds | `30` |
| [`assetStorage.localCacheSizeMegabytes`](./values.yaml#L355) | Sets local asset storage value in megabytes Results in `ASSET_STORAGE_CACHE_SIZE` (in bytes) | `2000` |
| [`assetStorage.localCacheTimeoutSeconds`](./values.yaml#L359) | Sets local asset storage cache timeout in seconds Results in `ASSET_STORAGE_CACHE_TIMEOUT` (in milliseconds) | `5` |
| [`assetStorage.redis`](./values.yaml#L452) | Redis settings for caching and prerendering | [...](./values.yaml#L452) |
| [`assetStorage.redis.database`](./values.yaml#L470) | `REDIS_DATABASE` | `""` |
| [`assetStorage.redis.enabled`](./values.yaml#L455) | `USE_REDIS_CACHE` | `false` |
| [`assetStorage.redis.externalSecretName`](./values.yaml#L507) | External secret name. Must contain `REDIS_USERNAME` and `REDIS_PASSWORD` if they are needed, and _may_ set other values | `""` |
| [`assetStorage.redis.host`](./values.yaml#L464) | `REDIS_HOST` | `"{{ .Release.Name }}-redis-master"` |
| [`assetStorage.redis.password`](./values.yaml#L496) | `REDIS_PASSWORD` | `""` |
| [`assetStorage.redis.port`](./values.yaml#L467) | `REDIS_PORT` | `6379` |
| [`assetStorage.redis.sentinel`](./values.yaml#L475) | Redis Sentinel | [...](./values.yaml#L475) |
| [`assetStorage.redis.tls`](./values.yaml#L500) | TLS settings |  |
| [`assetStorage.redis.tls.enabled`](./values.yaml#L503) | Enable TLS (`REDIS_SSL`) | `false` |
| [`assetStorage.redis.ttlSeconds`](./values.yaml#L461) | `REDIS_TTL` Time to live in seconds | `86400` |
| [`assetStorage.redis.useTtl`](./values.yaml#L458) | `USE_REDIS_TTL_FOR_PRERENDERING` | `true` |
| [`assetStorage.redis.username`](./values.yaml#L493) | `REDIS_USERNAME` | `""` |
| [`assetStorage.s3`](./values.yaml#L386) | S3 backend storage settings, in case `assetStorage.backendType` is set to `s3 | [...](./values.yaml#L386) |
| [`assetStorage.s3.bucket`](./values.yaml#L397) | `ASSET_STORAGE_S3_BUCKET` | `"document-engine-assets"` |
| [`assetStorage.s3.region`](./values.yaml#L400) | `ASSET_STORAGE_S3_REGION` | `"us-east-1"` |

### Statefulness

| Key | Description | Default |
|-----|-------------|---------|
| [`persistence`](./values.yaml#L525) | Persistent storage settings for StatefulSet pods. Only used when `workloadType` is `StatefulSet`. | [...](./values.yaml#L525) |
| [`persistence.accessModes`](./values.yaml#L531) | PVC access modes | `["ReadWriteOnce"]` |
| [`persistence.annotations`](./values.yaml#L541) | Annotations for each PVC | `{}` |
| [`persistence.mountPath`](./values.yaml#L538) | Mount path inside the container | `"/srv/pspdfkit/assets"` |
| [`persistence.selectorLabels`](./values.yaml#L544) | Selector labels for PVCs | `{}` |
| [`persistence.size`](./values.yaml#L535) | PVC storage size | `"10Gi"` |
| [`persistence.storageClassName`](./values.yaml#L528) | Storage class for PVCs. Empty string uses cluster default. | `"standard"` |
| [`podManagementPolicy`](./values.yaml#L519) | Pod management policy for StatefulSet: `OrderedReady` or `Parallel`. Only used when `workloadType` is `StatefulSet`. | `"OrderedReady"` |
| [`workloadType`](./values.yaml#L514) | Workload type: `Deployment` or `StatefulSet`. When `StatefulSet`, persistent storage is provisioned per pod via volumeClaimTemplates. **Note:** Switching an existing release from Deployment to StatefulSet requires deleting the existing Deployment first, as Kubernetes cannot change a resource kind in-place. | `"Deployment"` |

### Digital signatures

| Key | Description | Default |
|-----|-------------|---------|
| [`documentSigningService`](./values.yaml#L549) | Signing service parameters |  |
| [`documentSigningService.cadesLevel`](./values.yaml#L575) | `DIGITAL_SIGNATURE_CADES_LEVEL` | `"b-lt"` |
| [`documentSigningService.certificateCheckTime`](./values.yaml#L578) | `DIGITAL_SIGNATURE_CERTIFICATE_CHECK_TIME` | `"current_time"` |
| [`documentSigningService.defaultSignatureLocation`](./values.yaml#L569) | `DEFAULT_SIGNATURE_LOCATION` | `"Head Quarters"` |
| [`documentSigningService.defaultSignatureReason`](./values.yaml#L565) | `DEFAULT_SIGNATURE_REASON` | `"approved"` |
| [`documentSigningService.defaultSignerName`](./values.yaml#L561) | `DEFAULT_SIGNER_NAME` | `"John Doe"` |
| [`documentSigningService.enabled`](./values.yaml#L552) | Enable signing service integration | `false` |
| [`documentSigningService.hashAlgorithm`](./values.yaml#L572) | `DIGITAL_SIGNATURE_HASH_ALGORITHM` | `"sha512"` |
| [`documentSigningService.timeoutSeconds`](./values.yaml#L558) | `SIGNING_SERVICE_TIMEOUT` in seconds | `10` |
| [`documentSigningService.timestampAuthority`](./values.yaml#L582) | Timestamp Authority (TSA) settings | [...](./values.yaml#L582) |
| [`documentSigningService.timestampAuthority.url`](./values.yaml#L585) | `TIMESTAMP_AUTHORITY_URL` | `"https://freetsa.org/"` |
| [`documentSigningService.url`](./values.yaml#L555) | `SIGNING_SERVICE_URL` | `"https://signing-thing.local/sign"` |

### Document conversion

| Key | Description | Default |
|-----|-------------|---------|
| [`documentConversion`](./values.yaml#L598) | Document conversion parameters |  |
| [`documentConversion.spreadsheetMaxContentHeightMm`](./values.yaml#L602) | Maximal spreadsheet content height in millimetres (`SPREADSHEET_MAX_CONTENT_HEIGHT_MM`). Defaults to `0` for unlimited height. | `0` |
| [`documentConversion.spreadsheetMaxContentWidthMm`](./values.yaml#L606) | Maximal spreadsheet content width in millimetres (`SPREADSHEET_MAX_CONTENT_WIDTH_MM`). Defaults to `0` for unlimited width. | `0` |

### Clustering

> [!NOTE]
> Clustering is an experimental feature; use with caution!

| Key | Description | Default |
|-----|-------------|---------|
| [`clustering`](./values.yaml#L611) | Clustering settings |  |
| [`clustering.enabled`](./values.yaml#L614) | `CLUSTERING_ENABLED`, enable clustering, only works when `replicaCount` is greater than 1 | `false` |
| [`clustering.method`](./values.yaml#L617) | `CLUSTERING_METHOD`, only `kubernetes_dns` is currently supported | `"kubernetes_dns"` |

### Dashboard

| Key | Description | Default |
|-----|-------------|---------|
| [`dashboard`](./values.yaml#L628) | Document Engine Dashboard settings |  |
| [`dashboard.auth`](./values.yaml#L648) | Dashboard authentication | [...](./values.yaml#L648) |
| [`dashboard.auth.externalSecret`](./values.yaml#L658) | Use an external secret for dashboard credentials | [...](./values.yaml#L658) |
| [`dashboard.auth.externalSecret.name`](./values.yaml#L661) | External secret name | `""` |
| [`dashboard.auth.externalSecret.passwordKey`](./values.yaml#L667) | Secret key name for the password | `"DASHBOARD_PASSWORD"` |
| [`dashboard.auth.externalSecret.usernameKey`](./values.yaml#L664) | Secret key name for the username | `"DASHBOARD_USERNAME"` |
| [`dashboard.auth.password`](./values.yaml#L654) | `DASHBOARD_PASSWORD` — will generate a random password if not set | `""` |
| [`dashboard.auth.username`](./values.yaml#L651) | `DASHBOARD_USERNAME` | `"admin"` |
| [`dashboard.enabled`](./values.yaml#L631) | Enable dashboard | `true` |
| [`dashboard.rateLimitingEnabled`](./values.yaml#L636) | `DASHBOARD_RATE_LIMITING_ENABLED` — enables rate limiting for dashboard authentication to prevent brute force attacks. When enabled, failed authentication attempts are tracked per IP address. | `true` |
| [`dashboard.rateLimitingMaxRequests`](./values.yaml#L640) | `DASHBOARD_RATE_LIMITING_MAX_REQUESTS` — maximum number of failed authentication attempts allowed per IP address within the time window before blocking. | `5` |
| [`dashboard.rateLimitingWindowMs`](./values.yaml#L644) | `DASHBOARD_RATE_LIMITING_WINDOW_MS` — time window in milliseconds for tracking failed authentication attempts. After this period, the counter resets. | `60000` |

### Environment

| Key | Description | Default |
|-----|-------------|---------|
| [`extraEnvFrom`](./values.yaml#L862) | Extra environment variables from resources | `[]` |
| [`extraEnvs`](./values.yaml#L859) | Extra environment variables | `[]` |
| [`extraVolumeMounts`](./values.yaml#L868) | Additional volume mounts for Document Engine container | `[]` |
| [`extraVolumes`](./values.yaml#L865) | Additional volumes | `[]` |
| [`image`](./values.yaml#L819) | Image settings | [...](./values.yaml#L819) |
| [`imagePullSecrets`](./values.yaml#L826) | Pull secrets | `[]` |
| [`initContainers`](./values.yaml#L874) | Init containers | `[]` |
| [`podSecurityContext`](./values.yaml#L845) | Pod security context | `{"fsGroup":999}` |
| [`securityContext`](./values.yaml#L849) | Security context | `{}` |
| [`serviceAccount`](./values.yaml#L838) | ServiceAccount | [...](./values.yaml#L838) |
| [`sidecars`](./values.yaml#L871) | Additional containers | `[]` |

### Metadata

| Key | Description | Default |
|-----|-------------|---------|
| [`deploymentAnnotations`](./values.yaml#L884) | Workload annotations (`Deployment`/`StatefulSet`) | `{}` |
| [`deploymentExtraSelectorLabels`](./values.yaml#L889) | Additional selector labels for the workload (`Deployment`/`StatefulSet`) **Note:** Kubernetes selectors are immutable. Changing this value after first install may require recreating the workload. | `{}` |
| [`fullnameOverride`](./values.yaml#L833) | Release full name override | `""` |
| [`nameOverride`](./values.yaml#L830) | Release name override | `""` |
| [`podAnnotations`](./values.yaml#L881) | Pod annotations | `{}` |
| [`podLabels`](./values.yaml#L878) | Pod labels | `{}` |

### Networking

| Key | Description | Default |
|-----|-------------|---------|
| [`envoySidecar`](./values.yaml#L1058) | Envoy sidecar for consistent hashing by document ID | [...](./values.yaml#L1058) |
| [`envoySidecar.adminPort`](./values.yaml#L1074) | Admin port for Envoy | `9901` |
| [`envoySidecar.enabled`](./values.yaml#L1061) | Enable Envoy sidecar for consistent hashing | `false` |
| [`envoySidecar.healthCheck`](./values.yaml#L1078) | Health check configuration for upstream cluster | [...](./values.yaml#L1078) |
| [`envoySidecar.healthCheck.healthyThreshold`](./values.yaml#L1090) | Healthy threshold | `2` |
| [`envoySidecar.healthCheck.interval`](./values.yaml#L1084) | Health check interval | `"10s"` |
| [`envoySidecar.healthCheck.timeout`](./values.yaml#L1081) | Health check timeout | `"5s"` |
| [`envoySidecar.healthCheck.unhealthyThreshold`](./values.yaml#L1087) | Unhealthy threshold | `2` |
| [`envoySidecar.image`](./values.yaml#L1065) | Envoy sidecar image configuration | [...](./values.yaml#L1065) |
| [`envoySidecar.port`](./values.yaml#L1071) | Port where Envoy sidecar listens | `8080` |
| [`envoySidecar.resources`](./values.yaml#L1094) | Resource limits for Envoy sidecar | [...](./values.yaml#L1094) |
| [`extraIngresses`](./values.yaml#L949) | Additional ingresses, e.g. for the dashboard | [...](./values.yaml#L949) |
| [`gateway`](./values.yaml#L965) | Kubernetes [Gateway API](https://gateway-api.sigs.k8s.io/) | [...](./values.yaml#L965) |
| [`gateway.annotations`](./values.yaml#L971) | Annotations for the HTTPRoute resource | `{}` |
| [`gateway.enabled`](./values.yaml#L968) | Enable Gateway API HTTPRoute | `false` |
| [`gateway.extraHTTPRoutes`](./values.yaml#L1039) | Additional HTTPRoutes, e.g. for the dashboard | [...](./values.yaml#L1039) |
| [`gateway.gateway`](./values.yaml#L1001) | Optional [Gateway](https://gateway-api.sigs.k8s.io/api-types/gateway/) resource. Most clusters have Gateways managed by platform teams; enable this only if you want the chart to create one. | [...](./values.yaml#L1001) |
| [`gateway.gateway.addresses`](./values.yaml#L1034) | Gateway [addresses](https://gateway-api.sigs.k8s.io/reference/spec/#gateway.networking.k8s.io/v1.GatewayAddress) | `[]` |
| [`gateway.gateway.annotations`](./values.yaml#L1010) | Annotations for the Gateway resource | `{}` |
| [`gateway.gateway.enabled`](./values.yaml#L1004) | Create a Gateway resource | `false` |
| [`gateway.gateway.gatewayClassName`](./values.yaml#L1007) | GatewayClass name (e.g. `amazon-vpc-lattice`, or a custom ALB class) | `""` |
| [`gateway.gateway.infrastructure`](./values.yaml#L1027) | [Infrastructure](https://gateway-api.sigs.k8s.io/reference/spec/#gateway.networking.k8s.io/v1.GatewayInfrastructure) parameters, e.g. `parametersRef` for AWS Load Balancer Controller | `{}` |
| [`gateway.gateway.labels`](./values.yaml#L1013) | Labels for the Gateway resource | `{}` |
| [`gateway.gateway.listeners`](./values.yaml#L1016) | Gateway [listeners](https://gateway-api.sigs.k8s.io/reference/spec/#gateway.networking.k8s.io/v1.Listener) | `[]` |
| [`gateway.hostnames`](./values.yaml#L985) | Hostnames for the HTTPRoute | `[]` |
| [`gateway.labels`](./values.yaml#L974) | Labels for the HTTPRoute resource | `{}` |
| [`gateway.parentRefs`](./values.yaml#L979) | References to Gateway resources this route attaches to. When `gateway.gateway.enabled` is true and this is empty, the chart-created Gateway is used automatically. See [ParentRef](https://gateway-api.sigs.k8s.io/reference/spec/#gateway.networking.k8s.io/v1.ParentReference) | `[]` |
| [`gateway.rules`](./values.yaml#L991) | HTTP routing rules. When empty, a default catch-all rule routing to the chart service is created. When rules are provided without `backendRefs`, the chart service is used as the default backend. | `[]` |
| [`ingress`](./values.yaml#L914) | Ingress | [...](./values.yaml#L914) |
| [`ingress.annotations`](./values.yaml#L923) | Ingress annotations | `{}` |
| [`ingress.className`](./values.yaml#L920) | Ingress class name | `""` |
| [`ingress.enabled`](./values.yaml#L917) | Enable ingress | `false` |
| [`ingress.hosts`](./values.yaml#L926) | Hosts | `[]` |
| [`ingress.tls`](./values.yaml#L940) | Ingress TLS section | `[]` |
| [`networkPolicy`](./values.yaml#L1106) | [Network policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/) | [...](./values.yaml#L1106) |
| [`networkPolicy.allowExternal`](./values.yaml#L1114) | Allow access from anywhere | `true` |
| [`networkPolicy.allowExternalEgress`](./values.yaml#L1138) | Allow the pod to access any range of port and all destinations. | `true` |
| [`networkPolicy.enabled`](./values.yaml#L1109) | Enable network policy | `true` |
| [`networkPolicy.extraEgress`](./values.yaml#L1141) | Extra egress rules | `[]` |
| [`networkPolicy.extraIngress`](./values.yaml#L1117) | Additional ingress rules | `[]` |
| [`networkPolicy.ingressMatchSelectorLabels`](./values.yaml#L1132) | Allow traffic from other namespaces | `[]` |
| [`service`](./values.yaml#L894) | Service | [...](./values.yaml#L894) |
| [`service.annotations`](./values.yaml#L903) | Service annotations | `{}` |
| [`service.internalTrafficPolicy`](./values.yaml#L906) | Service internal traffic policy | `"Cluster"` |
| [`service.port`](./values.yaml#L900) | Service port — see also `config.port` | `5000` |
| [`service.trafficDistribution`](./values.yaml#L909) | Service [traffic distribution policy](https://kubernetes.io/docs/concepts/services-networking/service/#traffic-distribution) | `nil` |
| [`service.type`](./values.yaml#L897) | Service type | `"ClusterIP"` |

### Observability

| Key | Description | Default |
|-----|-------------|---------|
| [`observability`](./values.yaml#L672) | Observability settings |  |
| [`observability.log`](./values.yaml#L676) | Logs | [...](./values.yaml#L676) |
| [`observability.log.healthcheckLevel`](./values.yaml#L691) | `HEALTHCHECK_LOGLEVEL` — log level for health checks | `"debug"` |
| [`observability.log.level`](./values.yaml#L679) | `LOG_LEVEL` | `"info"` |
| [`observability.log.structured`](./values.yaml#L682) | `LOG_STRUCTURED` — enable structured logging in JSON format | `false` |
| [`observability.log.structuredFlatten`](./values.yaml#L688) | `LOG_STRUCTURED_FLATTEN` — when structured logging is enabled, emit `meta`, `location`, `exception`, and `extra` fields as top-level dotted fields (e.g. `meta.event`, `location.file`) instead of nested JSON. Useful for OpenTelemetry collector pipelines and log backends that index top-level attributes. Only applies when `observability.log.structured` is `true`. | `true` |
| [`observability.metrics`](./values.yaml#L726) | Metrics configuration | [...](./values.yaml#L726) |
| [`observability.metrics.customTags`](./values.yaml#L732) | Global metrics tags for all exporters: `METRICS_CUSTOM_TAGS` | *generated* |
| [`observability.metrics.grafanaDashboard`](./values.yaml#L774) | Grafana dashboard | [...](./values.yaml#L774) |
| [`observability.metrics.grafanaDashboard.configMap`](./values.yaml#L782) | ConfigMap parameters | [...](./values.yaml#L782) |
| [`observability.metrics.grafanaDashboard.configMap.labels`](./values.yaml#L785) | ConfigMap labels | `{"grafana_dashboard":"1"}` |
| [`observability.metrics.grafanaDashboard.enabled`](./values.yaml#L778) | Enable Grafana dashboard. To work, requires Prometheus metrics enabled in `observability.metrics.prometheusEndpoint.enabled` | `false` |
| [`observability.metrics.grafanaDashboard.tags`](./values.yaml#L795) | Dashboard tags | `["Nutrient","document-engine"]` |
| [`observability.metrics.grafanaDashboard.title`](./values.yaml#L792) | Dashboard title | *generated* |
| [`observability.metrics.prometheusEndpoint`](./values.yaml#L736) | Prometheus metrics endpoint settings | [...](./values.yaml#L736) |
| [`observability.metrics.prometheusEndpoint.enabled`](./values.yaml#L739) | Enable Prometheus metrics endpoint, `ENABLE_PROMETHEUS` | `false` |
| [`observability.metrics.prometheusEndpoint.port`](./values.yaml#L742) | Port for the Prometheus metrics endpoint, `PROMETHEUS_PORT` | `10254` |
| [`observability.metrics.prometheusRule`](./values.yaml#L766) | Prometheus [PrometheusRule](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.PrometheusRule) Requires `observability.metrics.prometheusEndpoint.enabled` to be `true` | [...](./values.yaml#L766) |
| [`observability.metrics.serviceMonitor`](./values.yaml#L751) | Prometheus [ServiceMonitor](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.ServiceMonitor) Requires `observability.metrics.prometheusEndpoint.enabled` to be `true` | [...](./values.yaml#L751) |
| [`observability.metrics.statsd`](./values.yaml#L801) | StatsD parameters | [...](./values.yaml#L801) |
| [`observability.metrics.statsd.customTags`](./values.yaml#L814) | StatsD custom tags, `STATSD_CUSTOM_TAGS` | `` |
| [`observability.metrics.statsd.port`](./values.yaml#L810) | StatsD port, `STATSD_PORT` | `9125` |
| [`observability.opentelemetry`](./values.yaml#L695) | OpenTelemetry settings | [...](./values.yaml#L695) |
| [`observability.opentelemetry.enabled`](./values.yaml#L698) | Enable OpenTelemetry (`ENABLE_OPENTELEMETRY`), only tracing is currently supported | `false` |
| [`observability.opentelemetry.otelPropagators`](./values.yaml#L714) | `OTEL_PROPAGATORS`, propagators | `""` |
| [`observability.opentelemetry.otelResourceAttributes`](./values.yaml#L711) | `OTEL_RESOURCE_ATTRIBUTES`, resource attributes | `""` |
| [`observability.opentelemetry.otelServiceName`](./values.yaml#L708) | `OTEL_SERVICE_NAME`, service name | `""` |
| [`observability.opentelemetry.otelTracesSampler`](./values.yaml#L719) | `OTEL_TRACES_SAMPLER`, should normally not be touched to allow custom `parent_based` work, but something like `parentbased_traceidratio` may be considered | `""` |
| [`observability.opentelemetry.otelTracesSamplerArg`](./values.yaml#L722) | `OTEL_TRACES_SAMPLER_ARG`, argument for the sampler | `""` |
| [`observability.opentelemetry.otlpExporterEndpoint`](./values.yaml#L702) | https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/ `OTEL_EXPORTER_OTLP_ENDPOINT`, if not set, defaults to `http://localhost:4317` | `""` |
| [`observability.opentelemetry.otlpExporterProtocol`](./values.yaml#L705) | `OTEL_EXPORTER_OTLP_PROTOCOL`, if not set, defaults to `grpc` | `""` |

### Pod lifecycle

| Key | Description | Default |
|-----|-------------|---------|
| [`lifecycle`](./values.yaml#L1201) | [Lifecycle](https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/) | `map[]` |
| [`livenessProbe`](./values.yaml#L1171) | [Liveness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L1171) |
| [`readinessProbe`](./values.yaml#L1184) | [Readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L1184) |
| [`startupProbe`](./values.yaml#L1158) | [Startup probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L1158) |
| [`terminationGracePeriodSeconds`](./values.yaml#L1197) | [Termination grace period](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/). Should be greater than the longest expected request processing time (`config.requestTimeoutSeconds`). | `65` |

### Scheduling

| Key | Description | Default |
|-----|-------------|---------|
| [`affinity`](./values.yaml#L1256) | Node affinity | `{}` |
| [`autoscaling`](./values.yaml#L1209) | [Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) | [...](./values.yaml#L1209) |
| [`nodeSelector`](./values.yaml#L1253) | [Node selector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) | `{}` |
| [`podDisruptionBudget`](./values.yaml#L1246) | [Pod disruption budget](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) | [...](./values.yaml#L1246) |
| [`priorityClassName`](./values.yaml#L1265) | [Priority classs](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/) | `""` |
| [`replicaCount`](./values.yaml#L1234) | Number of replicas | `1` |
| [`resources`](./values.yaml#L1231) | [Resources](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) | `{}` |
| [`schedulerName`](./values.yaml#L1268) | [Scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/) | `""` |
| [`tolerations`](./values.yaml#L1259) | [Node tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) | `[]` |
| [`topologySpreadConstraints`](./values.yaml#L1262) | [Topology spread constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) | `[]` |
| [`updateStrategy`](./values.yaml#L1237) | [Update strategy](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy) | `{"rollingUpdate":{},"type":"RollingUpdate"}` |

### Storage resource definitions

| Key | Description | Default |
|-----|-------------|---------|
| [`cloudNativePG`](./values.yaml#L1273) | [CloudNativePG](https://cloudnative-pg.io/) resources | [...](./values.yaml#L1273) |
| [`cloudNativePG.clusterAnnotations`](./values.yaml#L1308) | Cluster annotations | `{}` |
| [`cloudNativePG.clusterLabels`](./values.yaml#L1305) | Cluster labels | `{}` |
| [`cloudNativePG.clusterName`](./values.yaml#L1285) | CloudNativePG custom Cluster name | `"{{ .Release.Name }}-postgres"` |
| [`cloudNativePG.clusterSpec`](./values.yaml#L1289) | CloudNativePG [cluster spec](https://cloudnative-pg.io/documentation/current/cloudnative-pg.v1/#postgresql-cnpg-io-v1-ClusterSpec) | [...](./values.yaml#L1289) |
| [`cloudNativePG.enabled`](./values.yaml#L1276) | Enable CloudNativePG resources | `false` |
| [`cloudNativePG.networkPolicy`](./values.yaml#L1317) | Network policy to allow access to the cluster | `{"enabled":true}` |
| [`cloudNativePG.operatorNamespace`](./values.yaml#L1279) | CloudNativePG operator namespace | `"cnpg-system"` |
| [`cloudNativePG.operatorReleaseName`](./values.yaml#L1282) | CloudNativePG operator release name | `"cloudnative-pg"` |
| [`cloudNativePG.superuserSecret`](./values.yaml#L1311) | Superuser secret to use with the cluster | `{"create":true,"password":"despair","username":"postgres"}` |

### Other Values

| Key | Description | Default |
|-----|-------------|---------|
| [`config.hoard.binaryCopyEnabled`](./values.yaml#L154) | `HOARD_BINARY_COPY_ENABLED` — internal parameter, do not change unless explicitly recommended by Nutrient support. | `true` |
| [`config.hoard.binaryCopyThreshold`](./values.yaml#L156) | `HOARD_BINARY_COPY_THRESHOLD` — internal parameter, do not change unless explicitly recommended by Nutrient support. | `2` |
| [`config.http2SharedRendering.checkinTimeoutMilliseconds`](./values.yaml#L167) | `HTTP2_SHARED_RENDERING_PROCESS_CHECKIN_TIMEOUT` — document processing daemon checkin timeout. Do not change unless explicitly recommended by Nutrient support. | `0` |
| [`config.http2SharedRendering.checkoutTimeoutMilliseconds`](./values.yaml#L170) | `HTTP2_SHARED_RENDERING_PROCESS_CHECKOUT_TIMEOUT` — document processing daemon checkout timeout. Do not change unless explicitly recommended by Nutrient support. | `5000` |
| [`revisionHistoryLimit`](./values.yaml#L1241) | [Revision history limit](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#clean-up-policy) | `10` |

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

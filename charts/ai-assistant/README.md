# AI Assistant Helm chart

![Version: 2.2.0](https://img.shields.io/badge/Version-2.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.3.0](https://img.shields.io/badge/AppVersion-2.3.0-informational?style=flat-square)

AI Assistant is a thing that assists an AI

**Homepage:** <https://www.nutrient.io/guides/ai-assistant/>

* [Using this chart](#using-this-chart)
* [Database](#database)
  * [PostgreSQL](#postgresql)
* [Integrations](#integrations)
  * [Gateway API](#gateway-api)
  * [CloudNativePG operator](#cloudnativepg-operator)
* [Values](#values)
  * [AI Assistant License](#ai-assistant-license)
  * [API authentication](#api-authentication)
  * [Configuration options](#configuration-options)
  * [Certificate trust](#certificate-trust)
  * [Database](#database)
  * [Dashboard](#dashboard)
  * [Environment](#environment)
  * [Metadata](#metadata)
  * [Networking](#networking)
  * [Observability](#observability)
  * [Pod lifecycle](#pod-lifecycle)
  * [Scheduling](#scheduling)
  * [Dependencies](#dependencies)
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

### Installing AI Assistant

```shell
helm upgrade --install -n ai-assistant \
     ai-assistant nutrient/ai-assistant \
     -f ./ai-assistant-values.yaml
```

### Dependencies

An optional dependency is [Document Engine chart](https://github.com/PSPDFKit/helm-charts/tree/master/charts/document-engine), to use when external Document Engine instance is not available.

Please consider [tests](/charts/ai-assistant/ci) as examples.

Schema is generated using [helm values schema json plugin](https://github.com/losisin/helm-values-schema-json).

`README.md` is generated with [helm-docs](https://github.com/norwoodj/helm-docs).

### Upgrade

> [!NOTE]
> Please consult the [changelog](/charts/ai-assistant/CHANGELOG.md)

## Database and asset storage

### PostgreSQL

In order to operate, AI Assistant requires a PostgreSQL database with `pg_vector` extenstion.

The chart does not provide means to install PostgreSQL database, object storage or Redis for rendering cache.

Instead, we recommend to manage these resources externally, e.g., on the cloud provider level.

However, the chart suggests generation of PostgreSQL Cluster custom resource provided by [CloudNativePG](https://cloudnative-pg.io/) operator.

CloudNativePG is not the only possible solution, and we recommend to also consider [StackGres](https://stackgres.io/), [Zalando Postgres Operator](https://github.com/zalando/postgres-operator).

## Integrations

### Gateway API

As an alternative to Ingress, the chart supports the [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/) by creating [HTTPRoute](https://gateway-api.sigs.k8s.io/api-types/httproute/) and optionally [Gateway](https://gateway-api.sigs.k8s.io/api-types/gateway/) resources.

The Gateway API separates infrastructure concerns (the `Gateway` resource, typically managed by platform teams) from application routing (the `HTTPRoute`, managed by this chart). Both `ingress` and `gateway` can be enabled simultaneously.

> [!NOTE]
> TLS termination in Gateway API is configured on the Gateway Listener, not on the HTTPRoute. This differs from Ingress, where TLS is specified per-Ingress resource.

Basic configuration:

```yaml
gateway:
  enabled: true
  parentRefs:
    - name: my-gateway
      namespace: gateway-infra
      sectionName: https
  hostnames:
    - ai-assistant.example.com
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
    database: ai-assistant
    username: postgres
    password: nutrientArtificialIntelligenceAssistant
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
        database: ai-assistant
        owner: whatever
    logLevel: warning
  superuserSecret:
    create: true
    username: postgres
    password: nutrientArtificialIntelligenceAssistant
  networkPolicy:
    enabled: true
```

## Values

### AI Assistant License

| Key | Description | Default |
|-----|-------------|---------|
| [`aiAssistantLicense`](./values.yaml#L5) | License information, see more in [our guide](https://www.nutrient.io/guides/ai-assistant/deployment/product-activation/) |  |
| [`aiAssistantLicense.activationKey`](./values.yaml#L10) | Activation key for online activation (most common) or license key for offline activation. Results in `ACTIVATION_KEY` environment variable. | `""` |
| [`aiAssistantLicense.externalSecret`](./values.yaml#L15) | Query existing secret for the activation key | [...](./values.yaml#L15) |

### API authentication

| Key | Description | Default |
|-----|-------------|---------|
| [`apiAuth`](./values.yaml#L28) | AI Assistant API authentication |  |
| [`apiAuth.apiToken`](./values.yaml#L32) | `API_AUTH_TOKEN`, a universal secret with full access to the API,  should be long enough | `"secret"` |
| [`apiAuth.externalSecret`](./values.yaml#L55) | Use an external secret for API credentials | [...](./values.yaml#L55) |
| [`apiAuth.jwt`](./values.yaml#L36) | JSON Web Token (JWT) settings | [...](./values.yaml#L36) |
| [`apiAuth.jwt.algorithm`](./values.yaml#L44) | `JWT_ALGORITHM` Supported algorithms: `RS256`, `RS512`, `ES256`, `ES512`. See RFC 7518 for details about specific algorithms. | `"RS256"` |
| [`apiAuth.jwt.publicKey`](./values.yaml#L39) | `JWT_PUBLIC_KEY` | `"none"` |
| [`apiAuth.secretKeyBase`](./values.yaml#L50) | A string used as the base key for deriving secret keys for the purposes of authentication. Choose a sufficiently long random string for this option. To generate a random string, use: `openssl rand -hex 256`. This will set `SECRET_KEY_BASE` environment variable. | `""` |

### Configuration options

| Key | Description | Default |
|-----|-------------|---------|
| [`config`](./values.yaml#L85) | General configuration, see more in [our guide](https://www.nutrient.io/guides/ai-assistant/service-configuration/docker-configuration/) |  |
| [`config.aiServiceProviderCredentials`](./values.yaml#L131) | Credentials for AI service providers. It is recommended to use extrenal secrets through `extraEnvFromSecrets` instead. | [...](./values.yaml#L131) |
| [`config.aiServiceProviderCredentials.awsBedrock`](./values.yaml#L149) | AWS Bedrock. It is recommended to not use direct credentials, but rather IRSA |  |
| [`config.aiServiceProviderCredentials.awsBedrock.accessKeyId`](./values.yaml#L152) | `BEDROCK_ACCESS_KEY_ID` | `""` |
| [`config.aiServiceProviderCredentials.awsBedrock.secretAccessKey`](./values.yaml#L155) | `BEDROCK_SECRET_ACCESS_KEY` | `""` |
| [`config.aiServiceProviderCredentials.azureOpenAI`](./values.yaml#L142) | Azure OpenAI |  |
| [`config.aiServiceProviderCredentials.azureOpenAI.apiKey`](./values.yaml#L145) | `AZURE_API_KEY` | `""` |
| [`config.aiServiceProviderCredentials.openAI`](./values.yaml#L135) | OpenAI |  |
| [`config.aiServiceProviderCredentials.openAI.apiKey`](./values.yaml#L138) | `OPENAI_API_KEY` | `""` |
| [`config.aiServiceProviderCredentials.openAICompatible`](./values.yaml#L159) | OpenAI compatible |  |
| [`config.aiServiceProviderCredentials.openAICompatible.apiKey`](./values.yaml#L162) | `OPENAI_COMPAT_API_KEY` | `""` |
| [`config.documentEngine`](./values.yaml#L167) | Document Engine settings | [...](./values.yaml#L167) |
| [`config.documentEngine.auth`](./values.yaml#L177) | Document Engine API authentication |  |
| [`config.documentEngine.auth.apiToken`](./values.yaml#L180) | `DE_API_AUTH_TOKEN`, Document Engine API authentication token | `"secret"` |
| [`config.documentEngine.auth.externalSecret`](./values.yaml#L185) | Use an external secret for API credentials | [...](./values.yaml#L185) |
| [`config.documentEngine.enabled`](./values.yaml#L170) | Enable Configuration options | `true` |
| [`config.documentEngine.url`](./values.yaml#L173) | `DE_URL` — the URL of the Document Engine endpoint | `"document-engine"` |
| [`config.forceEmbeddingMigrate`](./values.yaml#L91) | `FORCE_EMBEDDING_MIGRATE`, enables database migration compatibility with the new embedding model | `false` |
| [`config.port`](./values.yaml#L88) | Port for the API | `4000` |
| [`config.serviceConfiguration`](./values.yaml#L109) | Inline content for service configuration, used if `config.serviceConfigurationConfigMap.name` is not set. Uses the v2 service configuration schema (`version: "2"` with `providers` and `models`). See more in [our guide](https://www.nutrient.io/guides/ai-assistant/service-configuration/ai-configuration/#service-configuration-file) | [...](./values.yaml#L109) |
| [`config.serviceConfiguration.models`](./values.yaml#L125) | Models exposed to the application. Each entry has a `{provider}:{model}` reference and one or more semantic `labels` (e.g. `default-llm`, `default-embedding`) used for label-based model selection and request-time `provider:model` overrides. | `[]` |
| [`config.serviceConfiguration.providers`](./values.yaml#L119) | AI service providers. Each entry has a `name` (`openai`, `anthropic`, `azure`, `bedrock`, `openai-compat` or `mock`) plus provider-specific fields such as `instanceName` (Azure), `region` (Bedrock) or `baseUrl` (OpenAI-compatible). See [our guide](https://www.nutrient.io/guides/ai-assistant/service-configuration/ai-configuration/). | `[]` |
| [`config.serviceConfiguration.version`](./values.yaml#L112) | Service configuration schema version. Must be `"2"`. | `"2"` |
| [`config.serviceConfigurationConfigMap`](./values.yaml#L96) | Existing ConfigMap for service configuration, overrides  `config.serviceConfiguration` value | [...](./values.yaml#L96) |
| [`config.serviceConfigurationConfigMap.key`](./values.yaml#L102) | Key in the external ConfigMap, must contain the content of the service configuration file | `"service-configuration.yaml"` |
| [`config.serviceConfigurationConfigMap.name`](./values.yaml#L99) | Name of the ConfigMap, non-empty value enables the use of the external ConfigMap | `""` |

### Certificate trust

| Key | Description | Default |
|-----|-------------|---------|
| [`certificateTrust`](./values.yaml#L199) | [Certificate trust](https://www.nutrient.io/guides/document-engine/configuration/certificate-trust/) |  |
| [`certificateTrust.customCertificates`](./values.yaml#L212) | ConfigMap and Secret references for trust configuration, stored in `/certificate-stores-custom` | `[]` |
| [`certificateTrust.digitalSignatures`](./values.yaml#L203) | CAs for digital signatures (`/certificate-stores/`) from ConfigMap and Secret resources. | `[]` |
| [`certificateTrust.downloaderTrustFileName`](./values.yaml#L222) | Override `DOWNLOADER_CERT_FILE_PATH` to set HTTP client trust. If empty, defaults to  Mozilla's CA bundle. | `""` |

### Database

| Key | Description | Default |
|-----|-------------|---------|
| [`database`](./values.yaml#L227) | Database |  |
| [`database.enabled`](./values.yaml#L230) | Persistent storage enabled | `true` |
| [`database.engine`](./values.yaml#L233) | Database engine: only `postgres` is currently supported | `"postgres"` |
| [`database.postgres`](./values.yaml#L238) | PostgreSQL database settings | [...](./values.yaml#L238) |
| [`database.postgres.database`](./values.yaml#L248) | `PGDATABASE` | `"ai_assistant"` |
| [`database.postgres.externalSecretName`](./values.yaml#L259) | Use external secret for database credentials. `PGUSER` and `PGPASSWORD` must be provided and, if not defined: `PGDATABASE`, `PGHOST`, `PGPORT`, `PGSSL` | `""` |
| [`database.postgres.host`](./values.yaml#L242) | `PGHOST`, if not set, relies on CloudNativePG cluster name | `` |
| [`database.postgres.password`](./values.yaml#L254) | `PGPASSWORD` | `"nutrientArtificialIntelligenceAssistant"` |
| [`database.postgres.port`](./values.yaml#L245) | `PGPORT` | `5432` |
| [`database.postgres.tls`](./values.yaml#L264) | TLS settings | [...](./values.yaml#L264) |
| [`database.postgres.tls.commonName`](./values.yaml#L277) | Common name for the certificate (`PGSSL_CERT_COMMON_NAME`), defaults to `PGHOST` value | `""` |
| [`database.postgres.tls.enabled`](./values.yaml#L267) | Enable TLS (`PGSSL`) | `false` |
| [`database.postgres.tls.hostVerify`](./values.yaml#L273) | Negated `PGSSL_DISABLE_HOSTNAME_VERIFY` | `true` |
| [`database.postgres.tls.trustBundle`](./values.yaml#L281) | Trust bundle for PostgreSQL, sets `PGSSL_CA_CERTS`, mutually exclusive with `trustFileName` and takes precedence | `""` |
| [`database.postgres.tls.trustFileName`](./values.yaml#L284) | Path from `certificateTrust.customCertificates`, wraps around `PGSSL_CA_CERT_PATH` | `""` |
| [`database.postgres.tls.verify`](./values.yaml#L270) | Negated `PGSSL_DISABLE_VERIFY` | `true` |
| [`database.postgres.username`](./values.yaml#L251) | `PGUSER` | `"postgres"` |

### Dashboard

| Key | Description | Default |
|-----|-------------|---------|
| [`dashboard`](./values.yaml#L289) | AI Assistant Dashboard settings |  |
| [`dashboard.auth`](./values.yaml#L296) | Dashboard authentication | [...](./values.yaml#L296) |
| [`dashboard.auth.externalSecret`](./values.yaml#L306) | Use an external secret for dashboard credentials | [...](./values.yaml#L306) |
| [`dashboard.auth.externalSecret.name`](./values.yaml#L309) | External secret name | `""` |
| [`dashboard.auth.externalSecret.passwordKey`](./values.yaml#L315) | Secret key name for the password | `"DASHBOARD_PASSWORD"` |
| [`dashboard.auth.externalSecret.usernameKey`](./values.yaml#L312) | Secret key name for the username | `"DASHBOARD_USERNAME"` |
| [`dashboard.auth.password`](./values.yaml#L302) | `DASHBOARD_PASSWORD` — will generate a random password if not set | `""` |
| [`dashboard.auth.username`](./values.yaml#L299) | `DASHBOARD_USERNAME` | `"admin"` |
| [`dashboard.enabled`](./values.yaml#L292) | Enable dashboard | `true` |

### Environment

| Key | Description | Default |
|-----|-------------|---------|
| [`extraEnvFrom`](./values.yaml#L380) | Extra environment variables from resources | `[]` |
| [`extraEnvFromSecrets`](./values.yaml#L384) | Extra environment variables from Secrets with these names (for convenience, overlaps with broader `extraEnvFrom`). Expected use is to define `OPENAI_API_KEY`, `AZURE_API_KEY`, etc. | `[]` |
| [`extraEnvs`](./values.yaml#L377) | Extra environment variables | `[]` |
| [`extraVolumeMounts`](./values.yaml#L390) | Additional volume mounts for Document Engine container | `[]` |
| [`extraVolumes`](./values.yaml#L387) | Additional volumes | `[]` |
| [`image`](./values.yaml#L336) | Image settings | [...](./values.yaml#L336) |
| [`imagePullSecrets`](./values.yaml#L343) | Pull secrets | `[]` |
| [`initContainers`](./values.yaml#L396) | Init containers | `[]` |
| [`podSecurityContext`](./values.yaml#L363) | Pod security context | `{}` |
| [`securityContext`](./values.yaml#L367) | Security context | `{}` |
| [`serviceAccount`](./values.yaml#L355) | ServiceAccount | [...](./values.yaml#L355) |
| [`sidecars`](./values.yaml#L393) | Additional containers | `[]` |

### Metadata

| Key | Description | Default |
|-----|-------------|---------|
| [`deploymentAnnotations`](./values.yaml#L406) | Deployment annotations | `{}` |
| [`fullnameOverride`](./values.yaml#L350) | Release full name override | `""` |
| [`nameOverride`](./values.yaml#L347) | Release name override | `""` |
| [`podAnnotations`](./values.yaml#L403) | Pod annotations | `{}` |
| [`podLabels`](./values.yaml#L400) | Pod labels | `{}` |

### Networking

| Key | Description | Default |
|-----|-------------|---------|
| [`gateway`](./values.yaml#L456) | Kubernetes [Gateway API](https://gateway-api.sigs.k8s.io/) | [...](./values.yaml#L456) |
| [`gateway.annotations`](./values.yaml#L462) | Annotations for the HTTPRoute resource | `{}` |
| [`gateway.enabled`](./values.yaml#L459) | Enable Gateway API HTTPRoute | `false` |
| [`gateway.gateway`](./values.yaml#L492) | Optional [Gateway](https://gateway-api.sigs.k8s.io/api-types/gateway/) resource. Most clusters have Gateways managed by platform teams; enable this only if you want the chart to create one. | [...](./values.yaml#L492) |
| [`gateway.gateway.addresses`](./values.yaml#L525) | Gateway [addresses](https://gateway-api.sigs.k8s.io/reference/spec/#gateway.networking.k8s.io/v1.GatewayAddress) | `[]` |
| [`gateway.gateway.annotations`](./values.yaml#L501) | Annotations for the Gateway resource | `{}` |
| [`gateway.gateway.enabled`](./values.yaml#L495) | Create a Gateway resource | `false` |
| [`gateway.gateway.gatewayClassName`](./values.yaml#L498) | GatewayClass name (e.g. `amazon-vpc-lattice`, or a custom ALB class) | `""` |
| [`gateway.gateway.infrastructure`](./values.yaml#L518) | [Infrastructure](https://gateway-api.sigs.k8s.io/reference/spec/#gateway.networking.k8s.io/v1.GatewayInfrastructure) parameters, e.g. `parametersRef` for AWS Load Balancer Controller | `{}` |
| [`gateway.gateway.labels`](./values.yaml#L504) | Labels for the Gateway resource | `{}` |
| [`gateway.gateway.listeners`](./values.yaml#L507) | Gateway [listeners](https://gateway-api.sigs.k8s.io/reference/spec/#gateway.networking.k8s.io/v1.Listener) | `[]` |
| [`gateway.hostnames`](./values.yaml#L476) | Hostnames for the HTTPRoute | `[]` |
| [`gateway.labels`](./values.yaml#L465) | Labels for the HTTPRoute resource | `{}` |
| [`gateway.parentRefs`](./values.yaml#L470) | References to Gateway resources this route attaches to. When `gateway.gateway.enabled` is true and this is empty, the chart-created Gateway is used automatically. See [ParentRef](https://gateway-api.sigs.k8s.io/reference/spec/#gateway.networking.k8s.io/v1.ParentReference) | `[]` |
| [`gateway.rules`](./values.yaml#L482) | HTTP routing rules. When empty, a default catch-all rule routing to the chart service is created. When rules are provided without `backendRefs`, the chart service is used as the default backend. | `[]` |
| [`ingress`](./values.yaml#L422) | Ingress | [...](./values.yaml#L422) |
| [`ingress.annotations`](./values.yaml#L431) | Ingress annotations | `{}` |
| [`ingress.className`](./values.yaml#L428) | Ingress class name | `""` |
| [`ingress.enabled`](./values.yaml#L425) | Enable ingress | `false` |
| [`ingress.hosts`](./values.yaml#L434) | Hosts | `[]` |
| [`ingress.tls`](./values.yaml#L448) | Ingress TLS section | `[]` |
| [`networkPolicy`](./values.yaml#L531) | [Network policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/) | [...](./values.yaml#L531) |
| [`networkPolicy.allowExternal`](./values.yaml#L539) | Allow access from anywhere | `true` |
| [`networkPolicy.allowExternalEgress`](./values.yaml#L563) | Allow the pod to access any range of port and all destinations. | `true` |
| [`networkPolicy.enabled`](./values.yaml#L534) | Enable network policy | `true` |
| [`networkPolicy.extraEgress`](./values.yaml#L566) | Extra egress rules | `[]` |
| [`networkPolicy.extraIngress`](./values.yaml#L542) | Additional ingress rules | `[]` |
| [`networkPolicy.ingressMatchSelectorLabels`](./values.yaml#L557) | Allow traffic from other namespaces | `[]` |
| [`service`](./values.yaml#L411) | Service | [...](./values.yaml#L411) |
| [`service.port`](./values.yaml#L417) | Service port — see also `config.port` | `4000` |
| [`service.type`](./values.yaml#L414) | Service type | `"ClusterIP"` |

### Observability

| Key | Description | Default |
|-----|-------------|---------|
| [`observability`](./values.yaml#L320) | Observability settings |  |
| [`observability.log`](./values.yaml#L324) | Logs | [...](./values.yaml#L324) |
| [`observability.log.level`](./values.yaml#L327) | `LOG_LEVEL` | `"info"` |
| [`observability.log.socketTraces`](./values.yaml#L331) | `SOCKET_TRACE` — enables logging of socket events and data. Warning: this may expose sensitive information and should only be used for debugging purposes. | `false` |

### Pod lifecycle

| Key | Description | Default |
|-----|-------------|---------|
| [`lifecycle`](./values.yaml#L626) | [Lifecycle](https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/) | `map[]` |
| [`livenessProbe`](./values.yaml#L596) | [Liveness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L596) |
| [`readinessProbe`](./values.yaml#L609) | [Readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L609) |
| [`startupProbe`](./values.yaml#L583) | [Startup probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L583) |
| [`terminationGracePeriodSeconds`](./values.yaml#L622) | [Termination grace period](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/). Should be greater than the longest expected request processing time (`config.requestTimeoutSeconds`). | `65` |

### Scheduling

| Key | Description | Default |
|-----|-------------|---------|
| [`affinity`](./values.yaml#L678) | Node affinity | `{}` |
| [`autoscaling`](./values.yaml#L631) | [Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) | [...](./values.yaml#L631) |
| [`nodeSelector`](./values.yaml#L675) | [Node selector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) | `{}` |
| [`podDisruptionBudget`](./values.yaml#L668) | [Pod disruption budget](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) | [...](./values.yaml#L668) |
| [`priorityClassName`](./values.yaml#L687) | [Priority classs](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/) | `""` |
| [`replicaCount`](./values.yaml#L656) | Number of replicas | `1` |
| [`resources`](./values.yaml#L653) | [Resources](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) | `{}` |
| [`schedulerName`](./values.yaml#L690) | [Scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/) | `""` |
| [`tolerations`](./values.yaml#L681) | [Node tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) | `[]` |
| [`topologySpreadConstraints`](./values.yaml#L684) | [Topology spread constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) | `[]` |
| [`updateStrategy`](./values.yaml#L659) | [Update strategy](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy) | `{"rollingUpdate":{},"type":"RollingUpdate"}` |

### Dependencies

| Key | Description | Default |
|-----|-------------|---------|
| [`document-engine`](./values.yaml#L745) | [Nutrient Document Engine chart](https://github.com/PSPDFKit/helm-charts/tree/master/charts/document-engine) | [...](./values.yaml#L745) |

### Storage resource definitions

| Key | Description | Default |
|-----|-------------|---------|
| [`cloudNativePG`](./values.yaml#L695) | [CloudNativePG](https://cloudnative-pg.io/) resources | [...](./values.yaml#L695) |
| [`cloudNativePG.clusterAnnotations`](./values.yaml#L725) | Cluster annotations | `{}` |
| [`cloudNativePG.clusterLabels`](./values.yaml#L722) | Cluster labels | `{}` |
| [`cloudNativePG.clusterName`](./values.yaml#L707) | CloudNativePG custom Cluster name | `"{{ .Release.Name }}-postgres"` |
| [`cloudNativePG.clusterSpec`](./values.yaml#L711) | CloudNativePG [cluster spec](https://cloudnative-pg.io/documentation/current/cloudnative-pg.v1/#postgresql-cnpg-io-v1-ClusterSpec) | [...](./values.yaml#L711) |
| [`cloudNativePG.documentEngineDatabase`](./values.yaml#L738) | Additional database for Document Engine | `{"enabled":false,"name":"document_engine"}` |
| [`cloudNativePG.enabled`](./values.yaml#L698) | Enable CloudNativePG resources | `false` |
| [`cloudNativePG.networkPolicy`](./values.yaml#L734) | Network policy to allow access to the cluster | `{"enabled":true}` |
| [`cloudNativePG.operatorNamespace`](./values.yaml#L701) | CloudNativePG operator namespace | `"cnpg-system"` |
| [`cloudNativePG.operatorReleaseName`](./values.yaml#L704) | CloudNativePG operator release name | `"cloudnative-pg"` |
| [`cloudNativePG.superuserSecret`](./values.yaml#L728) | Superuser secret to use with the cluster | `{"create":true,"password":"nutrientArtificialIntelligenceAssistant","username":"postgres"}` |

### Other Values

| Key | Description | Default |
|-----|-------------|---------|
| [`revisionHistoryLimit`](./values.yaml#L663) | [Revision history limit](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#clean-up-policy) | `10` |

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

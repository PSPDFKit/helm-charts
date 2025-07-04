# AI Assistant Helm chart

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.5.0](https://img.shields.io/badge/AppVersion-1.5.0-informational?style=flat-square)

AI Assistant is a thing that assists an AI

**Homepage:** <https://www.nutrient.io/guides/ai-assistant/>

* [Using this chart](#using-this-chart)
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

There is also chart optionally depends upon [Bitnami](https://github.com/bitnami/charts/tree/main/bitnami) chart for PostgreSQL.
It is disabled by default, but can be enabled for convenience.

> [!NOTE]
> Official Bitnami PostgreSQL image does not include `pgvector` extension and the existing values rely on a workaround using `pgvector/pgvector` image instead.
> We recommend using more mature solution in production, e.g. a managed database.

Please consider [tests](/charts/ai-assistant/ci) as examples.

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | postgresql | 16.7.4 |
| https://pspdfkit.github.io/helm-charts | document-engine | 3.10.1 |

Schema is generated using [helm values schema json plugin](https://github.com/losisin/helm-values-schema-json).

`README.md` is generated with [helm-docs](https://github.com/norwoodj/helm-docs).

### Upgrade

> [!NOTE]
> Please consult the [changelog](/charts/ai-assistant/CHANGELOG.md)

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
| [`config.aiServiceProviderCredentials`](./values.yaml#L126) | Credentials for AI service providers. It is recommended to use extrenal secrets through `extraEnvFromSecrets` instead. | [...](./values.yaml#L126) |
| [`config.aiServiceProviderCredentials.awsBedrock`](./values.yaml#L144) | AWS Bedrock. It is recommended to not use direct credentials, but rather IRSA |  |
| [`config.aiServiceProviderCredentials.awsBedrock.accessKeyId`](./values.yaml#L147) | `BEDROCK_ACCESS_KEY_ID` | `""` |
| [`config.aiServiceProviderCredentials.awsBedrock.secretAccessKey`](./values.yaml#L150) | `BEDROCK_SECRET_ACCESS_KEY` | `""` |
| [`config.aiServiceProviderCredentials.azureOpenAI`](./values.yaml#L137) | Azure OpenAI |  |
| [`config.aiServiceProviderCredentials.azureOpenAI.apiKey`](./values.yaml#L140) | `AZURE_API_KEY` | `""` |
| [`config.aiServiceProviderCredentials.openAI`](./values.yaml#L130) | OpenAI |  |
| [`config.aiServiceProviderCredentials.openAI.apiKey`](./values.yaml#L133) | `OPENAI_API_KEY` | `""` |
| [`config.aiServiceProviderCredentials.openAICompatible`](./values.yaml#L154) | OpenAI compatible |  |
| [`config.aiServiceProviderCredentials.openAICompatible.apiKey`](./values.yaml#L157) | `OPENAI_COMPAT_API_KEY` | `""` |
| [`config.documentEngine`](./values.yaml#L162) | Document Engine settings | [...](./values.yaml#L162) |
| [`config.documentEngine.auth`](./values.yaml#L172) | Document Engine API authentication |  |
| [`config.documentEngine.auth.apiToken`](./values.yaml#L175) | `DE_API_AUTH_TOKEN`, Document Engine API authentication token | `"secret"` |
| [`config.documentEngine.auth.externalSecret`](./values.yaml#L180) | Use an external secret for API credentials | [...](./values.yaml#L180) |
| [`config.documentEngine.enabled`](./values.yaml#L165) | Enable Configuration options | `true` |
| [`config.documentEngine.url`](./values.yaml#L168) | `DE_URL` — the URL of the Document Engine endpoint | `"document-engine"` |
| [`config.forceEmbeddingMigrate`](./values.yaml#L91) | `FORCE_EMBEDDING_MIGRATE`, enables database migration compatibility with the new embedding model | `false` |
| [`config.port`](./values.yaml#L88) | Port for the API | `4000` |
| [`config.serviceConfiguration`](./values.yaml#L108) | Inline content for service configuration, used if `config.serviceConfigurationConfigMap.name` is not set. See more in [our guide](https://www.nutrient.io/guides/ai-assistant/service-configuration/ai-configuration/#service-configuration-file) | [...](./values.yaml#L108) |
| [`config.serviceConfigurationConfigMap`](./values.yaml#L96) | Existing ConfigMap for service configuration, overrides  `config.serviceConfiguration` value | [...](./values.yaml#L96) |
| [`config.serviceConfigurationConfigMap.key`](./values.yaml#L102) | Key in the external ConfigMap, must contain the content of the service configuration file | `"service-configuration.yaml"` |
| [`config.serviceConfigurationConfigMap.name`](./values.yaml#L99) | Name of the ConfigMap, non-empty value enables the use of the external ConfigMap | `""` |

### Certificate trust

| Key | Description | Default |
|-----|-------------|---------|
| [`certificateTrust`](./values.yaml#L194) | [Certificate trust](https://www.nutrient.io/guides/document-engine/configuration/certificate-trust/) |  |
| [`certificateTrust.customCertificates`](./values.yaml#L207) | ConfigMap and Secret references for trust configuration, stored in `/certificate-stores-custom` | `[]` |
| [`certificateTrust.digitalSignatures`](./values.yaml#L198) | CAs for digital signatures (`/certificate-stores/`) from ConfigMap and Secret resources. | `[]` |
| [`certificateTrust.downloaderTrustFileName`](./values.yaml#L217) | Override `DOWNLOADER_CERT_FILE_PATH` to set HTTP client trust. If empty, defaults to  Mozilla's CA bundle. | `""` |

### Database

| Key | Description | Default |
|-----|-------------|---------|
| [`database`](./values.yaml#L222) | Database |  |
| [`database.enabled`](./values.yaml#L225) | Persistent storage enabled | `true` |
| [`database.engine`](./values.yaml#L228) | Database engine: only `postgres` is currently supported | `"postgres"` |
| [`database.postgres`](./values.yaml#L233) | PostgreSQL database settings | [...](./values.yaml#L233) |
| [`database.postgres.database`](./values.yaml#L242) | `PGDATABASE` | `"ai-assistant"` |
| [`database.postgres.externalSecretName`](./values.yaml#L253) | Use external secret for database credentials. `PGUSER` and `PGPASSWORD` must be provided and, if not defined: `PGDATABASE`, `PGHOST`, `PGPORT`, `PGSSL` | `""` |
| [`database.postgres.host`](./values.yaml#L236) | `PGHOST` | `"postgresql"` |
| [`database.postgres.password`](./values.yaml#L248) | `PGPASSWORD` | `"nutrient"` |
| [`database.postgres.port`](./values.yaml#L239) | `PGPORT` | `5432` |
| [`database.postgres.tls`](./values.yaml#L258) | TLS settings | [...](./values.yaml#L258) |
| [`database.postgres.tls.commonName`](./values.yaml#L271) | Common name for the certificate (`PGSSL_CERT_COMMON_NAME`), defaults to `PGHOST` value | `""` |
| [`database.postgres.tls.enabled`](./values.yaml#L261) | Enable TLS (`PGSSL`) | `false` |
| [`database.postgres.tls.hostVerify`](./values.yaml#L267) | Negated `PGSSL_DISABLE_HOSTNAME_VERIFY` | `true` |
| [`database.postgres.tls.trustBundle`](./values.yaml#L275) | Trust bundle for PostgreSQL, sets `PGSSL_CA_CERTS`, mutually exclusive with `trustFileName` and takes precedence | `""` |
| [`database.postgres.tls.trustFileName`](./values.yaml#L278) | Path from `certificateTrust.customCertificates`, wraps around `PGSSL_CA_CERT_PATH` | `""` |
| [`database.postgres.tls.verify`](./values.yaml#L264) | Negated `PGSSL_DISABLE_VERIFY` | `true` |
| [`database.postgres.username`](./values.yaml#L245) | `PGUSER` | `"postgres"` |

### Dashboard

| Key | Description | Default |
|-----|-------------|---------|
| [`dashboard`](./values.yaml#L283) | AI Assistant Dashboard settings |  |
| [`dashboard.auth`](./values.yaml#L290) | Dashboard authentication | [...](./values.yaml#L290) |
| [`dashboard.auth.externalSecret`](./values.yaml#L300) | Use an external secret for dashboard credentials | [...](./values.yaml#L300) |
| [`dashboard.auth.externalSecret.name`](./values.yaml#L303) | External secret name | `""` |
| [`dashboard.auth.externalSecret.passwordKey`](./values.yaml#L309) | Secret key name for the password | `"DASHBOARD_PASSWORD"` |
| [`dashboard.auth.externalSecret.usernameKey`](./values.yaml#L306) | Secret key name for the username | `"DASHBOARD_USERNAME"` |
| [`dashboard.auth.password`](./values.yaml#L296) | `DASHBOARD_PASSWORD` — will generate a random password if not set | `""` |
| [`dashboard.auth.username`](./values.yaml#L293) | `DASHBOARD_USERNAME` | `"admin"` |
| [`dashboard.enabled`](./values.yaml#L286) | Enable dashboard | `true` |

### Environment

| Key | Description | Default |
|-----|-------------|---------|
| [`extraEnvFrom`](./values.yaml#L374) | Extra environment variables from resources | `[]` |
| [`extraEnvFromSecrets`](./values.yaml#L378) | Extra environment variables from Secrets with these names (for convenience, overlaps with broader `extraEnvFrom`). Expected use is to define `OPENAI_API_KEY`, `AZURE_API_KEY`, etc. | `[]` |
| [`extraEnvs`](./values.yaml#L371) | Extra environment variables | `[]` |
| [`extraVolumeMounts`](./values.yaml#L384) | Additional volume mounts for Document Engine container | `[]` |
| [`extraVolumes`](./values.yaml#L381) | Additional volumes | `[]` |
| [`image`](./values.yaml#L330) | Image settings | [...](./values.yaml#L330) |
| [`imagePullSecrets`](./values.yaml#L337) | Pull secrets | `[]` |
| [`initContainers`](./values.yaml#L390) | Init containers | `[]` |
| [`podSecurityContext`](./values.yaml#L357) | Pod security context | `{}` |
| [`securityContext`](./values.yaml#L361) | Security context | `{}` |
| [`serviceAccount`](./values.yaml#L349) | ServiceAccount | [...](./values.yaml#L349) |
| [`sidecars`](./values.yaml#L387) | Additional containers | `[]` |

### Metadata

| Key | Description | Default |
|-----|-------------|---------|
| [`deploymentAnnotations`](./values.yaml#L400) | Deployment annotations | `{}` |
| [`fullnameOverride`](./values.yaml#L344) | Release full name override | `""` |
| [`nameOverride`](./values.yaml#L341) | Release name override | `""` |
| [`podAnnotations`](./values.yaml#L397) | Pod annotations | `{}` |
| [`podLabels`](./values.yaml#L394) | Pod labels | `{}` |

### Networking

| Key | Description | Default |
|-----|-------------|---------|
| [`ingress`](./values.yaml#L416) | Ingress | [...](./values.yaml#L416) |
| [`ingress.annotations`](./values.yaml#L425) | Ingress annotations | `{}` |
| [`ingress.className`](./values.yaml#L422) | Ingress class name | `""` |
| [`ingress.enabled`](./values.yaml#L419) | Enable ingress | `false` |
| [`ingress.hosts`](./values.yaml#L428) | Hosts | `[]` |
| [`ingress.tls`](./values.yaml#L442) | Ingress TLS section | `[]` |
| [`networkPolicy`](./values.yaml#L452) | [Network policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/) | [...](./values.yaml#L452) |
| [`networkPolicy.allowExternal`](./values.yaml#L460) | Allow access from anywhere | `true` |
| [`networkPolicy.allowExternalEgress`](./values.yaml#L484) | Allow the pod to access any range of port and all destinations. | `true` |
| [`networkPolicy.enabled`](./values.yaml#L455) | Enable network policy | `true` |
| [`networkPolicy.extraEgress`](./values.yaml#L487) | Extra egress rules | `[]` |
| [`networkPolicy.extraIngress`](./values.yaml#L463) | Additional ingress rules | `[]` |
| [`networkPolicy.ingressMatchSelectorLabels`](./values.yaml#L478) | Allow traffic from other namespaces | `[]` |
| [`service`](./values.yaml#L405) | Service | [...](./values.yaml#L405) |
| [`service.port`](./values.yaml#L411) | Service port — see also `config.port` | `4000` |
| [`service.type`](./values.yaml#L408) | Service type | `"ClusterIP"` |

### Observability

| Key | Description | Default |
|-----|-------------|---------|
| [`observability`](./values.yaml#L314) | Observability settings |  |
| [`observability.log`](./values.yaml#L318) | Logs | [...](./values.yaml#L318) |
| [`observability.log.level`](./values.yaml#L321) | `LOG_LEVEL` | `"info"` |
| [`observability.log.socketTraces`](./values.yaml#L325) | `SOCKET_TRACE` — enables logging of socket events and data. Warning: this may expose sensitive information and should only be used for debugging purposes. | `false` |

### Pod lifecycle

| Key | Description | Default |
|-----|-------------|---------|
| [`lifecycle`](./values.yaml#L547) | [Lifecycle](https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/) | `map[]` |
| [`livenessProbe`](./values.yaml#L517) | [Liveness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L517) |
| [`readinessProbe`](./values.yaml#L530) | [Readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L530) |
| [`startupProbe`](./values.yaml#L504) | [Startup probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) | [...](./values.yaml#L504) |
| [`terminationGracePeriodSeconds`](./values.yaml#L543) | [Termination grace period](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/). Should be greater than the longest expected request processing time (`config.requestTimeoutSeconds`). | `65` |

### Scheduling

| Key | Description | Default |
|-----|-------------|---------|
| [`affinity`](./values.yaml#L599) | Node affinity | `{}` |
| [`autoscaling`](./values.yaml#L552) | [Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) | [...](./values.yaml#L552) |
| [`nodeSelector`](./values.yaml#L596) | [Node selector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) | `{}` |
| [`podDisruptionBudget`](./values.yaml#L589) | [Pod disruption budget](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) | [...](./values.yaml#L589) |
| [`priorityClassName`](./values.yaml#L608) | [Priority classs](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/) | `""` |
| [`replicaCount`](./values.yaml#L577) | Number of replicas | `1` |
| [`resources`](./values.yaml#L574) | [Resources](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) | `{}` |
| [`schedulerName`](./values.yaml#L611) | [Scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/) | `""` |
| [`tolerations`](./values.yaml#L602) | [Node tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) | `[]` |
| [`topologySpreadConstraints`](./values.yaml#L605) | [Topology spread constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) | `[]` |
| [`updateStrategy`](./values.yaml#L580) | [Update strategy](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy) | `{"rollingUpdate":{},"type":"RollingUpdate"}` |

### Dependencies

| Key | Description | Default |
|-----|-------------|---------|
| [`documentEngine`](./values.yaml#L663) | [Nutrient Document Engine chart](https://github.com/PSPDFKit/helm-charts/tree/master/charts/document-engine) | [...](./values.yaml#L663) |
| [`postgresql`](./values.yaml#L619) | [External PostgreSQL database chart](https://github.com/bitnami/charts/tree/main/bitnami/postgresql). Please note that this chart is not maintained by Nutrient and that considering "unsupported" `pgvector/pgvector` image, this is a workaround. We recommend using PostgreSQL management orchestratration approach for production. | [...](./values.yaml#L619) |

### Other Values

| Key | Description | Default |
|-----|-------------|---------|
| [`revisionHistoryLimit`](./values.yaml#L584) | [Revision history limit](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#clean-up-policy) | `10` |

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

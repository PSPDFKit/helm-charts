# Maestrod Helm chart

> [!WARNING] This chart is made for internal use by Nutrient.

![Version: 0.11.0](https://img.shields.io/badge/Version-0.11.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.6.2](https://img.shields.io/badge/AppVersion-1.6.2-informational?style=flat-square)

Maestrod, the orchestration backend for Nutrient managed cloud workloads.

**Homepage:** <https://www.nutrient.io>

* [Using this chart](#using-this-chart)
* [Prerequisites](#prerequisites)
* [Migrating from the internal 0.3.x chart](#migrating-from-the-internal-03x-chart)
* [Restart Job](#restart-job)
* [Values](#values)
  * [Maestrod License](#maestrod-license)
  * [Maestrod configuration](#maestrod-configuration)
  * [Environment](#environment)
  * [Metadata](#metadata)
  * [Networking](#networking)
  * [Observability](#observability)
  * [Pod lifecycle](#pod-lifecycle)
  * [Scheduling](#scheduling)
  * [Restart job](#restart-job)
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

### Installing Maestrod

```shell
helm upgrade --install -n maestrod \
     maestrod nutrient/maestrod \
     -f ./maestrod-values.yaml
```

Schema is generated using the [helm-values-schema-json plugin](https://github.com/losisin/helm-values-schema-json).

`README.md` is generated with [helm-docs](https://github.com/norwoodj/helm-docs).

### Upgrade

> [!NOTE]
> Please consult the [changelog](/charts/maestrod/CHANGELOG.md).

## Prerequisites

### License Secret

Maestrod requires the activation key to be supplied via an existing
Kubernetes Secret in the release namespace. The chart does **not** create
this secret. Create it before installing:

```shell
kubectl create secret generic maestrod-secret \
  -n maestrod \
  --from-literal=NUTRIENT_LICENSE_KEY="$YOUR_LICENSE_KEY"
```

Override `licenseSecret.name` / `licenseSecret.key` to reference a different
Secret/key.

### Image

`image.repository` defaults to `pspdfkit/maestrod`. Override it to use a
private registry or mirror:

```yaml
image:
  repository: my-registry.example.com/maestrod
  tag: "1.0.0"
```

When `image.tag` is empty, the chart falls back to the chart's `appVersion`.

### Reported release version

`maestro.releaseVersion` maps to `MAESTRO_RELEASE_VERSION`, not to a `NUTRIENT_*` or
`NATIVESDK_*` variable. The chart injects it through the ConfigMap. When the value is empty,
the chart derives it from `image.tag`, falling back to chart `appVersion`, and removes any
`@sha256:...` suffix. Set it explicitly when the image reference doesn't name the deployed
release, such as an immutable commit image or a digest-pinned deployment:

```yaml
image:
  tag: "sha-<full SHA>@sha256:<digest>"
maestro:
  releaseVersion: "1.6.1"
```

A nonblank `MAESTRO_RELEASE_VERSION` changes the daemon's reported OpenAPI `info.version`
verbatim without changing the binary or its baked-in `<next-patch>-dev+<full SHA>` assembly
identity. When the runtime variable is absent or whitespace-only, the daemon reports its
assembly informational version, falling back to `0.0.0` if unavailable. An empty chart value
still injects the derived release name; it doesn't unset the runtime variable.

CI builds or reuses immutable `sha-<full SHA>` images. `latest` advances per normal `master`
commit without Hosted CI. Nightly validates a pinned `latest` digest through Hosted CI and
promotes that same digest. Stable releases select an explicit source SHA and `x.y.z` version,
reuse or build the commit image, and apply the Git release tag only after publishing the image.
The chart supplies the deployment identity; it doesn't perform image promotion.

## Migrating from the internal 0.3.x chart

This is the first public release of the chart. It is value-compatible with
the internal `cloud-demo-infra/charts/maestrod@0.3.4`, with a small number of
defaults reset to neutral values. If your existing values file relied on any
of the internal defaults below, reproduce the equivalent settings with your
registry and Secret names. All other value paths (`licenseSecret`, `maestro.*`, `service`, `ingress`,
`subdomainHostName`, `subdomainRootName`, `environmentShortName`, scheduling,
resources, `updateStrategy`, `restartJob.*`) keep identical defaults and
semantics.

```yaml
image:
  repository: your-registry.example.com/maestrod                       # no default in public chart
  tag: stable                                                          # default was 'stable', now empty (falls back to appVersion)
  pullPolicy: Always                                                   # default was 'Always', now 'IfNotPresent'

imagePullSecrets:
  - name: your-image-registry-secret                                   # default was this, now []

podLabels:
  component_name: maestrod                                             # default was this, now {}
  otel/logging-enabled: "true"

# only if restartJob.enabled: true
restartJob:
  registryAuthSecretName: your-image-registry-secret                   # default was this, now ""
```

The Deployment selector labels are byte-identical between the internal and
public chart, so existing releases can be upgraded in place without hitting
selector-immutability errors.

## Restart Job

The chart ships an optional CronJob that polls the configured image registry
for a new digest on the running `image.tag` and patches the Maestrod
Deployment with a `nutrient/refresh-tag` annotation to trigger a rollout.

It is disabled by default. To enable, set:

```yaml
restartJob:
  enabled: true
  schedule: "*/10 * * * *"
  registryAuthSecretName: my-registry-credentials   # required: must be a kubernetes.io/dockerconfigjson Secret
```

The CronJob runs under a dedicated ServiceAccount with a Role that grants
`get/list pods` and `get/list/update/patch deployments` in the release
namespace.

## Values

### Maestrod License

| Key | Description | Default |
|-----|-------------|---------|
| [`licenseSecret`](./values.yaml#L9) | Maestrod license. When `licenseSecret.name` is non-empty (the default), the chart wires the `NUTRIENT_LICENSE_KEY` environment variable to the referenced Secret/key. The Secret is **not** managed by the chart and must exist in the release namespace prior to install. Set `licenseSecret.name: ""` to omit the env var entirely (e.g. for chart-level template tests where the license is not exercised). | [...](./values.yaml#L9) |
| [`licenseSecret.key`](./values.yaml#L19) | Key inside the referenced Secret whose value is the Maestrod activation key. The chart wires this into the `NUTRIENT_LICENSE_KEY` environment variable. | `"NUTRIENT_LICENSE_KEY"` |
| [`licenseSecret.name`](./values.yaml#L14) | Name of the pre-existing Kubernetes Secret that holds the Maestrod activation key. When empty, the chart skips wiring the `NUTRIENT_LICENSE_KEY` env var. | `"maestrod-secret"` |

### Maestrod configuration

| Key | Description | Default |
|-----|-------------|---------|
| [`maestro`](./values.yaml#L26) | Maestrod-specific runtime settings. `showScalar` and `nativeSdkVisionLogs` map to `NUTRIENT_*` / `NATIVESDK_*` environment variables; `releaseVersion` maps to `MAESTRO_RELEASE_VERSION`. | [...](./values.yaml#L26) |
| [`maestro.nativeSdkVisionLogs`](./values.yaml#L34) | `NATIVESDK_VISION_LOGS` — enable native SDK vision-mode logging. Rendered as a string-quoted boolean. | `false` |
| [`maestro.releaseVersion`](./values.yaml#L44) | `MAESTRO_RELEASE_VERSION`: release name Maestrod reports as its version (OpenAPI `info.version`), verbatim. When empty, the chart derives it from `image.tag` (falling back to the chart's `appVersion`), with any `@sha256:...` digest suffix removed, so `latest`, `nightly` or `1.6.0` is reported as deployed. Set it explicitly when the tag does not name the release, e.g. a digest-pinned deployment. It only changes the reported version, not the binary. Rendered into the chart ConfigMap, so `extraEnvs`/`extraEnvFrom` entries with the same name take precedence. | `""` |
| [`maestro.showScalar`](./values.yaml#L30) | `NUTRIENT_SHOW_SCALAR` — enable Nutrient Scalar integration in the Maestrod UI. Rendered as a string-quoted boolean. | `false` |

### Environment

| Key | Description | Default |
|-----|-------------|---------|
| [`extraEnvFrom`](./values.yaml#L103) | Extra `envFrom` sources appended to the Maestrod container. | `[]` |
| [`extraEnvFromSecrets`](./values.yaml#L112) | Extra Secret names whose contents are loaded into the container env via `envFrom: secretRef:`. Convenience for the common case of supplying credentials. | `[]` |
| [`extraEnvs`](./values.yaml#L97) | Extra environment variables appended to the Maestrod container. | `[]` |
| [`extraVolumeMounts`](./values.yaml#L121) | Additional volume mounts for the Maestrod container. | `[]` |
| [`extraVolumes`](./values.yaml#L117) | Additional volumes for the pod. | `[]` |
| [`image`](./values.yaml#L49) | Image settings. | [...](./values.yaml#L49) |
| [`image.pullPolicy`](./values.yaml#L57) | Image pull policy. | `"IfNotPresent"` |
| [`image.repository`](./values.yaml#L54) | Image repository. The default points at the canonical public Nutrient registry; override to use a private registry or mirror. The schema rejects an empty string. | `"pspdfkit/maestrod"` |
| [`image.tag`](./values.yaml#L60) | Image tag. Defaults to the chart's `appVersion` when empty. | `""` |
| [`imagePullSecrets`](./values.yaml#L65) | [ImagePullSecrets](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod) referencing pre-existing Secrets in the release namespace. | `[]` |
| [`initContainers`](./values.yaml#L130) | [Init containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) for the pod. | `[]` |
| [`podSecurityContext`](./values.yaml#L90) | [Pod security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/). | `{}` |
| [`securityContext`](./values.yaml#L93) | [Container security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/). | `{}` |
| [`serviceAccount`](./values.yaml#L73) | ServiceAccount for the Maestrod pod. With `create: false` (default), the pod runs under the namespace's `default` ServiceAccount and no ServiceAccount resource is created by the chart. | [...](./values.yaml#L73) |
| [`serviceAccount.annotations`](./values.yaml#L79) | Annotations for the created ServiceAccount. | `{}` |
| [`serviceAccount.automount`](./values.yaml#L86) | Auto-mount the ServiceAccount token in the pod. | `false` |
| [`serviceAccount.create`](./values.yaml#L76) | Create a ServiceAccount. | `true` |
| [`serviceAccount.name`](./values.yaml#L83) | Name to use for the ServiceAccount. When empty and `create: true`, the chart's fullname is used. | `""` |
| [`sidecars`](./values.yaml#L125) | Additional sidecar containers for the pod. | `[]` |

### Metadata

| Key | Description | Default |
|-----|-------------|---------|
| [`deploymentAnnotations`](./values.yaml#L148) | Annotations for the Deployment resource itself (distinct from `podAnnotations`, which apply to the pod template). | `{}` |
| [`fullnameOverride`](./values.yaml#L137) | Release full name override. | `""` |
| [`nameOverride`](./values.yaml#L134) | Release name override. | `""` |
| [`podAnnotations`](./values.yaml#L144) | Pod annotations. | `{}` |
| [`podLabels`](./values.yaml#L141) | Pod labels merged on top of the common chart labels. | `{}` |

### Networking

| Key | Description | Default |
|-----|-------------|---------|
| [`environmentShortName`](./values.yaml#L215) | Short environment identifier (e.g. `staging`, `prod`). Kept for backwards compatibility; not currently consumed by any template. | `""` |
| [`ingress`](./values.yaml#L173) | Ingress for the Maestrod Service. Single-host structure for backwards compatibility with the internal `0.3.x` chart. The host is resolved from `ingress.host` (preferred), or composed from `subdomainHostName` + `subdomainRootName` (fallback). | [...](./values.yaml#L173) |
| [`ingress.annotations`](./values.yaml#L183) | Ingress annotations. The chart additionally injects an `external-dns.alpha.kubernetes.io/hostname` annotation with the resolved host. | `{}` |
| [`ingress.className`](./values.yaml#L179) | Ingress class name. | `"nginx"` |
| [`ingress.enabled`](./values.yaml#L176) | Enable ingress. | `false` |
| [`ingress.host`](./values.yaml#L187) | Explicit ingress host. When empty, the host is composed from `subdomainHostName` and `subdomainRootName`. | `""` |
| [`ingress.path`](./values.yaml#L190) | Ingress path. | `"/"` |
| [`ingress.pathType`](./values.yaml#L193) | Path type. | `"Prefix"` |
| [`ingress.tls`](./values.yaml#L197) | Ingress TLS settings. | [...](./values.yaml#L197) |
| [`ingress.tls.enabled`](./values.yaml#L200) | Enable TLS. | `false` |
| [`ingress.tls.secretName`](./values.yaml#L203) | TLS secret name. When empty, defaults to `<fullname>-ingress`. | `""` |
| [`service`](./values.yaml#L153) | Service exposing the Maestrod container. | [...](./values.yaml#L153) |
| [`service.annotations`](./values.yaml#L165) | Service annotations. | `{}` |
| [`service.port`](./values.yaml#L159) | Service port. | `5000` |
| [`service.targetPort`](./values.yaml#L162) | Container port the Service routes to. | `5000` |
| [`service.type`](./values.yaml#L156) | Service type. | `"ClusterIP"` |
| [`subdomainHostName`](./values.yaml#L208) | Subdomain part of the composed ingress host. Used when `ingress.host` is empty: the chart joins `<subdomainHostName>.<subdomainRootName>`. | `""` |
| [`subdomainRootName`](./values.yaml#L211) | Root domain part of the composed ingress host. | `""` |

### Observability

| Key | Description | Default |
|-----|-------------|---------|
| [`observability`](./values.yaml#L220) | Observability settings for Maestrod. | [...](./values.yaml#L220) |
| [`observability.metrics`](./values.yaml#L224) | Metrics integration settings. | [...](./values.yaml#L224) |
| [`observability.metrics.serviceMonitor`](./values.yaml#L229) | Prometheus [ServiceMonitor](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.ServiceMonitor) scraping Maestrod's `/metrics` endpoint on the existing `http` Service port. | [...](./values.yaml#L229) |
| [`observability.metrics.serviceMonitor.enabled`](./values.yaml#L232) | Create a Prometheus Operator ServiceMonitor for Maestrod. | `false` |
| [`observability.metrics.serviceMonitor.honorLabels`](./values.yaml#L253) | Honor labels from scraped metrics. | `false` |
| [`observability.metrics.serviceMonitor.interval`](./values.yaml#L238) | Scrape interval for the ServiceMonitor endpoint. | `"30s"` |
| [`observability.metrics.serviceMonitor.jobLabel`](./values.yaml#L256) | ServiceMonitor job label. | `""` |
| [`observability.metrics.serviceMonitor.labels`](./values.yaml#L244) | Extra labels added to the ServiceMonitor metadata. | `{}` |
| [`observability.metrics.serviceMonitor.metricRelabelings`](./values.yaml#L250) | Metric relabeling rules for the ServiceMonitor endpoint. | `[]` |
| [`observability.metrics.serviceMonitor.namespace`](./values.yaml#L235) | Namespace where the ServiceMonitor is created. Defaults to the release namespace when empty. | `""` |
| [`observability.metrics.serviceMonitor.relabelings`](./values.yaml#L247) | Relabeling rules for the ServiceMonitor endpoint. | `[]` |
| [`observability.metrics.serviceMonitor.scrapeTimeout`](./values.yaml#L241) | Scrape timeout for the ServiceMonitor endpoint. Omitted when empty. | `""` |

### Pod lifecycle

| Key | Description | Default |
|-----|-------------|---------|
| [`lifecycle`](./values.yaml#L307) | [Container lifecycle hooks](https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/). | `{}` |
| [`livenessProbe`](./values.yaml#L279) | [Liveness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) against Maestrod's `/health` HTTP endpoint. Polls less often than readiness and is more forgiving — a failure restarts the container, so this should only trip on true deadlock. Set `livenessProbe: {}` to disable. | [...](./values.yaml#L279) |
| [`readinessProbe`](./values.yaml#L293) | [Readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) against Maestrod's `/health` HTTP endpoint. Set `readinessProbe: {}` to disable. | [...](./values.yaml#L293) |
| [`startupProbe`](./values.yaml#L264) | [Startup probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) against Maestrod's `/health` HTTP endpoint. Generous `failureThreshold` so a slow initial boot doesn't get killed (10 s × 30 = 5 min budget). Set `startupProbe: {}` to disable. | [...](./values.yaml#L264) |
| [`terminationGracePeriodSeconds`](./values.yaml#L304) | [Termination grace period](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/). | `30` |

### Scheduling

| Key | Description | Default |
|-----|-------------|---------|
| [`affinity`](./values.yaml#L442) | Node affinity. | `{}` |
| [`autoscaling`](./values.yaml#L314) | [HorizontalPodAutoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/). When `enabled: true`, the chart's HPA controls the replica count and `replicaCount` is ignored. Mutually exclusive with `keda.enabled`. | [...](./values.yaml#L314) |
| [`autoscaling.behavior`](./values.yaml#L332) | HPA [scaling behaviour](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#configurable-scaling-behavior). | `{}` |
| [`autoscaling.enabled`](./values.yaml#L317) | Enable the HPA. | `false` |
| [`autoscaling.maxReplicas`](./values.yaml#L323) | Maximum replicas. | `10` |
| [`autoscaling.minReplicas`](./values.yaml#L320) | Minimum replicas. | `1` |
| [`autoscaling.targetCPUUtilizationPercentage`](./values.yaml#L326) | Target average CPU utilisation (percentage). `null` disables the metric. | `nil` |
| [`autoscaling.targetMemoryUtilizationPercentage`](./values.yaml#L329) | Target average memory utilisation (percentage). `null` disables the metric. | `nil` |
| [`keda`](./values.yaml#L341) | [KEDA](https://keda.sh/) autoscaling. When `enabled: true`, the chart renders a `keda.sh/v1alpha1` ScaledObject targeting the Deployment, KEDA creates and owns the HPA, and `replicaCount` is ignored. Requires KEDA in the cluster. Mutually exclusive with `autoscaling.enabled`: rendering fails when both are `true`. | [...](./values.yaml#L341) |
| [`keda.advanced`](./values.yaml#L373) | [Advanced](https://keda.sh/docs/latest/reference/scaledobject-spec/#advanced) settings, rendered verbatim; omitted when empty. HPA scaling behaviour goes in `horizontalPodAutoscalerConfig.behavior`. | `{}` |
| [`keda.annotations`](./values.yaml#L347) | Annotations for the ScaledObject. | `{}` |
| [`keda.cooldownPeriod`](./values.yaml#L363) | Seconds to wait after the last active trigger before scaling to zero (`spec.cooldownPeriod`). KEDA applies it only to scale-to-zero, when `minReplicaCount` is `0`. Pace scale-down between non-zero replica counts with `advanced.horizontalPodAutoscalerConfig.behavior` instead. `null` omits the field. | `nil` |
| [`keda.enabled`](./values.yaml#L344) | Enable the KEDA ScaledObject. | `false` |
| [`keda.fallback`](./values.yaml#L368) | [Fallback](https://keda.sh/docs/latest/reference/scaledobject-spec/#fallback) replica count used when the triggers fail. Rendered verbatim; omitted when empty. | `{}` |
| [`keda.maxReplicaCount`](./values.yaml#L353) | Maximum replicas (`spec.maxReplicaCount`). | `10` |
| [`keda.minReplicaCount`](./values.yaml#L350) | Minimum replicas (`spec.minReplicaCount`). | `1` |
| [`keda.pollingInterval`](./values.yaml#L356) | Seconds between two checks of each trigger (`spec.pollingInterval`). | `30` |
| [`keda.triggers`](./values.yaml#L378) | [Triggers](https://keda.sh/docs/latest/reference/scaledobject-spec/#triggers), rendered verbatim. Rendering fails when `enabled: true` and the list is empty. Trigger `metadata` values must be strings. | `[]` |
| [`nodeSelector`](./values.yaml#L439) | [Node selector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/). | `{}` |
| [`podDisruptionBudget`](./values.yaml#L426) | [PodDisruptionBudget](https://kubernetes.io/docs/tasks/run-application/configure-pdb/). When both `minAvailable` and `maxUnavailable` are non-empty, `maxUnavailable` wins (the two fields are mutually exclusive in Kubernetes). Either field accepts an integer (e.g. `1`) or a percentage string (e.g. `"50%"`). | [...](./values.yaml#L426) |
| [`podDisruptionBudget.create`](./values.yaml#L429) | Create a PodDisruptionBudget for Maestrod. | `false` |
| [`podDisruptionBudget.maxUnavailable`](./values.yaml#L435) | `spec.maxUnavailable`. Integer or percentage string. Takes precedence over `minAvailable`. | `""` |
| [`podDisruptionBudget.minAvailable`](./values.yaml#L432) | `spec.minAvailable`. Integer or percentage string. Ignored when `maxUnavailable` is set. | `1` |
| [`priorityClassName`](./values.yaml#L451) | [PriorityClass](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/) name. | `""` |
| [`progressDeadlineSeconds`](./values.yaml#L418) | Seconds a rollout may go without progress before the Deployment reports it failed ([progress deadline](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#progress-deadline-seconds)). Empty keeps the Kubernetes default of 600. Raise it when old pods drain for longer than that while their replacements wait for a node. | `nil` |
| [`replicaCount`](./values.yaml#L399) | Number of replicas. Ignored when `autoscaling.enabled` or `keda.enabled` is `true`. | `3` |
| [`resources`](./values.yaml#L388) | [Resources](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/). | `{"limits":{"cpu":"4","memory":"8Gi"},"requests":{"cpu":"4","memory":"8Gi"}}` |
| [`revisionHistoryLimit`](./values.yaml#L412) | [Revision history limit](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#clean-up-policy). | `1` |
| [`schedulerName`](./values.yaml#L454) | [Scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/) name. | `""` |
| [`tolerations`](./values.yaml#L445) | [Node tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/). | `[]` |
| [`topologySpreadConstraints`](./values.yaml#L448) | [Topology spread constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/). | `[]` |
| [`updateStrategy`](./values.yaml#L405) | [Update strategy](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy). `rollingUpdate.maxSurge` and `rollingUpdate.maxUnavailable` are `IntOrString` in Kubernetes — both an integer (e.g. `1`) and a percentage string (e.g. `"25%"`) are accepted. | `{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0},"type":"RollingUpdate"}` |

### Restart job

| Key | Description | Default |
|-----|-------------|---------|
| [`restartJob`](./values.yaml#L461) | Optional CronJob that polls the configured image registry for a new digest on the running `image.tag` and patches the Maestrod Deployment with a refresh annotation to trigger a rollout. Disabled by default. | [...](./values.yaml#L461) |
| [`restartJob.affinity`](./values.yaml#L501) | Affinity for the restart-job pod. | `{}` |
| [`restartJob.enabled`](./values.yaml#L464) | Enable the restart-job CronJob and its supporting RBAC/ServiceAccount. | `false` |
| [`restartJob.image`](./values.yaml#L472) | Image for the restart-job container. Must contain `kubectl`, `curl`, `jq`, and `bash` — `alpine/k8s` covers all four. | [...](./values.yaml#L472) |
| [`restartJob.nodeSelector`](./values.yaml#L495) | Node selector for the restart-job pod. | `{}` |
| [`restartJob.podAnnotations`](./values.yaml#L483) | Pod annotations for the restart-job pod. | `{"skip-auto-labelling":"true"}` |
| [`restartJob.podLabels`](./values.yaml#L487) | Pod labels for the restart-job pod. | `{}` |
| [`restartJob.registryAuthSecretName`](./values.yaml#L480) | Name of a pre-existing `kubernetes.io/dockerconfigjson` Secret holding the registry credentials used to query the image manifest. Required when `restartJob.enabled: true`; rendering fails otherwise. | `""` |
| [`restartJob.schedule`](./values.yaml#L467) | CronJob schedule. | `"*/10 * * * *"` |
| [`restartJob.serviceAccount`](./values.yaml#L491) | ServiceAccount for the restart-job pod. | [...](./values.yaml#L491) |
| [`restartJob.tolerations`](./values.yaml#L498) | Tolerations for the restart-job pod. | `[]` |

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

# Maestrod Helm chart

> [!WARNING] This chart is made for internal use by Nutrient.

![Version: 0.5.0](https://img.shields.io/badge/Version-0.5.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.1.1](https://img.shields.io/badge/AppVersion-v1.1.1-informational?style=flat-square)

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

## Migrating from the internal 0.3.x chart

This is the first public release of the chart. It is value-compatible with
the internal `cloud-demo-infra/charts/maestrod@0.3.4`, with a small number of
defaults reset to neutral values. If your existing values file relied on any
of the internal defaults below, copy them into your values file as-is. All
other value paths (`licenseSecret`, `maestro.*`, `service`, `ingress`,
`subdomainHostName`, `subdomainRootName`, `environmentShortName`, scheduling,
resources, `updateStrategy`, `restartJob.*`) keep identical defaults and
semantics.

```yaml
image:
  repository: 111300957880.dkr.ecr.eu-west-1.amazonaws.com/maestrod  # no default in public chart
  tag: stable                                                          # default was 'stable', now empty (falls back to appVersion)
  pullPolicy: Always                                                   # default was 'Always', now 'IfNotPresent'

imagePullSecrets:
  - name: image-registry-mcleod-ecr                                    # default was this, now []

podLabels:
  component_name: maestrod                                             # default was this, now {}
  otel/logging-enabled: "true"

# only if restartJob.enabled: true
restartJob:
  registryAuthSecretName: image-registry-mcleod-ecr                    # default was this, now ""
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
| [`maestro`](./values.yaml#L25) | Maestrod-specific runtime flags. Each key maps directly to a `NUTRIENT_*` / `NATIVESDK_*` environment variable on the container. | [...](./values.yaml#L25) |
| [`maestro.nativeSdkVisionLogs`](./values.yaml#L33) | `NATIVESDK_VISION_LOGS` — enable native SDK vision-mode logging. Rendered as a string-quoted boolean. | `false` |
| [`maestro.showScalar`](./values.yaml#L29) | `NUTRIENT_SHOW_SCALAR` — enable Nutrient Scalar integration in the Maestrod UI. Rendered as a string-quoted boolean. | `false` |

### Environment

| Key | Description | Default |
|-----|-------------|---------|
| [`extraEnvFrom`](./values.yaml#L92) | Extra `envFrom` sources appended to the Maestrod container. | `[]` |
| [`extraEnvFromSecrets`](./values.yaml#L101) | Extra Secret names whose contents are loaded into the container env via `envFrom: secretRef:`. Convenience for the common case of supplying credentials. | `[]` |
| [`extraEnvs`](./values.yaml#L86) | Extra environment variables appended to the Maestrod container. | `[]` |
| [`extraVolumeMounts`](./values.yaml#L110) | Additional volume mounts for the Maestrod container. | `[]` |
| [`extraVolumes`](./values.yaml#L106) | Additional volumes for the pod. | `[]` |
| [`image`](./values.yaml#L38) | Image settings. | [...](./values.yaml#L38) |
| [`image.pullPolicy`](./values.yaml#L46) | Image pull policy. | `"IfNotPresent"` |
| [`image.repository`](./values.yaml#L43) | Image repository. The default points at the canonical public Nutrient registry; override to use a private registry or mirror. The schema rejects an empty string. | `"pspdfkit/maestrod"` |
| [`image.tag`](./values.yaml#L49) | Image tag. Defaults to the chart's `appVersion` when empty. | `""` |
| [`imagePullSecrets`](./values.yaml#L54) | [ImagePullSecrets](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod) referencing pre-existing Secrets in the release namespace. | `[]` |
| [`initContainers`](./values.yaml#L119) | [Init containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) for the pod. | `[]` |
| [`podSecurityContext`](./values.yaml#L79) | [Pod security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/). | `{}` |
| [`securityContext`](./values.yaml#L82) | [Container security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/). | `{}` |
| [`serviceAccount`](./values.yaml#L62) | ServiceAccount for the Maestrod pod. With `create: false` (default), the pod runs under the namespace's `default` ServiceAccount and no ServiceAccount resource is created by the chart. | [...](./values.yaml#L62) |
| [`serviceAccount.annotations`](./values.yaml#L68) | Annotations for the created ServiceAccount. | `{}` |
| [`serviceAccount.automount`](./values.yaml#L75) | Auto-mount the ServiceAccount token in the pod. | `false` |
| [`serviceAccount.create`](./values.yaml#L65) | Create a ServiceAccount. | `true` |
| [`serviceAccount.name`](./values.yaml#L72) | Name to use for the ServiceAccount. When empty and `create: true`, the chart's fullname is used. | `""` |
| [`sidecars`](./values.yaml#L114) | Additional sidecar containers for the pod. | `[]` |

### Metadata

| Key | Description | Default |
|-----|-------------|---------|
| [`deploymentAnnotations`](./values.yaml#L137) | Annotations for the Deployment resource itself (distinct from `podAnnotations`, which apply to the pod template). | `{}` |
| [`fullnameOverride`](./values.yaml#L126) | Release full name override. | `""` |
| [`nameOverride`](./values.yaml#L123) | Release name override. | `""` |
| [`podAnnotations`](./values.yaml#L133) | Pod annotations. | `{}` |
| [`podLabels`](./values.yaml#L130) | Pod labels merged on top of the common chart labels. | `{}` |

### Networking

| Key | Description | Default |
|-----|-------------|---------|
| [`environmentShortName`](./values.yaml#L204) | Short environment identifier (e.g. `staging`, `prod`). Kept for backwards compatibility; not currently consumed by any template. | `""` |
| [`ingress`](./values.yaml#L162) | Ingress for the Maestrod Service. Single-host structure for backwards compatibility with the internal `0.3.x` chart. The host is resolved from `ingress.host` (preferred), or composed from `subdomainHostName` + `subdomainRootName` (fallback). | [...](./values.yaml#L162) |
| [`ingress.annotations`](./values.yaml#L172) | Ingress annotations. The chart additionally injects an `external-dns.alpha.kubernetes.io/hostname` annotation with the resolved host. | `{}` |
| [`ingress.className`](./values.yaml#L168) | Ingress class name. | `"nginx"` |
| [`ingress.enabled`](./values.yaml#L165) | Enable ingress. | `false` |
| [`ingress.host`](./values.yaml#L176) | Explicit ingress host. When empty, the host is composed from `subdomainHostName` and `subdomainRootName`. | `""` |
| [`ingress.path`](./values.yaml#L179) | Ingress path. | `"/"` |
| [`ingress.pathType`](./values.yaml#L182) | Path type. | `"Prefix"` |
| [`ingress.tls`](./values.yaml#L186) | Ingress TLS settings. | [...](./values.yaml#L186) |
| [`ingress.tls.enabled`](./values.yaml#L189) | Enable TLS. | `false` |
| [`ingress.tls.secretName`](./values.yaml#L192) | TLS secret name. When empty, defaults to `<fullname>-ingress`. | `""` |
| [`service`](./values.yaml#L142) | Service exposing the Maestrod container. | [...](./values.yaml#L142) |
| [`service.annotations`](./values.yaml#L154) | Service annotations. | `{}` |
| [`service.port`](./values.yaml#L148) | Service port. | `5000` |
| [`service.targetPort`](./values.yaml#L151) | Container port the Service routes to. | `5000` |
| [`service.type`](./values.yaml#L145) | Service type. | `"ClusterIP"` |
| [`subdomainHostName`](./values.yaml#L197) | Subdomain part of the composed ingress host. Used when `ingress.host` is empty: the chart joins `<subdomainHostName>.<subdomainRootName>`. | `""` |
| [`subdomainRootName`](./values.yaml#L200) | Root domain part of the composed ingress host. | `""` |

### Pod lifecycle

| Key | Description | Default |
|-----|-------------|---------|
| [`lifecycle`](./values.yaml#L224) | [Container lifecycle hooks](https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/). | `{}` |
| [`livenessProbe`](./values.yaml#L214) | [Liveness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/). Empty by default. Provide a probe spec to enable. | `{}` |
| [`readinessProbe`](./values.yaml#L218) | [Readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/). Empty by default. Provide a probe spec to enable. | `{}` |
| [`startupProbe`](./values.yaml#L210) | [Startup probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/). Empty by default (no probe configured) for backwards compatibility with the internal `0.3.x` chart. Provide a probe spec to enable. | `{}` |
| [`terminationGracePeriodSeconds`](./values.yaml#L221) | [Termination grace period](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/). | `30` |

### Scheduling

| Key | Description | Default |
|-----|-------------|---------|
| [`affinity`](./values.yaml#L300) | Node affinity. | `{}` |
| [`autoscaling`](./values.yaml#L231) | [HorizontalPodAutoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/). When `enabled: true`, the chart's HPA controls the replica count and `replicaCount` is ignored. | [...](./values.yaml#L231) |
| [`autoscaling.behavior`](./values.yaml#L249) | HPA [scaling behaviour](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#configurable-scaling-behavior). | `{}` |
| [`autoscaling.enabled`](./values.yaml#L234) | Enable the HPA. | `false` |
| [`autoscaling.maxReplicas`](./values.yaml#L240) | Maximum replicas. | `10` |
| [`autoscaling.minReplicas`](./values.yaml#L237) | Minimum replicas. | `1` |
| [`autoscaling.targetCPUUtilizationPercentage`](./values.yaml#L243) | Target average CPU utilisation (percentage). `null` disables the metric. | `nil` |
| [`autoscaling.targetMemoryUtilizationPercentage`](./values.yaml#L246) | Target average memory utilisation (percentage). `null` disables the metric. | `nil` |
| [`nodeSelector`](./values.yaml#L297) | [Node selector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/). | `{}` |
| [`podDisruptionBudget`](./values.yaml#L284) | [PodDisruptionBudget](https://kubernetes.io/docs/tasks/run-application/configure-pdb/). When both `minAvailable` and `maxUnavailable` are non-empty, `maxUnavailable` wins (the two fields are mutually exclusive in Kubernetes). Either field accepts an integer (e.g. `1`) or a percentage string (e.g. `"50%"`). | [...](./values.yaml#L284) |
| [`podDisruptionBudget.create`](./values.yaml#L287) | Create a PodDisruptionBudget for Maestrod. | `false` |
| [`podDisruptionBudget.maxUnavailable`](./values.yaml#L293) | `spec.maxUnavailable`. Integer or percentage string. Takes precedence over `minAvailable`. | `""` |
| [`podDisruptionBudget.minAvailable`](./values.yaml#L290) | `spec.minAvailable`. Integer or percentage string. Ignored when `maxUnavailable` is set. | `1` |
| [`priorityClassName`](./values.yaml#L309) | [PriorityClass](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/) name. | `""` |
| [`replicaCount`](./values.yaml#L263) | Number of replicas. Ignored when `autoscaling.enabled` is `true`. | `3` |
| [`resources`](./values.yaml#L253) | [Resources](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/). | `{"limits":{"cpu":"4","memory":"8Gi"},"requests":{"cpu":"4","memory":"8Gi"}}` |
| [`revisionHistoryLimit`](./values.yaml#L276) | [Revision history limit](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#clean-up-policy). | `1` |
| [`schedulerName`](./values.yaml#L312) | [Scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/) name. | `""` |
| [`tolerations`](./values.yaml#L303) | [Node tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/). | `[]` |
| [`topologySpreadConstraints`](./values.yaml#L306) | [Topology spread constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/). | `[]` |
| [`updateStrategy`](./values.yaml#L269) | [Update strategy](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy). `rollingUpdate.maxSurge` and `rollingUpdate.maxUnavailable` are `IntOrString` in Kubernetes — both an integer (e.g. `1`) and a percentage string (e.g. `"25%"`) are accepted. | `{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0},"type":"RollingUpdate"}` |

### Restart job

| Key | Description | Default |
|-----|-------------|---------|
| [`restartJob`](./values.yaml#L319) | Optional CronJob that polls the configured image registry for a new digest on the running `image.tag` and patches the Maestrod Deployment with a refresh annotation to trigger a rollout. Disabled by default. | [...](./values.yaml#L319) |
| [`restartJob.affinity`](./values.yaml#L359) | Affinity for the restart-job pod. | `{}` |
| [`restartJob.enabled`](./values.yaml#L322) | Enable the restart-job CronJob and its supporting RBAC/ServiceAccount. | `false` |
| [`restartJob.image`](./values.yaml#L330) | Image for the restart-job container. Must contain `kubectl`, `curl`, `jq`, and `bash` — `alpine/k8s` covers all four. | [...](./values.yaml#L330) |
| [`restartJob.nodeSelector`](./values.yaml#L353) | Node selector for the restart-job pod. | `{}` |
| [`restartJob.podAnnotations`](./values.yaml#L341) | Pod annotations for the restart-job pod. | `{"skip-auto-labelling":"true"}` |
| [`restartJob.podLabels`](./values.yaml#L345) | Pod labels for the restart-job pod. | `{}` |
| [`restartJob.registryAuthSecretName`](./values.yaml#L338) | Name of a pre-existing `kubernetes.io/dockerconfigjson` Secret holding the registry credentials used to query the image manifest. Required when `restartJob.enabled: true`; rendering fails otherwise. | `""` |
| [`restartJob.schedule`](./values.yaml#L325) | CronJob schedule. | `"*/10 * * * *"` |
| [`restartJob.serviceAccount`](./values.yaml#L349) | ServiceAccount for the restart-job pod. | [...](./values.yaml#L349) |
| [`restartJob.tolerations`](./values.yaml#L356) | Tolerations for the restart-job pod. | `[]` |

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

{{/*
Expand the name of the chart.
*/}}
{{- define "document-engine.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "document-engine.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "document-engine.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "document-engine.labels" -}}
helm.sh/chart: {{ include "document-engine.chart" . }}
{{ include "document-engine.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "document-engine.selectorLabels" -}}
app.kubernetes.io/name: {{ include "document-engine.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "document-engine.expirationSelectorLabels" -}}
document-engine.something/job: cleanup
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "document-engine.migrationSelectorLabels" -}}
document-engine.something/job: migration
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "document-engine.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "document-engine.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
License secret name
*/}}
{{- define "document-engine.license.secret.name" -}}
  {{- if not .Values.documentEngineLicense.externalSecret.name -}}
    {{- printf "%s-license" (include "document-engine.fullname" .) -}}
  {{- else -}}
    {{- .Values.documentEngineLicense.externalSecret.name -}}
  {{- end -}}
{{- end -}}

{{- define "document-engine.license.secret.key" -}}
  {{- if not .Values.documentEngineLicense.externalSecret.name -}}
    ACTIVATION_KEY
  {{- else -}}
    {{- .Values.documentEngineLicense.externalSecret.key -}}
  {{- end -}}
{{- end -}}

{{- define "document-engine.license.available" -}}
  {{- if or .Values.documentEngineLicense.activationKey 
            .Values.documentEngineLicense.externalSecret.name -}}
    {{- true -}}
  {{- else -}}
    {{- false -}}
  {{- end -}}
{{- end -}}

{{/*
Clustering and networking
*/}}
{{- define "document-engine.clustering.service.enabled" -}}
  {{- if and .Values.clustering.enabled
             (eq .Values.clustering.method "kubernetes_dns") -}}
    {{- true -}}
  {{- else -}}
    {{- false -}}
  {{- end -}}
{{- end }}

{{- define "document-engine.clustering.service.name" -}}
  {{- include "document-engine.fullname" . }}-cl
{{- end }}

{{- define "document-engine.envoySidecar.enabled" -}}
  {{- if and .Values.envoySidecar.enabled
             (gt .Values.replicaCount 1) -}}
    {{- true -}}
  {{- else -}}
    {{- false -}}
  {{- end -}}
{{- end }}

{{/*
Database parameters
*/}}
{{- define "document-engine.storage.postgres.enabled" -}}
  {{- if and .Values.database.enabled 
             (eq .Values.database.engine "postgres") -}}
    {{- true -}}
  {{- else -}}
    {{- false -}}
  {{- end -}}
{{- end -}}

{{- define "document-engine.storage.redis.secret.name" -}}
  {{- if not .Values.assetStorage.redis.externalSecretName -}}
    {{- printf "%s-redis" (include "document-engine.fullname" .) -}}
  {{- else -}}
    {{- .Values.assetStorage.redis.externalSecretName -}}
  {{- end -}}
{{- end -}}

{{/*
Object storage parameters
*/}}
{{- define "document-engine.storage.s3.enabled" -}}
  {{- if or (eq .Values.assetStorage.backendType "s3")
            (and .Values.assetStorage.backendFallback.enabled
                 .Values.assetStorage.backendFallback.enabledS3 ) -}}
    {{- true -}}
  {{- else -}}
    {{- false -}}
  {{- end -}}
{{- end -}}

{{- define "document-engine.storage.s3.createSecret" -}}
  {{- if and (eq (include "document-engine.storage.s3.enabled" .) "true") 
             (not .Values.assetStorage.s3.externalSecretName) -}}
    {{- true -}}
  {{- else -}}
    {{- false -}}
  {{- end -}}
{{- end -}}

{{- define "document-engine.storage.s3.secret.name" -}}
  {{- if (eq (include "document-engine.storage.s3.createSecret" .) "true") -}}
    {{- printf "%s-s3" (include "document-engine.fullname" .) -}}
  {{- else -}}
    {{- .Values.assetStorage.s3.externalSecretName -}}
  {{- end -}}
{{- end -}}

{{- define "document-engine.storage.azure.enabled" -}}
  {{- if or (eq .Values.assetStorage.backendType "azure")
            (and .Values.assetStorage.backendFallback.enabled
                 .Values.assetStorage.backendFallback.enabledAzure ) -}}
    {{- true -}}
  {{- else -}}
    {{- false -}}
  {{- end -}}
{{- end -}}

{{- define "document-engine.storage.azure.createSecret" -}}
  {{- if and (eq (include "document-engine.storage.azure.enabled" .) "true") 
             (not .Values.assetStorage.azure.externalSecretName) -}}
    {{- true -}}
  {{- else -}}
    {{- false -}}
  {{- end -}}
{{- end -}}

{{- define "document-engine.storage.azure.secret.name" -}}
  {{- if (eq (include "document-engine.storage.azure.createSecret" .) "true") -}}
    {{- printf "%s-azure" (include "document-engine.fullname" .) -}}
  {{- else -}}
    {{- .Values.assetStorage.azure.externalSecretName -}}
  {{- end -}}
{{- end -}}

{{/*
CloudNativePG
*/}}
{{- define "document-engine.storage.cloudNativePG.cluster.name" -}}
  {{- if .Values.cloudNativePG.clusterName -}}
    {{- tpl .Values.cloudNativePG.clusterName $ -}}
  {{- else -}}
    {{- .Release.Name }}-postgres
  {{- end -}}
{{- end -}}

{{- define "document-engine.storage.cloudNativePG.superuser-secret.name" -}}
{{- include "document-engine.storage.cloudNativePG.cluster.name" . }}-superuser
{{- end -}}

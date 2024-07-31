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

{{- define "document-engine.cleanupSelectorLabels" -}}
document-engine.pspdfkit/job: cleanup
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "document-engine.migrationSelectorLabels" -}}
document-engine.pspdfkit/job: migration
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
  {{- if not .Values.pspdfkit.license.externalSecret.name -}}
    {{- printf "%s-license" (include "document-engine.fullname" .) -}}
  {{- else -}}
    {{- .Values.pspdfkit.license.externalSecret.name -}}
  {{- end -}}
{{- end -}}

{{- define "document-engine.license.variable.name" -}}
  {{- if not .Values.pspdfkit.license.isOffline -}}
  ACTIVATION_KEY
  {{- else -}}
  LICENSE_KEY
  {{- end -}}
{{- end -}}

{{- define "document-engine.license.secret.key" -}}
  {{- if not .Values.pspdfkit.license.externalSecret.name -}}
    {{- include "document-engine.license.variable.name" . -}}
  {{- else -}}
    {{- .Values.pspdfkit.license.externalSecret.key -}}
  {{- end -}}
{{- end -}}

{{- define "document-engine.license.available" -}}
  {{- if or .Values.pspdfkit.license.activationKey 
            .Values.pspdfkit.license.externalSecret.name -}}
    {{- true -}}
  {{- else -}}
    {{- false -}}
  {{- end -}}
{{- end -}}

{{/*
API and dashboard secrets
*/}}
{{- define "document-engine.api.secret.name" -}}
  {{- if not .Values.pspdfkit.auth.api.externalSecret.name -}}
    {{- printf "%s-api-auth" (include "document-engine.fullname" .) -}}
  {{- else -}}
    {{- .Values.pspdfkit.auth.api.externalSecret.name -}}
  {{- end -}}
{{- end -}}

{{- define "document-engine.api.secret.key.apiToken" -}}
  {{- if not .Values.pspdfkit.auth.api.externalSecret.name -}}
    API_AUTH_TOKEN
  {{- else -}}
    {{- .Values.pspdfkit.auth.api.externalSecret.apiTokenKey -}}
  {{- end -}}
{{- end -}}
{{- define "document-engine.api.secret.key.jwtPublicKey" -}}
  {{- if not .Values.pspdfkit.auth.api.externalSecret.name -}}
    JWT_PUBLIC_KEY
  {{- else -}}
    {{- .Values.pspdfkit.auth.api.externalSecret.jwtPublicKeyKey -}}
  {{- end -}}
{{- end -}}
{{- define "document-engine.api.secret.key.jwtAlgorithm" -}}
  {{- if not .Values.pspdfkit.auth.api.externalSecret.name -}}
    JWT_ALGORITHM
  {{- else -}}
    {{- .Values.pspdfkit.auth.api.externalSecret.jwtAlgorithmKey -}}
  {{- end -}}
{{- end -}}

{{- define "document-engine.dashboard.secret.name" -}}
  {{- if not .Values.pspdfkit.auth.dashboard.externalSecret.name -}}
    {{- printf "%s-dashboard-auth" (include "document-engine.fullname" .) -}}
  {{- else -}}
    {{- .Values.pspdfkit.auth.dashboard.externalSecret.name -}}
  {{- end -}}
{{- end -}}
{{- define "document-engine.dashboard.secret.key.username" -}}
  {{- if not .Values.pspdfkit.auth.dashboard.externalSecret.name -}}
    DASHBOARD_USERNAME
  {{- else -}}
    {{- .Values.pspdfkit.auth.dashboard.externalSecret.usernameKey -}}
  {{- end -}}
{{- end -}}
{{- define "document-engine.dashboard.secret.key.password" -}}
  {{- if not .Values.pspdfkit.auth.dashboard.externalSecret.name -}}
    DASHBOARD_PASSWORD
  {{- else -}}
    {{- .Values.pspdfkit.auth.dashboard.externalSecret.passwordKey -}}
  {{- end -}}
{{- end -}}

{{- define "document-engine.secretKeyBase.secret.name" -}}
  {{- if not .Values.pspdfkit.secretKeyBase.externalSecret.name -}}
    {{- printf "%s-secretkeybase" (include "document-engine.fullname" .) -}}
  {{- else -}}
    {{- .Values.pspdfkit.secretKeyBase.externalSecret.name -}}
  {{- end -}}
{{- end -}}
{{- define "document-engine.secretKeyBase.secret.key" -}}
  {{- if not .Values.pspdfkit.secretKeyBase.externalSecret.name -}}
    SECRET_KEY_BASE
  {{- else -}}
    {{- .Values.pspdfkit.secretKeyBase.externalSecret.key -}}
  {{- end -}}
{{- end -}}

{{/*
Database secrets
*/}}
{{- define "document-engine.storage.postgres.secret.name" -}}
  {{- if not .Values.pspdfkit.storage.postgres.externalSecretName -}}
    {{- printf "%s-db-postgres" (include "document-engine.fullname" .) -}}
  {{- else -}}
    {{- .Values.pspdfkit.storage.postgres.externalSecretName -}}
  {{- end -}}
{{- end -}}
{{- define "document-engine.storage.postgres.createSecret" -}}
  {{- if and .Values.pspdfkit.storage.postgres.enabled 
             (not .Values.pspdfkit.storage.postgres.externalSecretName) -}}
    {{- true -}}
  {{- else -}}
    {{- false -}}
  {{- end -}}
{{- end -}}

{{- define "document-engine.storage.postgres.adminSecret.name" -}}
  {{- if not .Values.pspdfkit.storage.postgres.externalAdminSecretName -}}
    {{- printf "%s-db-postgres-admin" (include "document-engine.fullname" .) -}}
  {{- else -}}
    {{- .Values.pspdfkit.storage.postgres.externalAdminSecretName -}}
  {{- end -}}
{{- end -}}
{{- define "document-engine.storage.postgres.createAdminSecret" -}}
  {{- if and .Values.pspdfkit.storage.postgres.enabled 
             (not .Values.pspdfkit.storage.postgres.externalAdminSecretName) -}}
    {{- true -}}
  {{- else -}}
    {{- false -}}
  {{- end -}}
{{- end -}}

{{- define "document-engine.storage.redis.secret.name" -}}
  {{- if not .Values.pspdfkit.storage.redis.externalSecretName -}}
    {{- printf "%s-redis" (include "document-engine.fullname" .) -}}
  {{- else -}}
    {{- .Values.pspdfkit.storage.redis.externalSecretName -}}
  {{- end -}}
{{- end -}}
{{- define "document-engine.storage.redis.createSecret" -}}
  {{- if and .Values.pspdfkit.storage.redis.enabled 
             (not .Values.pspdfkit.storage.redis.externalSecretName) -}}
    {{- true -}}
  {{- else -}}
    {{- false -}}
  {{- end -}}
{{- end -}}

{{/*
Object storage parameters
*/}}
{{- define "document-engine.storage.s3.enabled" -}}
  {{- if or (eq .Values.pspdfkit.storage.assetStorageBackend "s3")
            (and .Values.pspdfkit.storage.enableAssetStorageFallback
                 .Values.pspdfkit.storage.enableAssetStorageFallbackS3 ) -}}
    {{- true -}}
  {{- else -}}
    {{- false -}}
  {{- end -}}
{{- end -}}

{{- define "document-engine.storage.s3.createSecret" -}}
  {{- if and (eq (include "document-engine.storage.s3.enabled" .) "true") 
             (not .Values.pspdfkit.storage.s3.externalSecretName) -}}
    {{- true -}}
  {{- else -}}
    {{- false -}}
  {{- end -}}
{{- end -}}

{{- define "document-engine.storage.s3.secret.name" -}}
  {{- if (eq (include "document-engine.storage.s3.createSecret" .) "true") -}}
    {{- printf "%s-s3" (include "document-engine.fullname" .) -}}
  {{- else -}}
    {{- .Values.pspdfkit.storage.s3.externalSecretName -}}
  {{- end -}}
{{- end -}}

{{- define "document-engine.storage.azure.enabled" -}}
  {{- if or (eq .Values.pspdfkit.storage.assetStorageBackend "azure")
            (and .Values.pspdfkit.storage.enableAssetStorageFallback
                 .Values.pspdfkit.storage.enableAssetStorageFallbackAzure ) -}}
    {{- true -}}
  {{- else -}}
    {{- false -}}
  {{- end -}}
{{- end -}}


{{- define "document-engine.storage.azure.createSecret" -}}
  {{- if and (eq (include "document-engine.storage.azure.enabled" .) "true") 
             (not .Values.pspdfkit.storage.azure.externalSecretName) -}}
    {{- true -}}
  {{- else -}}
    {{- false -}}
  {{- end -}}
{{- end -}}

{{- define "document-engine.storage.azure.secret.name" -}}
  {{- if (eq (include "document-engine.storage.azure.createSecret" .) "true") -}}
    {{- printf "%s-s3" (include "document-engine.fullname" .) -}}
  {{- else -}}
    {{- .Values.pspdfkit.storage.azure.externalSecretName -}}
  {{- end -}}
{{- end -}}

{{/*
Jobs
*/}}
{{- define "document-engine.storage.cleanupJob.enabled" -}}
{{- and .Values.pspdfkit.storage.postgres.enabled 
        .Values.pspdfkit.storage.cleanupJob.enabled 
        (eq .Values.pspdfkit.storage.assetStorageBackend "built-in") -}}
{{- end -}}

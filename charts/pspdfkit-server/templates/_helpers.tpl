{{/*
Expand the name of the chart.
*/}}
{{- define "pspdfkit-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pspdfkit-server.fullname" -}}
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
{{- define "pspdfkit-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "pspdfkit-server.labels" -}}
helm.sh/chart: {{ include "pspdfkit-server.chart" . }}
{{ include "pspdfkit-server.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "pspdfkit-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pspdfkit-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "pspdfkit-server.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "pspdfkit-server.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
License secret name
*/}}
{{- define "pspdfkit-server.license.secret.name" -}}
  {{- if not .Values.pspdfkit.license.externalSecret.name -}}
    {{- printf "%s-license" (include "pspdfkit-server.fullname" .) -}}
  {{- else -}}
    {{- .Values.pspdfkit.license.externalSecret.name -}}
  {{- end -}}
{{- end -}}

{{- define "pspdfkit-server.license.secret.key" -}}
  {{- if not .Values.pspdfkit.license.externalSecret.name -}}
    ACTIVATION_KEY
  {{- else -}}
    {{- .Values.pspdfkit.license.externalSecret.key -}}
  {{- end -}}
{{- end -}}

{{/*
Object storage parameters
*/}}
{{- define "pspdfkit-server.s3.enabled" -}}
  {{- if .Values.pspdfkit.storage.assetStorageBackend -}}
    {{- with .Values.pspdfkit.storage.assetStorageBackend -}}
      {{- if eq . "s3" -}}
        {{- true -}}
      {{- else -}}
        {{- false -}}
      {{- end -}}
    {{- end -}}
  {{- else -}}
    {{- false -}}
  {{- end -}}
{{- end -}}

{{- define "pspdfkit-server.s3.createSecret" -}}

  {{- if and (eq (include "pspdfkit-server.s3.enabled" .) "true") (not .Values.pspdfkit.storage.s3.auth.externalSecretName) -}}
    {{- true -}}
  {{- else -}}
    {{- false -}}
  {{- end -}}
{{- end -}}

{{- define "pspdfkit-server.s3.secretName" -}}
  {{- if (eq (include "pspdfkit-server.s3.createSecret" .) "true") -}}
    {{- printf "%s-s3" (include "pspdfkit-server.fullname" .) -}}
  {{- else -}}
    {{- .Values.pspdfkit.storage.s3.auth.externalSecretName -}}
  {{- end -}}
{{- end -}}

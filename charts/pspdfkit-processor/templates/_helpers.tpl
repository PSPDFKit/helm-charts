{{/*
Expand the name of the chart.
*/}}
{{- define "pspdfkit-processor.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pspdfkit-processor.fullname" -}}
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
{{- define "pspdfkit-processor.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "pspdfkit-processor.labels" -}}
helm.sh/chart: {{ include "pspdfkit-processor.chart" . }}
{{ include "pspdfkit-processor.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "pspdfkit-processor.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pspdfkit-processor.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "pspdfkit-processor.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "pspdfkit-processor.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
License secret name
*/}}
{{- define "pspdfkit-processor.license.secret.name" -}}
  {{- if not .Values.pspdfkit.license.externalSecret.name -}}
    {{- printf "%s-license" (include "pspdfkit-processor.fullname" .) -}}
  {{- else -}}
    {{- .Values.pspdfkit.license.externalSecret.name -}}
  {{- end -}}
{{- end -}}

{{- define "pspdfkit-processor.license.secret.key" -}}
  {{- if not .Values.pspdfkit.license.externalSecret.name -}}
    LICENSE_KEY
  {{- else -}}
    {{- .Values.pspdfkit.license.externalSecret.key -}}
  {{- end -}}
{{- end -}}

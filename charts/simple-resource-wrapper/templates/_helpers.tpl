{{/*
Expand the name of the chart.
*/}}
{{- define "simple-resource-wrapper.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Note! Standard Helm thing was altered to make wrapping as transparent as possible.
*/}}
{{- define "simple-resource-wrapper.fullname" -}}
{{- if .Values.metadata.name }}
{{- .Values.metadata.name | trunc 63 | trimSuffix "-" }}
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
{{- define "simple-resource-wrapper.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "simple-resource-wrapper.labels" -}}
helm.sh/chart: {{ include "simple-resource-wrapper.chart" . }}
{{ include "simple-resource-wrapper.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "simple-resource-wrapper.selectorLabels" -}}
app.kubernetes.io/name: {{ include "simple-resource-wrapper.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

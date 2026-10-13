{{/*
Expand the name of the chart.
*/}}
{{- define "maestrod.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "maestrod.fullname" -}}
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
Chart label.
*/}}
{{- define "maestrod.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "maestrod.labels" -}}
helm.sh/chart: {{ include "maestrod.chart" . }}
{{ include "maestrod.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels. Kept byte-identical to the internal 0.3.x chart so upgrades
in place do not hit immutable-selector errors.
*/}}
{{- define "maestrod.selectorLabels" -}}
app.kubernetes.io/name: {{ include "maestrod.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ServiceAccount name. Returns the chart's fullname when serviceAccount.create is
true and no name override is given; otherwise the `serviceAccount.name` or
`default`.
*/}}
{{- define "maestrod.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "maestrod.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Ingress host. Prefers an explicit ingress.host; otherwise composes the host
from subdomainHostName and subdomainRootName; otherwise falls back to
subdomainHostName alone.
*/}}
{{- define "maestrod.ingressHost" -}}
{{- if .Values.ingress.host -}}
{{- .Values.ingress.host -}}
{{- else if and .Values.subdomainHostName .Values.subdomainRootName -}}
{{- printf "%s.%s" .Values.subdomainHostName .Values.subdomainRootName -}}
{{- else -}}
{{- .Values.subdomainHostName -}}
{{- end -}}
{{- end }}

{{/*
Ingress TLS secret name. Defaults to <fullname>-ingress when no override given.
*/}}
{{- define "maestrod.ingressTlsSecretName" -}}
{{- if .Values.ingress.tls.secretName -}}
{{- .Values.ingress.tls.secretName -}}
{{- else -}}
{{- printf "%s-ingress" (include "maestrod.fullname" .) -}}
{{- end -}}
{{- end }}

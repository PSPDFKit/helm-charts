{{/*
Pod template shared between Deployment and StatefulSet.
*/}}
{{- define "document-engine.podTemplate" -}}
metadata:
  annotations:
    checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
    checksum/secret: {{ include (print $.Template.BasePath "/secret.yaml") . | sha256sum }}
  {{- with .Values.podAnnotations }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "document-engine.labels" . | nindent 4 }}
    {{- with .Values.podLabels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- with .Values.deploymentExtraSelectorLabels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  {{- with .Values.imagePullSecrets }}
  imagePullSecrets:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  serviceAccountName: {{ include "document-engine.serviceAccountName" . }}
  securityContext:
    {{- toYaml .Values.podSecurityContext | nindent 4 }}
  {{- if .Values.initContainers }}
  initContainers:
    {{ toYaml .Values.initContainers | nindent 4 }}
  {{- end }}
  containers:
    - name: {{ .Chart.Name }}
      envFrom:
        - configMapRef:
            name: {{ include "document-engine.fullname" . }}
        - secretRef:
            name: {{ include "document-engine.fullname" . }}
      {{- if and .Values.database.enabled
                 .Values.database.postgres.externalSecretName }}
        - secretRef:
            name: {{ .Values.database.postgres.externalSecretName }}
      {{- end }}
      {{- if and .Values.database.enabled
                 .Values.database.migrationJob.enabled
                 .Values.database.postgres.externalAdminSecretName  }}
        - secretRef:
            name: {{ .Values.database.postgres.externalAdminSecretName }}
      {{- end }}
      {{- with .Values.assetStorage }}
        {{- if and (eq (include "document-engine.storage.s3.enabled" $) "true")
                   .s3.externalSecretName }}
        - secretRef:
            name: {{ .s3.externalSecretName }}
        {{- end }}
        {{- if and (eq (include "document-engine.storage.azure.enabled" $) "true")
                   .azure.externalSecretName }}
        - secretRef:
            name: {{ .azure.externalSecretName }}
        {{- end }}
        {{- if and .redis.enabled
                   .redis.externalSecretName }}
        - secretRef:
            name: {{ .redis.externalSecretName  }}
        {{- end }}
      {{- end }}
      {{- with .Values.extraEnvFrom }}
        {{- toYaml . | nindent 8 }}
      {{- end }}
      env:
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
      {{- if .Values.documentEngineLicense.externalSecret.name }}
        - name: ACTIVATION_KEY
          valueFrom:
            secretKeyRef:
              name: {{ .Values.documentEngineLicense.externalSecret.name }}
              key: {{ .Values.documentEngineLicense.externalSecret.key }}
      {{- end }}
      {{- if .Values.apiAuth.externalSecret.name }}
        {{- with .Values.apiAuth }}
          {{- if .externalSecret.apiTokenKey }}
        - name: API_AUTH_TOKEN
          valueFrom:
            secretKeyRef:
              name: {{ .externalSecret.name }}
              key: {{ .externalSecret.apiTokenKey }}
          {{- end }}
          {{- if .externalSecret.secretKeyBaseKey }}
        - name: SECRET_KEY_BASE
          valueFrom:
            secretKeyRef:
              name: {{ .externalSecret.name }}
              key: {{ .externalSecret.secretKeyBaseKey }}
          {{- end }}
          {{- if and .jwt.enabled .externalSecret.jwtPublicKeyKey }}
        - name: JWT_PUBLIC_KEY
          valueFrom:
            secretKeyRef:
              name: {{ .externalSecret.name }}
              key: {{ .externalSecret.jwtPublicKeyKey }}
          {{- end }}
          {{- if and .jwt.enabled .externalSecret.jwtAlgorithmKey }}
        - name: JWT_ALGORITHM
          valueFrom:
            secretKeyRef:
              name: {{ .externalSecret.name }}
              key: {{ .externalSecret.jwtAlgorithmKey }}
          {{- end }}
        {{- end }}
      {{- end }}
      {{- if and .Values.dashboard.enabled
                 .Values.dashboard.auth.externalSecret.name}}
        - name: DASHBOARD_USERNAME
          valueFrom:
            secretKeyRef:
              name: {{ .Values.dashboard.auth.externalSecret.name }}
              key: {{ .Values.dashboard.auth.externalSecret.usernameKey }}
        - name: DASHBOARD_PASSWORD
          valueFrom:
            secretKeyRef:
              name: {{ .Values.dashboard.auth.externalSecret.name }}
              key: {{ .Values.dashboard.auth.externalSecret.passwordKey }}
      {{- end }}
      {{- with .Values.extraEnvs }}
        {{- toYaml . | nindent 8 }}
      {{- end }}
      securityContext:
        {{- toYaml .Values.securityContext | nindent 8 }}
      image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
      imagePullPolicy: {{ .Values.image.pullPolicy }}
      ports:
        - name: api
          containerPort: {{ .Values.config.port }}
          protocol: TCP
        {{- if .Values.observability.metrics.prometheusEndpoint.enabled }}
        - name: metrics
          containerPort: {{ .Values.observability.metrics.prometheusEndpoint.port }}
          protocol: TCP
        {{- end }}
      {{- if .Values.startupProbe }}
      startupProbe: {{ toYaml .Values.startupProbe | nindent 8 }}
      {{- end }}
      {{- if .Values.livenessProbe }}
      livenessProbe: {{ toYaml .Values.livenessProbe | nindent 8 }}
      {{- end }}
      {{- if .Values.readinessProbe }}
      readinessProbe: {{ toYaml .Values.readinessProbe | nindent 8 }}
      {{- end }}
      resources:
        {{- toYaml .Values.resources | nindent 8 }}
      {{- if or .Values.extraVolumeMounts
                .Values.certificateTrust.digitalSignatures
                .Values.certificateTrust.customCertificates
                (include "document-engine.isStatefulSet" .) }}
      volumeMounts:
        {{- if (include "document-engine.isStatefulSet" .) }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
        {{- end }}
        {{- with .Values.extraVolumeMounts }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- with .Values.certificateTrust.digitalSignatures }}
        {{-   range $trustSource := . }}
        - name: signing-trust-{{ $trustSource.name }}
          mountPath: /certificate-stores/{{ $trustSource.path }}
          subPath: {{ $trustSource.path }}
          readOnly: true
        {{-   end }}
        {{- end }}
        {{- include "document-engine.certificateTrust.customCertificates.volumeMounts" . | nindent 8 }}
      {{- end }}
      {{- with .Values.lifecycle }}
      lifecycle:
        {{- toYaml . | nindent 8 }}
      {{- end }}
  {{- if (eq (include "document-engine.envoySidecar.enabled" . ) "true" ) }}
    - name: envoy-sidecar
      image: "{{ .Values.envoySidecar.image.repository }}:{{ .Values.envoySidecar.image.tag }}"
      imagePullPolicy: {{ .Values.envoySidecar.image.pullPolicy }}
      ports:
        - name: envoy
          containerPort: {{ .Values.envoySidecar.port }}
          protocol: TCP
        - name: envoy-admin
          containerPort: {{ .Values.envoySidecar.adminPort }}
          protocol: TCP
      resources:
        {{- toYaml .Values.envoySidecar.resources | nindent 8 }}
      volumeMounts:
        - name: envoy-config
          mountPath: /etc/envoy
          readOnly: true
      command:
        - envoy
        - -c
        - /etc/envoy/envoy.yaml
  {{- end }}
  {{- if .Values.sidecars }}
    {{ toYaml .Values.sidecars | nindent 4 }}
  {{- end }}
  {{- if or .Values.extraVolumeMounts
            .Values.certificateTrust.digitalSignatures
            .Values.certificateTrust.customCertificates
            .Values.envoySidecar.enabled }}
  volumes:
    {{- if (eq (include "document-engine.envoySidecar.enabled" . ) "true" ) }}
    - name: envoy-config
      configMap:
        name: {{ include "document-engine.fullname" . }}-envoy-sidecar
    {{- end }}
    {{- with .Values.extraVolumes }}
    {{ toYaml . | nindent 4 }}
    {{- end }}
    {{- with .Values.certificateTrust.digitalSignatures }}
    {{-   range $trustSource := . }}
    - name: signing-trust-{{ $trustSource.name }}
    {{-     if $trustSource.configMap }}
      configMap:
        name: {{ $trustSource.configMap.name }}
        items:
          - key: {{ $trustSource.configMap.key }}
            path: {{ $trustSource.path }}
    {{-     else if $trustSource.secret }}
      secret:
        secretName: {{ $trustSource.secret.name }}
        items:
          - key: {{ $trustSource.secret.key }}
            path: {{ $trustSource.path }}
    {{-     else }}
    {{-       fail "Expecting ConfigMap or Secret for a certificate trust" }}
    {{-     end }}
    {{-   end }}
    {{- end }}
    {{- include "document-engine.certificateTrust.customCertificates.volumes" . | nindent 4 }}
  {{- end }}
  {{- with (include "document-engine.scheduling" .) }}
{{ . | nindent 2 }}
  {{- end }}
  {{- if .Values.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.terminationGracePeriodSeconds }}
  {{- end }}
{{- end -}}

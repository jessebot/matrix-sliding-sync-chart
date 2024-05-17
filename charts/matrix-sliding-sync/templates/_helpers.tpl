{{/*
Expand the name of the chart.
*/}}
{{- define "matrix-sliding-sync.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "matrix-sliding-sync.fullname" -}}
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
{{- define "matrix-sliding-sync.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "matrix-sliding-sync.labels" -}}
helm.sh/chart: {{ include "matrix-sliding-sync.chart" . }}
{{ include "matrix-sliding-sync.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "matrix-sliding-sync.selectorLabels" -}}
app.kubernetes.io/name: {{ include "matrix-sliding-sync.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "matrix-sliding-sync.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "matrix-sliding-sync.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Helper function to get postgres instance name
*/}}
{{- define "postgresql.name" -}}
{{- if .Values.postgresql.enabled -}}
{{ include "matrix-sliding-sync.fullname" . }}-postgresql
{{- end }}
{{- end }}

{{/*
Helper function to get the postgres secret containing the database credentials
*/}}
{{- define "matrix-sliding-sync.postgresql.secretName" -}}
{{- if and .Values.postgresql.enabled .Values.postgresql.global.postgresql.auth.existingSecret -}}
{{ .Values.postgresql.global.postgresql.auth.existingSecret }}
{{- else if and .Values.externalDatabase.enabled .Values.externalDatabase.existingSecret -}}
{{ .Values.externalDatabase.existingSecret }}
{{- else -}}
{{ template "matrix-sliding-sync.fullname" . }}-db-secret
{{- end }}
{{- end }}

{{/*
templates out SYNCV3_DB which is a postgres connection string: https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING
*/}}
{{- define "matrix-sliding-sync.dbConnString" -}}
{{- if and .Values.postgresql.enabled (not .Values.syncv3.existingSecret) }}
{{- if .Values.syncv3.db.password }}
{{- printf "user=%s dbname=%s sslmode=%s host=%s password=%s" .Values.syncv3.db.user .Values.syncv3.db.dbname .Values.syncv3.db.sslmode .Values.syncv3.db.host .Values.syncv3.db.password }}
{{- else -}}
{{- printf "user=%s dbname=%s sslmode=%s host=%s" .Values.syncv3.db.user .Values.syncv3.db.dbname .Values.syncv3.db.sslmode .Values.syncv3.db.host }}
{{- end }}
{{- end }}
{{- end }}

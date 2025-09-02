{{/*
Expand the name of the chart.
*/}}
{{- define "dwmkerr-starter-kit.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dwmkerr-starter-kit.fullname" -}}
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
{{- define "dwmkerr-starter-kit.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dwmkerr-starter-kit.labels" -}}
helm.sh/chart: {{ include "dwmkerr-starter-kit.chart" . }}
{{ include "dwmkerr-starter-kit.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
ark.mckinsey.com/service: dwmkerr-starter-kit
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dwmkerr-starter-kit.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dwmkerr-starter-kit.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
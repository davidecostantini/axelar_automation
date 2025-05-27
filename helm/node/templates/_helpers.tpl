{{/* Generate name */}}
{{- define "my-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/* Generate fullname */}}
{{- define "my-app.fullname" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/* Generate chain_id */}}
{{- define "my-app.chain_id" -}}
{{- if eq .Values.network "mainnet" -}}
axelar-dojo-1
{{- else -}}
axelar-testnet-lisbon-3
{{- end -}}
{{- end }}

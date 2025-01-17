{{- define "labels" }} 
  name: {{ $.Release.Name }}
{{- end }}

{{- define "labels.metadata" }} 
  {{- include "labels" . }} 
  namespace: {{ .Values.app.namespace }}
{{- end }}
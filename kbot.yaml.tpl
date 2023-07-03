apiVersion: v1
kind: Secret
metadata:
  name: kbot
  namespace: demo
type: Opaque
data:
${join("\n", [
  for k, v in secret_data :
  "  ${k}: ${v}"
])}

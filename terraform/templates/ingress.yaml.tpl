apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    ingress.kubernetes.io/ssl-redirect: "true"
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
  name: spinnaker
  namespace: spinnaker
spec:
  rules:
  - host: ${spinnaker_deck_domain}
    http:
      paths:
      - backend:
          serviceName: spin-deck
          servicePort: 9000
        path: /
  - host: ${spinnaker_gate_domain}
    http:
      paths:
      - backend:
          serviceName: spin-gate
          servicePort: 8084
        path: /
  tls:
  - hosts:
    - ${spinnaker_deck_domain}
    secretName: spinnaker-tls
  - hosts:
    - ${spinnaker_gate_domain}
    secretName: spinnaker-gate-tls
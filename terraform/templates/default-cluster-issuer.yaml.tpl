apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: letsencrypt-production
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: "${gcp_account}"
    privateKeySecretRef:
      name: letsencrypt-private-key
    http01: {}
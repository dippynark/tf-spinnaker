data "google_client_config" "default" {}

resource "null_resource" "install" {

  triggers {
    content = "${local_file.manifests.content}"
  }

  provisioner "local-exec" {

    command = <<EOF
export KUBECONFIG='${local_file.kubeconfig.filename}'
kubectl config set-credentials admin --kubeconfig '${local_file.kubeconfig.filename}' --token '${data.google_client_config.default.access_token}'

kubectl apply --kubeconfig '${local_file.kubeconfig.filename}' -f '${local_file.manifests.filename}'

helm fetch \
  --repo https://kubernetes-charts.storage.googleapis.com \
  --untar \
  --untardir '${path.module}/charts' \
  nginx-ingress
kubectl create --kubeconfig '${local_file.kubeconfig.filename}' namespace nginx-ingress
helm template '${path.module}/charts/nginx-ingress' \
  --namespace nginx-ingress \
  --name nginx-ingress | kubectl apply -n nginx-ingress -f -

helm fetch \
  --repo https://kubernetes-charts.storage.googleapis.com \
  --untar \
  --untardir '${path.module}/charts' \
  cert-manager
kubectl create --kubeconfig '${local_file.kubeconfig.filename}' namespace cert-manager
helm template '${path.module}/charts/cert-manager' \
  --namespace cert-manager \
  --name cert-manager \
  --set ingressShim.defaultIssuerName=letsencrypt-production \
  --set ingressShim.defaultIssuerKind=ClusterIssuer | kubectl apply -n cert-manager -f -

kubectl apply --kubeconfig '${local_file.kubeconfig.filename}' -f '${local_file.default-cluster-issuer.filename}'
EOF

  }

}
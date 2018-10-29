data "google_client_config" "default" {}

resource "null_resource" "install" {

  triggers {
    manifests = "${local_file.manifests.content}"
    goldengoose = "${local_file.goldengoose.content}"
    values = "${local_file.values.content}"
  }

  provisioner "local-exec" {

    command = <<EOF
export KUBECONFIG='${local_file.kubeconfig.filename}'
kubectl config set-credentials admin --kubeconfig '${local_file.kubeconfig.filename}' --token '${data.google_client_config.default.access_token}'

kubectl apply --kubeconfig '${local_file.kubeconfig.filename}' -f '${local_file.manifests.filename}'

kubectl apply --kubeconfig '${local_file.kubeconfig.filename}' -f '${local_file.goldengoose.filename}'

kubectl apply --filename https://raw.githubusercontent.com/knative/serving/v0.1.1/third_party/config/build/release.yaml

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

helm init \
  --service-account tiller \
  --wait \
  --override 'spec.template.spec.containers[0].args={/tiller,--listen=localhost:44134}'
helm upgrade \
  --install \
  --namespace spinnaker \
  --values '${local_file.values.filename}' \
  --timeout 600 \
  spinnaker \
  stable/spinnaker

EOF

  }

}
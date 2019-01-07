data "google_client_config" "default" {}

resource "null_resource" "install" {

  triggers {
    manifests = "${local_file.manifests.content}"
    goldengoose = "${local_file.goldengoose.content}"
    spinnaker-values = "${local_file.spinnaker-values.content}"
    prometheus-values = "${data.local_file.prometheus-values.content}"
  }

  provisioner "local-exec" {

    command = <<EOF
export KUBECONFIG='${local_file.kubeconfig.filename}'
kubectl config set-credentials admin --kubeconfig '${local_file.kubeconfig.filename}' --token '${data.google_client_config.default.access_token}'

kubectl apply --kubeconfig '${local_file.kubeconfig.filename}' -f '${local_file.manifests.filename}'
kubectl apply --kubeconfig '${local_file.kubeconfig.filename}' -f '${local_file.goldengoose.filename}'
kubectl apply --filename https://raw.githubusercontent.com/knative/serving/v0.2.2/third_party/config/build/release.yaml

helm init \
  --service-account tiller \
  --wait \
  --override 'spec.template.spec.containers[0].args={/tiller,--listen=localhost:44134}'

helm upgrade \
  --install \
  --namespace cert-manager \
  --set ingressShim.defaultIssuerName=letsencrypt-production \
  --set ingressShim.defaultIssuerKind=ClusterIssuer \
  cert-manager \
  stable/cert-manager

kubectl apply --kubeconfig '${local_file.kubeconfig.filename}' -f '${local_file.default-cluster-issuer.filename}'

helm upgrade \
  --install \
  --namespace nginx-ingress \
  nginx-ingress \
  stable/nginx-ingress

helm upgrade \
  --install \
  --namespace prometheus \
  --values '${data.local_file.prometheus-values.filename}' \
  prometheus \
  stable/prometheus

helm upgrade \
  --install \
  --namespace spinnaker \
  --values '${local_file.spinnaker-values.filename}' \
  --timeout 600 \
  spinnaker \
  stable/spinnaker
EOF

  }

}
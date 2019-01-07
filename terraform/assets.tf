# default-cluster-issuer.yaml
data "template_file" "default-cluster-issuer" {
  template = "${file("${path.module}/templates/default-cluster-issuer.yaml.tpl")}"

  vars {
    gcp_account = "${var.gcp_account}"
  }
}

resource "local_file" "default-cluster-issuer" {
  content  = "${data.template_file.default-cluster-issuer.rendered}"
  filename = "${path.module}/default-cluster-issuer.yaml"
}

# kubeconfig
data "template_file" "kubeconfig" {
  template = "${file("${path.module}/templates/kubeconfig.tpl")}"

  vars {
    server = "https://${google_container_cluster.spinnaker.endpoint}"
    certificate_authority = "${google_container_cluster.spinnaker.master_auth.0.cluster_ca_certificate}"
  }
}

resource "local_file" "kubeconfig" {
  content  = "${data.template_file.kubeconfig.rendered}"
  filename = "${path.module}/kubeconfig"
}

# spinnaker-values.yaml
data "template_file" "spinnaker-values" {
  template = "${file("${path.module}/templates/spinnaker-values.yaml.tpl")}"

  vars {
    gcp_project = "${var.project}"
    gcs_service_account_json = "${base64decode(google_service_account_key.spinnaker.private_key)}"
    gcs_service_account_json_path = "/opt/gcs/key.json"
    gcs_storage_bucket_name = "${google_storage_bucket.spinnaker.name}"
    spinnaker_version = "${var.spinnaker_version}"
    spinnaker_oauth_client_id = "${var.spinnaker_oauth_client_id}"
    spinnaker_oauth_client_secret = "${var.spinnaker_oauth_client_secret}"
    spinnaker_oauth_provider = "${var.spinnaker_oauth_provider}"
    spinnaker_deck_domain = "${var.spinnaker_deck_domain}"
    spinnaker_gate_domain = "${var.spinnaker_gate_domain}"
  }
}

resource "local_file" "spinnaker-values" {
  content  = "${data.template_file.spinnaker-values.rendered}"
  filename = "${path.module}/spinnaker-values.yaml"
}

# prometheus-values.yaml
data "local_file" "prometheus-values" {
    filename = "${path.module}/prometheus-values.yaml"
}

# manifests.yaml
data "template_file" "manifests" {
  template = "${file("${path.module}/templates/manifests.yaml.tpl")}"

  vars {
    gcp_account = "${var.gcp_account}"
  }
}

resource "local_file" "manifests" {
  content  = "${data.template_file.manifests.rendered}"
  filename = "${path.module}/manifests.yaml"
}

# ingress.yaml
data "template_file" "ingress" {
  template = "${file("${path.module}/templates/ingress.yaml.tpl")}"

  vars {
    spinnaker_deck_domain = "${var.spinnaker_deck_domain}"
    spinnaker_gate_domain = "${var.spinnaker_gate_domain}"
  }
}

resource "local_file" "ingress" {
  content  = "${data.template_file.ingress.rendered}"
  filename = "${path.module}/ingress.yaml"
}

# goldengoose.yaml
data "template_file" "goldengoose" {
  template = "${file("${path.module}/templates/goldengoose.yaml.tpl")}"

  vars {
    docker_dippynark_password = "${base64encode(var.docker_dippynark_password)}"
  }
}

resource "local_file" "goldengoose" {
  content  = "${data.template_file.goldengoose.rendered}"
  filename = "${path.module}/goldengoose.yaml"
}

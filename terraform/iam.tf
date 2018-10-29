# https://github.com/spinnaker/spinnaker.github.io/issues/443#issuecomment-408913130-permalink
resource "random_id" "spinnaker-entropy" {
  byte_length = 6
}

resource "google_service_account" "spinnaker" {
  account_id   = "spinnaker-gcs-${random_id.spinnaker-entropy.hex}"
  display_name = "Spinnaker GCS Account"
}

resource "google_project_iam_binding" "spinnaker" {
  role    = "roles/storage.admin"

  members = [
    "serviceAccount:${google_service_account.spinnaker.email}",
  ]
}

resource "google_service_account_key" "spinnaker" {
  service_account_id = "${google_service_account.spinnaker.name}"
  public_key_type = "TYPE_X509_PEM_FILE"
}

resource "random_id" "cluster-entropy" {
  byte_length = 6
}

resource "google_service_account" "default" {
  account_id   = "cluster-minimal-${random_id.cluster-entropy.hex}"
  display_name = "Minimal account for GKE cluster ${var.cluster_name}"
  project = "${var.project}"
}

resource "google_project_iam_member" "logging-log-writer" {
  role    = "roles/logging.logWriter"
  project = "${var.project}"
  member = "serviceAccount:${google_service_account.default.email}"
}

resource "google_project_iam_member" "monitoring-metric-writer" {
  role    = "roles/monitoring.metricWriter"
  project = "${var.project}"
  member = "serviceAccount:${google_service_account.default.email}"
}

resource "google_project_iam_member" "monitoring-viewer" {
  role    = "roles/monitoring.viewer"
  project = "${var.project}"
  member = "serviceAccount:${google_service_account.default.email}"
}

resource "google_project_iam_member" "storage-object-viewer" {
  role    = "roles/storage.objectViewer"
  project = "${var.project}"
  member = "serviceAccount:${google_service_account.default.email}"
}
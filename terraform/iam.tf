resource "google_service_account" "spinnaker" {
  account_id   = "spinnaker-gcs-account"
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
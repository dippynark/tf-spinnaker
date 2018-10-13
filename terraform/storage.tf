resource "google_storage_bucket" "spinnaker" {
  name     = "${var.storage_bucket_name}"
  location = "${var.region}"
  storage_class = "REGIONAL"
  force_destroy = true
}
resource "google_compute_network" "spinnaker" {
  name                    = "spinnaker"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "spinnaker" {
  name          = "spinnaker"
  ip_cidr_range = "${var.subnetwork_cidr_range}"
  network       = "${google_compute_network.spinnaker.self_link}"
  #private_ip_google_access = true

  secondary_ip_range {
    range_name    = "spinnaker-pods"
    ip_cidr_range = "${var.cluster_pod_cidr_range}"
  }

  secondary_ip_range {
    range_name    = "spinnaker-services"
    ip_cidr_range = "${var.cluster_service_cidr_range}"
  }

}
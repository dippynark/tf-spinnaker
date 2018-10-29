resource "google_container_cluster" "spinnaker" {
  name               = "${var.cluster_name}"
  additional_zones = "${var.cluster_additional_zones}"
  provider = "google-beta"

  ip_allocation_policy {
    cluster_secondary_range_name = "spinnaker-pods"
    services_secondary_range_name = "spinnaker-services"
  }

  master_auth {
    username = ""
    password = ""
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "${var.cluster_master_authorized_cidr}"
    }
  }

  min_master_version = "${var.cluster_min_master_version}"
  network = "${google_compute_network.spinnaker.self_link}"
  subnetwork = "${google_compute_subnetwork.spinnaker.self_link}"

  network_policy {
    enabled = true
    provider = "CALICO"
  }

  pod_security_policy_config {
    enabled = true
  }

  /*
  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes = true
    master_ipv4_cidr_block = "${var.cluster_master_ipv4_cidr_block}"
  }
  */

  addons_config {
    network_policy_config {
      disabled = false
    }
  }

  node_pool {
    name = "default-pool"
    initial_node_count = "${var.cluster_autoscaling_min_node_count}"

    autoscaling {
      min_node_count = "${var.cluster_autoscaling_min_node_count}"
      max_node_count = "${var.cluster_autoscaling_max_node_count}"
    }

    management {
      auto_repair = true
      auto_upgrade = false
    }

    node_config {
      machine_type = "${var.cluster_machine_type}"

      # https://cloud.google.com/compute/docs/access/service-accounts#usingroles
      # https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster#reduce_node_sa_scopes
      # https://developers.google.com/identity/protocols/googlescopes
      oauth_scopes = [
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
      ]

      service_account = "${google_service_account.default.email}"

      metadata {
        disable-legacy-endpoints = true
      }

      workload_metadata_config {
        node_metadata = "SECURE"
      }
    }
  }
}
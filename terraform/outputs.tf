output "cluster_master_version" {
  value = "${google_container_cluster.spinnaker.master_version}"
}

output "cluster_public_endpoint" {
  value = "${google_container_cluster.spinnaker.endpoint}"
}
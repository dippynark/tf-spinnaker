# provider
variable "project" {}
variable "region" {}
variable "zone" {}

# vpc
variable "subnetwork_cidr_range" {}

# kubernetes
variable "cluster_name" {}
variable "cluster_min_master_version" {}
variable "cluster_additional_zones" {
  type    = "list"
}
variable "cluster_pod_cidr_range" {}
variable "cluster_service_cidr_range" {}
variable "cluster_master_ipv4_cidr_block" {}
variable "cluster_autoscaling_min_node_count" {}
variable "cluster_autoscaling_max_node_count" {}
variable "cluster_machine_type" {}
variable "cluster_master_authorized_cidr" {}
variable "gcp_account" {}

# spinnaker
variable "storage_bucket_name" {}
variable "spinnaker_version" {}
variable "spinnaker_oauth_client_id" {}
variable "spinnaker_oauth_client_secret" {}
variable "spinnaker_oauth_provider" {}
variable "spinnaker_deck_domain" {}
variable "spinnaker_gate_domain" {}

# goldengoose
variable "docker_dippynark_password" {}

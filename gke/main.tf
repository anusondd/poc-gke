provider "google" {
  project = var.project_id
  region  = var.region
}

terraform {
  backend "gcs" {
    bucket = "poc-gke-448016-terraform-state"
    prefix = "poc-gke/gke"
  }
}

data "google_compute_zones" "this" {
  region  = var.region
  project = var.project_id
}

# data "terraform_remote_state" "vpc" {
#   backend = "gcs"
#   config = {
#     bucket = "poc-gke-448016-terraform-state"
#     prefix = "poc-gke/vpc"
#   }
# }

# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke-cluster"
  location = var.region
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.vpc_name
  subnetwork = var.subnet_public_name
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name           = "${var.project_id}-node-pool"
  location       = var.region
  cluster        = google_container_cluster.primary.name
  node_count     = var.gke_num_nodes
  node_locations = ["asia-southeast1-a", "asia-southeast1-b", "asia-southeast1-c"]

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
    disk_size_gb = 20
    disk_type    = "pd-ssd"
  }

}
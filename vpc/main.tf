provider "google" {
  project = var.project_id
  region  = var.region
}

terraform {
  backend "gcs" {
    bucket = "poc-gke-448016-terraform-state"
    prefix = "poc-gke/vpc"
  }
}

data "google_compute_zones" "this" {
  region  = var.region
  project = var.project_id
}

locals {
  type  = ["public", "private"]
  zones = data.google_compute_zones.this.names
}

# VPC
resource "google_compute_network" "this" {
  name                            = "${var.name}-vpc"
  delete_default_routes_on_create = false
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
}

# SUBNETS
resource "google_compute_subnetwork" "this" {
  count                    = 2
  name                     = "${var.name}-${local.type[count.index]}-subnetwork"
  ip_cidr_range            = var.ip_cidr_range[count.index]
  region                   = var.region
  network                  = google_compute_network.this.id
  private_ip_google_access = true
}
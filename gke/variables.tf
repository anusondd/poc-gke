variable "project_id" {
  type        = string
  description = "Project ID"
  default     = "poc-gke-448016"
}

variable "region" {
  type        = string
  description = "Region for this infrastructure"
  default     = "asia-southeast1"
}

variable "name" {
  type        = string
  description = "Name for this infrastructure"
  default     = "poc-gke"
}

variable "vpc_name" {
  type        = string
  description = "VPC Name"
  default     = "poc-gke-vpc"
}

variable "subnet_public_name" {
  type        = string
  description = "subnetwork Public Name"
  default     = "poc-gke-public-subnetwork"
}

variable "subnet_private_name" {
  type        = string
  description = "subnetwork Private Name"
  default     = "poc-gke-private-subnetwork"
}

variable "gke_num_nodes" {
  default     = 2
  description = "number of gke nodes"
}
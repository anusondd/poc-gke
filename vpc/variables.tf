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

variable "ip_cidr_range" {
  type        = list(string)
  description = "List of The range of internal addresses that are owned by this subnetwork."
  default     = ["10.10.10.0/24", "10.10.20.0/24"]
}
variable "GOOGLE_PROJECT" {
  type        = string
  default     = "devopsgo-385622"
  description = "GCP project name"
}

variable "GOOGLE_REGION" {
  type        = string
  default     = "europe-west1-c"
  description = "region name"
}

variable "GKE_MACHINE_TYPE" {
  type        = string
  default     = "n1-standard-1"
  description = "Machine type"
}

variable "GKE_NUM_NODES" {
  type        = number
  default     = 1
  description = "GKE nodes number"
}

# ==============================================================================
# variables.tf
# ------------------------------------------------------------------------------
# Purpose:
#   - Define network-related variables for Managed AD deployment.
#   - Parameterize VPC and subnet names.
#
# Notes:
#   - Defaults are suitable for dev/test environments.
#   - Override via tfvars for prod or multi-env deployments.
# ==============================================================================

# ------------------------------------------------------------------------------
# VPC Name
# ------------------------------------------------------------------------------
# Name of the VPC where the Managed AD instance will reside.
variable "vpc" {
  description = "Network for AD instance (e.g., ad-vpc)"
  type        = string
  default     = "managed-ad-vpc"
}

# ------------------------------------------------------------------------------
# Subnet Name
# ------------------------------------------------------------------------------
# Name of the subnet within the VPC for AD placement.
variable "subnet" {
  description = "Sub-network for AD instance (e.g., ad-subnet)"
  type        = string
  default     = "managed-ad-subnet"
}
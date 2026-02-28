# ==============================================================================
# VPC Name for Managed AD Instance
# ------------------------------------------------------------------------------
# Name of the VPC network where the AD instance will reside.
# ==============================================================================
variable "vpc" {
  description = "Network for AD instance (e.g., ad-vpc)"
  type        = string
  default     = "managed-ad-vpc"
}

# ==============================================================================
# Subnet Name for Managed AD Instance
# ------------------------------------------------------------------------------
# Name of the subnet within the VPC used for AD placement.
# ==============================================================================
variable "subnet" {
  description = "Sub-network for AD instance (e.g., ad-subnet)"
  type        = string
  default     = "managed-ad-subnet"
}
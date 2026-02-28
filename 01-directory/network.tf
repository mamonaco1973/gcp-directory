# ==============================================================================
# network.tf
# ------------------------------------------------------------------------------
# Purpose:
#   - Create a custom mode VPC.
#   - Define a dedicated subnet for AD and related resources.
#
# Notes:
#   - Custom mode requires explicit subnet definitions.
#   - No automatic regional subnets are created.
#   - Subnet CIDR must not overlap other VPC subnets.
# ==============================================================================

# ------------------------------------------------------------------------------
# VPC Network
# ------------------------------------------------------------------------------
# Create a custom mode VPC network.
# auto_create_subnetworks = false disables default regional subnets.
resource "google_compute_network" "ad_vpc" {

  # Unique VPC name within the project.
  name = var.vpc

  # Disable automatic subnet creation (custom mode).
  auto_create_subnetworks = false
}

# ------------------------------------------------------------------------------
# Subnetwork
# ------------------------------------------------------------------------------
# Create a regional subnet within the custom VPC.
resource "google_compute_subnetwork" "ad_subnet" {

  # Unique subnet name within the VPC.
  name = var.subnet

  # Region where the subnet and its resources will reside.
  region = "us-central1"

  # Attach subnet to the previously created VPC.
  network = google_compute_network.ad_vpc.id

  # IPv4 CIDR block for this subnet.
  # Must not overlap with other subnets in the VPC.
  ip_cidr_range = "10.1.0.0/24"
}
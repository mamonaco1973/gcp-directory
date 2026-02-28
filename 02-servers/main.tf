# ==============================================================================
# main.tf
# ------------------------------------------------------------------------------
# Purpose:
#   - Configure the Google Cloud provider.
#   - Load credentials from JSON file.
#   - Lookup existing VPC and subnet resources.
#
# Notes:
#   - Credentials file must exist at ../credentials.json.
#   - jsondecode() converts JSON into a usable map.
#   - Data sources reference pre-existing network resources.
# ==============================================================================

# ------------------------------------------------------------------------------
# Provider Configuration
# ------------------------------------------------------------------------------
# Configure Google provider using project ID and credentials file.
provider "google" {
  project     = local.credentials.project_id
  credentials = file("../credentials.json")
}

# ------------------------------------------------------------------------------
# Local Variables
# ------------------------------------------------------------------------------
# Decode credentials file and extract reusable values.
locals {
  credentials           = jsondecode(file("../credentials.json"))
  service_account_email = local.credentials.client_email
}

# ------------------------------------------------------------------------------
# Existing VPC Lookup
# ------------------------------------------------------------------------------
# Retrieve existing VPC by name.
data "google_compute_network" "ad_vpc" {
  name = var.vpc
}

# ------------------------------------------------------------------------------
# Existing Subnet Lookup
# ------------------------------------------------------------------------------
# Retrieve existing subnet by name and region.
data "google_compute_subnetwork" "ad_subnet" {
  name   = var.subnet
  region = "us-central1"
}
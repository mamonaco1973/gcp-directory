# ==============================================================================
# directory.tf
# ------------------------------------------------------------------------------
# Purpose:
#   - Provision a Google Managed Active Directory domain.
#   - Attach the domain to an existing VPC network.
#   - Reserve a dedicated subnet range for domain controllers.
#
# Notes:
#   - Managed AD requires a dedicated /24 CIDR block.
#   - The reserved range must not overlap other VPC subnets.
#   - deletion_protection should be true for production use.
# ==============================================================================

resource "google_active_directory_domain" "mikecloud_ad" {

  # ----------------------------------------------------------------------------
  # Domain Name
  # ----------------------------------------------------------------------------
  # Fully qualified domain name (FQDN) for the AD forest root.
  # Must follow standard AD naming conventions.
  domain_name = "mcloud.mikecloud.com"

  # ----------------------------------------------------------------------------
  # Deployment Regions
  # ----------------------------------------------------------------------------
  # Regions where Managed AD domain controllers will be deployed.
  # At least one region is required.
  locations = ["us-central1"]

  # ----------------------------------------------------------------------------
  # Reserved IP Range
  # ----------------------------------------------------------------------------
  # Dedicated /24 CIDR block reserved exclusively for Managed AD.
  # Must not overlap with existing VPC subnet ranges.
  reserved_ip_range = "192.168.255.0/24"

  # ----------------------------------------------------------------------------
  # Authorized Networks
  # ----------------------------------------------------------------------------
  # VPC network where Managed AD domain controllers will reside.
  # References an existing google_compute_network resource.
  authorized_networks = [google_compute_network.ad_vpc.id]

  # ----------------------------------------------------------------------------
  # Deletion Protection
  # ----------------------------------------------------------------------------
  # Prevents accidental deletion when set to true.
  # Should typically be true in production environments.
  deletion_protection = false
  
  timeouts {
    create = "3h"
    update = "3h"
    delete = "3h"
  }

}

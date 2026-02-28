# ==============================================================================
# windows.tf
# ------------------------------------------------------------------------------
# Purpose:
#   - Deploy Windows Server 2022 VM for AD administration.
#   - Allow RDP access via firewall rule.
#   - Join VM to Managed AD using startup script.
#
# Notes:
#   - RDP is open to 0.0.0.0/0 (restrict in production).
#   - VM uses latest Windows 2022 image family.
#   - Random suffix avoids name collisions.
# ==============================================================================

# ------------------------------------------------------------------------------
# Firewall Rule: Allow RDP
# ------------------------------------------------------------------------------
# Allow inbound TCP/3389 from any source to tagged instances.
resource "google_compute_firewall" "allow_rdp" {

  # Firewall rule name (unique within VPC).
  name = "ad-allow-rdp"

  # Target VPC network.
  network = var.vpc

  # Allow TCP port 3389 (RDP).
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  # Apply rule only to instances with this tag.
  target_tags = ["ad-allow-rdp"]

  # Source range allowed to connect.
  source_ranges = ["0.0.0.0/0"]
}

# ------------------------------------------------------------------------------
# Windows AD Management VM
# ------------------------------------------------------------------------------
# Windows Server instance for AD management tasks.
resource "google_compute_instance" "windows_ad_instance" {

  # VM name with random suffix.
  name = "win-ad-${random_string.vm_suffix.result}"

  # Standard machine type suitable for Windows workloads.
  machine_type = "e2-standard-2"

  # Deployment zone (must align with subnet region).
  zone = "us-central1-a"

  # --------------------------------------------------------------------------
  # Boot Disk
  # --------------------------------------------------------------------------
  # Use latest Windows Server 2022 image.
  boot_disk {
    initialize_params {
      image = data.google_compute_image.windows_2022.self_link
    }
  }

  # --------------------------------------------------------------------------
  # Network Interface
  # --------------------------------------------------------------------------
  # Attach to VPC and subnet.
  network_interface {
    network    = var.vpc
    subnetwork = var.subnet

    # Attach ephemeral public IP for RDP access.
    access_config {}
  }

  # --------------------------------------------------------------------------
  # Service Account
  # --------------------------------------------------------------------------
  # Attach service account with cloud-platform scope.
  service_account {
    email  = local.service_account_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  # --------------------------------------------------------------------------
  # Startup Script
  # --------------------------------------------------------------------------
  # Run PowerShell script to join Managed AD domain.
  metadata = {
    windows-startup-script-ps1 = templatefile("./scripts/ad_join.ps1", {
      domain_fqdn  = "mcloud.mikecloud.com"
      computers_ou = "OU=Computers,OU=Cloud,DC=mcloud,DC=mikecloud,DC=com"
    })
  }

  # Apply RDP firewall tag.
  tags = ["ad-allow-rdp"]
}

# ------------------------------------------------------------------------------
# Windows Image Data Source
# ------------------------------------------------------------------------------
# Retrieve latest Windows Server 2022 image from official project.
data "google_compute_image" "windows_2022" {
  family  = "windows-2022"
  project = "windows-cloud"
}
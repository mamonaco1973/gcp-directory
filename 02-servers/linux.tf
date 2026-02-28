# ==============================================================================
# linux.tf
# ------------------------------------------------------------------------------
# Purpose:
#   - Deploy a Linux VM for Managed AD administration.
#   - Configure SSH access via firewall rule.
#   - Join VM to AD domain using startup script.
#
# Notes:
#   - VM uses Ubuntu 24.04 LTS image (latest family version).
#   - SSH is open to 0.0.0.0/0 (restrict for production).
#   - Random suffix ensures unique VM names.
# ==============================================================================

# ------------------------------------------------------------------------------
# Random Suffix
# ------------------------------------------------------------------------------
# Generate a 6-char lowercase string for unique VM naming.
resource "random_string" "vm_suffix" {
  length  = 6
  special = false
  upper   = false
}

# ------------------------------------------------------------------------------
# Firewall Rule: Allow SSH
# ------------------------------------------------------------------------------
# Allow inbound TCP/22 from anywhere to tagged instances.
resource "google_compute_firewall" "allow_ssh" {

  # Firewall rule name (unique within VPC).
  name = "ad-allow-ssh"

  # Target VPC network.
  network = var.vpc

  # Allow TCP port 22 (SSH).
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Apply rule only to instances with this tag.
  target_tags = ["ad-allow-ssh"]

  # Source range allowed to connect.
  source_ranges = ["0.0.0.0/0"]
}

# ------------------------------------------------------------------------------
# Linux AD VM
# ------------------------------------------------------------------------------
# Ubuntu VM used for AD join and administrative tasks.
resource "google_compute_instance" "linux_ad_instance" {

  # VM name with random suffix.
  name = "linux-ad-${random_string.vm_suffix.result}"

  # Small, low-cost machine type for dev/test.
  machine_type = "e2-micro"

  # Deployment zone (must match subnet region).
  zone = "us-central1-a"

  # --------------------------------------------------------------------------
  # Boot Disk
  # --------------------------------------------------------------------------
  # Use latest Ubuntu 24.04 LTS image.
  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu_latest.self_link
    }
  }

  # --------------------------------------------------------------------------
  # Network Interface
  # --------------------------------------------------------------------------
  # Attach to VPC and subnet.
  network_interface {
    network    = var.vpc
    subnetwork = var.subnet

    # Attach ephemeral public IP.
    access_config {}
  }

  # --------------------------------------------------------------------------
  # Metadata / Startup Script
  # --------------------------------------------------------------------------
  # Enable OS Login and run domain join script.
  metadata = {
    enable-oslogin = "TRUE"

    startup-script = templatefile("./scripts/ad_join.sh", {
      domain_fqdn  = "mcloud.mikecloud.com"
      computers_ou = "OU=Computers,OU=Cloud,DC=mcloud,DC=mikecloud,DC=com"
    })
  }

  # --------------------------------------------------------------------------
  # Service Account
  # --------------------------------------------------------------------------
  # Attach service account with cloud-platform scope.
  service_account {
    email  = local.service_account_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  # Apply SSH firewall tag.
  tags = ["ad-allow-ssh"]
}

# ------------------------------------------------------------------------------
# Ubuntu Image Data Source
# ------------------------------------------------------------------------------
# Retrieve latest Ubuntu 24.04 LTS image from official project.
data "google_compute_image" "ubuntu_latest" {
  family  = "ubuntu-2404-lts-amd64"
  project = "ubuntu-os-cloud"
}
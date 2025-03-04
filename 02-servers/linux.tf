# --- Generate a random string to use as a suffix for resource names ---
resource "random_string" "vm_suffix" {
  length  = 6     # 6-character suffix
  special = false # Exclude special characters
  upper   = false # Lowercase only
}

# Firewall Rule: Allow SSH traffic (port 22)
# This rule allows SSH access to instances tagged with "allow-ssh" from any source IP.

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"                # Name of the firewall rule.
  network = "ad-vpc"                   # Network to apply the rule 

  allow {
    protocol = "tcp"                   # Specifies TCP protocol for SSH.
    ports    = ["22"]                  # Allows incoming traffic on port 22 (SSH).
  }

  target_tags = ["allow-ssh"]          # Applies the rule to instances tagged with "allow-ssh".

  source_ranges = ["0.0.0.0/0"]        # Permits traffic from any IP address.
}

# Compute Instance: Ubuntu VM
# Deploys a lightweight Ubuntu 24.04 VM with essential configurations.
resource "google_compute_instance" "linux_ad_instance" {
  name         = "linux-ad-${random_string.vm_suffix.result}"   # Name of the instance.
  machine_type = "e2-micro"                                     # Machine type for cost-efficient workloads.
  zone         = "us-central1-a"                                # Deployment zone for the instance.

  # Boot Disk Configuration
  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu_latest.self_link  # Specifies the latest Ubuntu image.
    }
  }

  # Network Interface Configuration
  network_interface {
    network = "ad-vpc"                      # Set to your VPC name.
    subnetwork = "ad-subnet"                # Set to your desired subnet name.
    access_config {}                        # Automatically assigns a public IP for external access.
  }

  metadata = {
        enable-oslogin = "TRUE"
  }


  # Metadata for Startup Script
  # metadata_startup_script = file("./scripts/startup_script.sh")  # Runs a startup script upon instance boot.

  # Tags for Firewall Rules
  tags = ["allow-ssh"]                     # Tags to match firewall rules for SSH and HTTP access.
}

# Data Source: Ubuntu Image
# Fetches the latest Ubuntu 24.04 LTS image from the official Ubuntu Cloud project.
data "google_compute_image" "ubuntu_latest" {
  family  = "ubuntu-2404-lts-amd64"         # Specifies the Ubuntu image family.
  project = "ubuntu-os-cloud"               # Google Cloud project hosting the image.
}

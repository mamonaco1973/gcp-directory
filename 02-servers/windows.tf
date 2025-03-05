# Firewall Rule: Allow RDP traffic (port 3389)
# This rule allows RDP access to instances tagged with "allow-rdp" from any source IP.

resource "google_compute_firewall" "allow_rdp" {
  name    = "allow-rdp"                # Name of the firewall rule
  network = "ad-vpc"                    # Network to apply the rule

  allow {
    protocol = "tcp"
    ports    = ["3389"]                  # RDP port
  }

  target_tags = ["allow-rdp"]            # Applies the rule to instances tagged with "allow-rdp"

  source_ranges = ["0.0.0.0/0"]          # Permits traffic from any IP address (you could restrict to your own IP if desired)
}

# Compute Instance: Windows Server 2022 VM
# Deploys a Windows Server 2022 VM.
resource "google_compute_instance" "windows_ad_instance" {
  name         = "win-ad-${random_string.vm_suffix.result}"      # Instance name
  machine_type = "e2-standard-2"                                  # Windows needs more resources than Ubuntu
  zone         = "us-central1-a"                                  # Deployment zone for the instance

  # Boot Disk Configuration
  boot_disk {
    initialize_params {
      image = data.google_compute_image.windows_2022.self_link    # Specifies Windows Server 2022 image
    }
  }

  # Network Interface Configuration
  network_interface {
    network    = "ad-vpc"            # Set to your VPC name
    subnetwork = "ad-subnet"         # Set to your desired subnet name
    access_config {}                  # Automatically assigns a public IP for external access
  }

  service_account {
    email  = local.service_account_email # Use the existing service account
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  # Metadata for Startup Script
  metadata = {
    windows-startup-script-ps1 = templatefile("./scripts/ad-join.ps1", {
      domain_fqdn =  "mcloud.mikecloud.com"
      computers_ou = "OU=Computers,OU=Cloud,DC=mcloud,DC=mikecloud,DC=com"
    })
  }

  # Tags for Firewall Rules
  tags = ["allow-rdp"]                  # Matches firewall rule for RDP access
}

# Data Source: Windows Server 2022 Image
data "google_compute_image" "windows_2022" {
  family  = "windows-2022"
  project = "windows-cloud"              # Official GCP project for Windows images
}


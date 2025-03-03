# Google Cloud Provider Configuration
# Configures the Google Cloud provider using project details and credentials from a JSON file.
provider "google" {
  project     = local.credentials.project_id             # Specifies the project ID extracted from the decoded credentials file.
  credentials = file("./credentials.json")               # Path to the credentials JSON file for Google Cloud authentication.
}

# Local Variables
# Reads and decodes the credentials JSON file to extract useful details like project ID and service account email.
locals {
  credentials            = jsondecode(file("./credentials.json"))  # Decodes the JSON file into a map for easier access.
  service_account_email  = local.credentials.client_email          # Extracts the service account email from the decoded JSON map.
}

# Firewall Rule: Allow SSH traffic (port 22)
# This rule allows SSH access to instances tagged with "allow-ssh" from any source IP.

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"                # Name of the firewall rule.
  network = "default"                  # Network to apply the rule (uses the default VPC network).

  allow {
    protocol = "tcp"                   # Specifies TCP protocol for SSH.
    ports    = ["22"]                  # Allows incoming traffic on port 22 (SSH).
  }

  target_tags = ["allow-ssh"]          # Applies the rule to instances tagged with "allow-ssh".

  source_ranges = ["0.0.0.0/0"]        # Permits traffic from any IP address.
}

# Firewall Rule: Allow HTTP traffic (port 80)
# This rule allows HTTP access to instances tagged with "allow-http" from any source IP.

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"               # Name of the firewall rule.
  network = "default"                  # Network to apply the rule (uses the default VPC network).

  allow {
    protocol = "tcp"                   # Specifies TCP protocol for HTTP.
    ports    = ["80"]                  # Allows incoming traffic on port 80 (HTTP).
  }

  target_tags = ["allow-http"]         # Applies the rule to instances tagged with "allow-http".

  source_ranges = ["0.0.0.0/0"]        # Permits traffic from any IP address.
}

# Compute Instance: Ubuntu VM
# Deploys a lightweight Ubuntu 24.04 VM with essential configurations.
resource "google_compute_instance" "ubuntu_vm" {
  name         = "setup-vm"                 # Name of the instance.
  machine_type = "e2-micro"                 # Machine type for cost-efficient workloads.
  zone         = "us-central1-a"            # Deployment zone for the instance.

  # Boot Disk Configuration
  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu_latest.self_link  # Specifies the latest Ubuntu image.
    }
  }

  # Network Interface Configuration
  network_interface {
    network = "default"                     # Attaches the instance to the default VPC network.
    access_config {}                        # Automatically assigns a public IP for external access.
  }

  # Metadata for Startup Script
  metadata_startup_script = file("./scripts/startup_script.sh")  # Runs a startup script upon instance boot.

  # SSH Key Metadata
  metadata = {
    ssh-keys = "ubuntu:${file("./keys/Public_Key")}"  # Sets up SSH key access for the "ubuntu" user.
  }

  # Tags for Firewall Rules
  tags = ["allow-ssh", "allow-http"]        # Tags to match firewall rules for SSH and HTTP access.

  # Service Account Configuration
  service_account {
    email  = "default"                      # Uses the default service account for the project.
    scopes = ["cloud-platform"]             # Grants access to all Google Cloud APIs.
  }
}

# Data Source: Ubuntu Image
# Fetches the latest Ubuntu 24.04 LTS image from the official Ubuntu Cloud project.
data "google_compute_image" "ubuntu_latest" {
  family  = "ubuntu-2404-lts-amd64"         # Specifies the Ubuntu image family.
  project = "ubuntu-os-cloud"               # Google Cloud project hosting the image.
}

# Output: Public IP of the Ubuntu VM
# Outputs the public IP address of the deployed VM.
output "instance_public_ip" {
  value       = google_compute_instance.ubuntu_vm.network_interface[0].access_config[0].nat_ip  
                                                           # Retrieves the NAT IP of the instance.
  description = "The public IP address of the Ubuntu VM."  # Describes the output for clarity.
}

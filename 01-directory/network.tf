resource "google_compute_network" "ad_vpc" {
  name                    = "ad-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "ad_subnet" {
  name          = "ad-subnet"
  region        = "us-central1"
  network       = google_compute_network.ad_vpc.id
  ip_cidr_range = "10.1.0.0/24"
}

resource "google_compute_network" "ad_vpc" {
  name                    = "ad-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "ad_subnet_1" {
  name          = "ad-subnet-1"
  region        = "us-central1"
  network       = google_compute_network.ad_vpc.id
  ip_cidr_range = "10.1.0.0/24"
}

resource "google_compute_subnetwork" "ad_subnet_2" {
  name          = "ad-subnet-2"
  region        = "us-central1"
  network       = google_compute_network.ad_vpc.id
  ip_cidr_range = "10.1.1.0/24"
}

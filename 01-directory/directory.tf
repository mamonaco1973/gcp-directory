
resource "google_active_directory_domain" "mikecloud_ad" {
  domain_name       = "mcloud.mikecloud.com"
  locations         = ["us-central1"]
  reserved_ip_range = "192.168.255.0/24" 
  authorized_networks = [google_compute_network.ad_vpc.id]
  deletion_protection = false
}

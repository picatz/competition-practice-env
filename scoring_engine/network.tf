resource "google_compute_network" "scoring" {
  name = "scoring-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "scoring" {
  network = "scoring-network"
  name    = "scoring-subnet"
  region  = "us-east1"

  ip_cidr_range = "192.168.3.0/24"

  depends_on = ["google_compute_network.scoring"]
}




resource "google_compute_firewall" "allow_icmp" {
  name    = "allow-icmp"
  network = "scoring-network"

  allow {
    protocol = "icmp"
  }

  depends_on = ["google_compute_network.scoring"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = "scoring-network"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  depends_on = ["google_compute_network.scoring"]
}

resource "google_compute_firewall" "allow_web" {
  name    = "allow-web"
  network = "scoring-network"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  
  depends_on = ["google_compute_network.scoring"]
}

resource "google_compute_network_peering" "team1" {
  name = "team1-peering"
  network = "https://www.googleapis.com/compute/v1/projects/iasa-scoring-engine/global/networks/scoring-network"
  peer_network = "https://www.googleapis.com/compute/v1/projects/iasa-team-0001/global/networks/team1-network"

  depends_on = ["google_compute_network.scoring"]
}

resource "google_compute_network_peering" "team2" {
  name = "team2-peering"
  network = "https://www.googleapis.com/compute/v1/projects/iasa-scoring-engine/global/networks/scoring-network"
  peer_network = "https://www.googleapis.com/compute/v1/projects/iasa-team-0010/global/networks/team2-network"

  depends_on = ["google_compute_network.scoring", "google_compute_network_peering.team1"]
}
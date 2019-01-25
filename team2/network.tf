resource "google_compute_network" "team2" {
  name = "team2-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "team2" {
  network = "team2-network"
  name    = "team2-subnet"
  region  = "us-east1"

  ip_cidr_range = "192.168.2.0/24"

  depends_on = ["google_compute_network.team2"]
}

resource "google_compute_network_peering" "team2" {
  name = "team2-peering"
  network = "https://www.googleapis.com/compute/v1/projects/iasa-team-0010/global/networks/team2-network"
  peer_network = "https://www.googleapis.com/compute/v1/projects/iasa-team-0001/global/networks/team1-network"

  depends_on = ["google_compute_network.team2"]
}

resource "google_compute_network_peering" "scoring" {
  name = "scoring-peering"
  network = "https://www.googleapis.com/compute/v1/projects/iasa-team-0010/global/networks/team2-network"
  peer_network = "https://www.googleapis.com/compute/v1/projects/iasa-scoring-engine/global/networks/scoring-network"

  depends_on = ["google_compute_network.team2", "google_compute_network_peering.team2"]
}

resource "google_compute_firewall" "allow_icmp" {
  name    = "allow-icmp"
  network = "team2-network"

  allow {
    protocol = "icmp"
  }

  depends_on = ["google_compute_network.team2"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = "team2-network"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  depends_on = ["google_compute_network.team2"]
}

resource "google_compute_firewall" "allow_rdp" {
  name    = "allow-rdp"
  network = "team2-network"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  
  depends_on = ["google_compute_network.team2"]
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = "team2-network"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  
  depends_on = ["google_compute_network.team2"]
}

resource "google_compute_firewall" "allow_ftp" {
  name    = "allow-ftp"
  network = "team2-network"

  allow {
    protocol = "tcp"
    ports    = ["21"]
  }
  
  depends_on = ["google_compute_network.team2"]
}

resource "google_compute_firewall" "allow_ldap" {
  name    = "allow-ldap"
  network = "team2-network"

  allow {
    protocol = "tcp"
    ports    = ["389"]
  }
  
  depends_on = ["google_compute_network.team2"]
}

resource "google_compute_firewall" "allow_mysql" {
  name    = "allow-mysql"
  network = "team2-network"

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }
  
  depends_on = ["google_compute_network.team2"]
}

resource "google_compute_firewall" "allow_mssql" {
  name    = "allow-mssql"
  network = "team2-network"

  allow {
    protocol = "tcp"
    ports    = ["1433"]
  }
  
  depends_on = ["google_compute_network.team2"]
}


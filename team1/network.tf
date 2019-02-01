resource "google_compute_network" "team1" {
  name = "team1-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "team1" {
  network = "team1-network"
  name    = "team1-subnet"
  region  = "us-east1"

  ip_cidr_range = "192.168.1.0/24"

  depends_on = ["google_compute_network.team1"]
}

resource "google_compute_network_peering" "team1" {
  name = "team1-peering"
  network = "https://www.googleapis.com/compute/v1/projects/iasa-team-0001/global/networks/team1-network"
  peer_network = "https://www.googleapis.com/compute/v1/projects/iasa-team-0010/global/networks/team2-network"

  depends_on = ["google_compute_network.team1"]
}

resource "google_compute_network_peering" "scoring" {
  name = "scoring-peering"
  network = "https://www.googleapis.com/compute/v1/projects/iasa-team-0001/global/networks/team1-network"
  peer_network = "https://www.googleapis.com/compute/v1/projects/iasa-scoring-engine/global/networks/scoring-network"

  depends_on = ["google_compute_network.team1", "google_compute_network_peering.team1"]
}


resource "google_compute_firewall" "allow_icmp" {
  name    = "allow-icmp"
  network = "team1-network"

  allow {
    protocol = "icmp"
  }

  depends_on = ["google_compute_network.team1"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = "team1-network"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  depends_on = ["google_compute_network.team1"]
}

resource "google_compute_firewall" "allow_rdp" {
  name    = "allow-rdp"
  network = "team1-network"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  
  depends_on = ["google_compute_network.team1"]
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = "team1-network"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  
  depends_on = ["google_compute_network.team1"]
}

resource "google_compute_firewall" "allow_ftp" {
  name    = "allow-ftp"
  network = "team1-network"

  allow {
    protocol = "tcp"
    ports    = ["21"]
  }
  
  depends_on = ["google_compute_network.team1"]
}

resource "google_compute_firewall" "allow_ldap" {
  name    = "allow-ldap"
  network = "team1-network"

  allow {
    protocol = "tcp"
    ports    = ["389"]
  }
  
  depends_on = ["google_compute_network.team1"]
}

resource "google_compute_firewall" "allow_mysql" {
  name    = "allow-mysql"
  network = "team1-network"

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }
  
  depends_on = ["google_compute_network.team1"]
}

resource "google_compute_firewall" "allow_mssql" {
  name    = "allow-mssql"
  network = "team1-network"

  allow {
    protocol = "tcp"
    ports    = ["1433"]
  }
  
  depends_on = ["google_compute_network.team1"]
}
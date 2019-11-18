resource "google_compute_network" "team" {
  name = "${var.team_name}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "team" {
  network = google_compute_network.team.name
  name    = "${var.team_name}-subnet"
  region  = "${var.region}"

  ip_cidr_range = "${var.cidr_range}"
}

resource "google_compute_network_peering" "team" {
  for_each = var.enemy_teams

  name         = "${each.value}-peering"
  network      = "https://www.googleapis.com/compute/v1/projects/${var.project}/global/networks/${google_compute_network.team.name}"
  peer_network = "https://www.googleapis.com/compute/v1/projects/${each.key}/global/networks/${each.value}"

  depends_on = [google_compute_network_peering.scoring]
}

resource "google_compute_network_peering" "scoring" {
  for_each = var.scoring_engine

  name         = "scoring-peering"
  network      = "https://www.googleapis.com/compute/v1/projects/${var.project}/global/networks/${google_compute_network.team.name}"
  peer_network = "https://www.googleapis.com/compute/v1/projects/${each.key}/global/networks/${each.value}"
}

resource "google_compute_firewall" "allow_icmp" {
  name    = "allow-icmp"
  network = google_compute_network.team.name

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.team.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "allow_rdp" {
  name    = "allow-rdp"
  network = google_compute_network.team.name

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.team.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "allow_ftp" {
  name    = "allow-ftp"
  network = google_compute_network.team.name

  allow {
    protocol = "tcp"
    ports    = ["21"]
  }
}

resource "google_compute_firewall" "allow_ldap" {
  name    = "allow-ldap"
  network = google_compute_network.team.name

  allow {
    protocol = "tcp"
    ports    = ["389"]
  }
}

resource "google_compute_firewall" "allow_mysql" {
  name    = "allow-mysql"
  network = google_compute_network.team.name

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }
}

resource "google_compute_firewall" "allow_mssql" {
  name    = "allow-mssql"
  network = google_compute_network.team.name

  allow {
    protocol = "tcp"
    ports    = ["1433"]
  }
}
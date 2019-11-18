resource "google_compute_network" "scoring" {
  name = "scoring-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "scoring" {
  network = google_compute_network.scoring.name
  name    = "scoring-subnet"
  region  = "${var.region}"

  ip_cidr_range = "${var.cidr_range}"
}

resource "google_compute_firewall" "allow_icmp" {
  name    = "allow-icmp"
  network = google_compute_network.scoring.name

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.scoring.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "allow_scoring_engine_web_internet" {
  name    = "allow-scoring-engine-web-internet"
  network = google_compute_network.scoring.name

  allow {
    protocol = "tcp"
    ports    = ["6767"]
  }

  source_ranges = ["0.0.0.0/0"]
}


resource "google_compute_firewall" "allow_web" {
  name    = "allow-web"
  network = google_compute_network.scoring.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_network_peering" "teams" {
  for_each = var.teams

  name         = "${each.value}-peering"
  network      = "https://www.googleapis.com/compute/v1/projects/${var.project}/global/networks/${google_compute_network.scoring.name}"
  peer_network = "https://www.googleapis.com/compute/v1/projects/${each.key}/global/networks/${each.value}"
}

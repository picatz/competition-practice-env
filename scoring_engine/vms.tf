resource "google_compute_instance" "engine" {
  name         = "engine"
  machine_type = "g1-small"
  zone         = "us-east1-b"

  boot_disk {
    initialize_params {
      image = "engine"
      size  = 10
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.scoring.name

    access_config {
      // Ephemeral IP
    }
  }

  tags = [ "http-server" ]

  depends_on = ["null_resource.template"]
}
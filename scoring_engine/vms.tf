resource "google_compute_instance" "engine" {
  name         = "engine"
  machine_type = "n1-standard-4"
  zone         = "us-east1-b"

  boot_disk {
    initialize_params {
      image = "engine"
      size  = 10
    }
  }

  network_interface {
    subnetwork = "scoring-subnet"

    access_config {
      // Ephemeral IP
    }
  }

  depends_on = ["google_compute_subnetwork.scoring", "null_resource.template"]
}
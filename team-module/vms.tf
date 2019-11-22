resource "google_compute_instance" "vm" {
  count = length(var.vms)

  name         = var.vms[count.index].name
  machine_type = var.vms[count.index].machine_type
  zone         = "us-east1-b"

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.vms[count.index].image
      size  = var.vms[count.index].disk_size
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.team.name

    // If the network IP address was given, use that, otherwise use the zero-value
    // so the internal network IP address is automatically assigned.
    network_ip = var.vms[count.index].ip_addr != "" ? var.vms[count.index].ip_addr : ""

    access_config {
      // Ephemeral external IP address
    }
  }

  metadata = {
    enable-oslogin = true
  }
}

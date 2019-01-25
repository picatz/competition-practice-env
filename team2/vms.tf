resource "google_compute_instance" "ubuntu" {
  name         = "ubuntu"
  machine_type = "f1-micro"
  zone         = "us-east1-b"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
      size  = 10
    }
  }

  network_interface {
    subnetwork = "team2-subnet"

    network_ip = "192.168.2.2"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    enable-oslogin = true
  }

  depends_on = ["google_compute_subnetwork.team2"]
}

resource "google_compute_instance" "centos" {
  name         = "centos"
  machine_type = "f1-micro"
  zone         = "us-east1-b"

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
      size  = 10
    }
  }

  network_interface {
    subnetwork = "team2-subnet"

    network_ip = "192.168.2.3"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    enable-oslogin = true
  }

  depends_on = ["google_compute_subnetwork.team2"]
}

resource "google_compute_instance" "windows" {
  name         = "windows"
  machine_type = "f1-micro"
  zone         = "us-east1-b"

  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-2016"
      size  = 50
    }
  }

  network_interface {
    subnetwork = "team2-subnet"

    network_ip = "192.168.2.4"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    enable-oslogin = true
  }

  depends_on = ["google_compute_subnetwork.team2"]
}

server {
  ip   = "0.0.0.0"
  port = "6767"
}

scoring_interval = "1m"

state {
  save_interval = "5m"
  save_path     = "/tmp/service-registry.json"
}

team "team-1" {
  service "http" {
    protocol = "tcp"
    ip       = "192.168.1.2"
    port     = 80
  }

  service "ssh" {
    protocol = "tcp"
    ip       = "192.168.1.3"
    port     = 22
  }
}

team "team-2" {
  service "http" {
    protocol = "tcp"
    ip       = "192.168.2.2"
    port     = 80
  }

  service "ssh" {
    protocol = "tcp"
    ip       = "192.168.2.3"
    port     = 22
  }
}

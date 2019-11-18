server {
  ip   = "127.0.0.1"
  port = 6767
}

scoring_interval = "10s"

state {
  save_interval = "5m"
  save_path     = "/tmp/service-registry.json"
}

team "localhost" {
  service "scoring-engine" {
    ip       = "127.0.0.1"
    port     = 6767
  }
}

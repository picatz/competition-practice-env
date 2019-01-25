provider "google" {
  project     = "iasa-scoring-engine"
  credentials = "${file("account.json")}"
}

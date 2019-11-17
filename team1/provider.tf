provider "google" {
  project     = var.project
  credentials = file("account.json")
}

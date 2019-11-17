variable "project" {
  type = string
}

variable "region" {
  type = string
  default = "us-east1"
}

variable "cidr_range" {
  type = string
  default = "192.168.3.0/24"
}

variable "teams" {
  type    = map(string)
  default = {
      # project -> team_network_name
      "emu-cloud-team-2" = "team2-network"
  }
}

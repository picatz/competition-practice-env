variable "project" {
  type = string
}

variable "region" {
  type = string
  default = "us-east1"
}

variable "cidr_range" {
  type = string
  default = "192.168.2.0/24"
}

variable "team_name" {
  type    = string
  default = "team2"
}

variable "team_members" {
  type = list(string)

  default = []
}

variable "scoring_engine" {
  type    = map(string)
  default = {
      # project -> scording_network_name
      "emu-cloud-scoring" = "scoring-network"
  }
}

variable "enemy_teams" {
  type    = map(string)
  default = {
      # project -> team_network_name
      "emu-cloud-team-1" = "team1-network"
  }
}

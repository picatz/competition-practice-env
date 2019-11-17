variable "project" {
  type = string
}

variable "credentials" {
  type = string
}

variable "team_name" {
  type = string
}

variable "cidr_range" {
  type = string
}

variable "scoring_engine" {
  type = map(string)
}

variable "enemy_teams" {
  type = map(string)
}

variable "region" {
  type = string
  default = "us-east1"
}

variable "team_members" {
  type = list(string)

  default = []
}

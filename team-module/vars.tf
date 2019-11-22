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

variable "vms" {
  type = list(object({
    name         = string
    image        = string
    machine_type = string
    disk_size    = number
    ip_addr      = string
  }))

  default = [
    {
      name         = "ubuntu"
      image        = "ubuntu-os-cloud/ubuntu-1804-lts"
      machine_type = "n1-standard-1"
      disk_size    = 10
      ip_addr      = ""
    },
    {
      name         = "centos"
      image        = "centos-cloud/centos-7"
      machine_type = "n1-standard-1"
      disk_size    = 10
      ip_addr      = ""
    },
    {
      name         = "windows"
      image        = "windows-cloud/windows-2016"
      machine_type = "n1-standard-2"
      disk_size    = 50
      ip_addr      = ""
    },
  ]
}
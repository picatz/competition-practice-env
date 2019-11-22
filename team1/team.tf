module "team" {
    source = "../team-module"

    project = var.project

    credentials = file("account.json")

    team_name = "team1"

    cidr_range = "192.168.1.0/24"

    enemy_teams = {
        # project -> team_network_name
        "emu-cloud-team-2" = "team2-network"
    }

    scoring_engine = {
        # project -> scording_network_name
        "emu-cloud-scoring" = "scoring-network"
    }

    vms = [
        {
          name         = "ubuntu"
          image        = "ubuntu-os-cloud/ubuntu-1804-lts"
          machine_type = "n1-standard-1"
          disk_size    = 10
          ip_addr      = "192.168.1.2"
        },
        {
          name         = "centos"
          image        = "centos-cloud/centos-7"
          machine_type = "n1-standard-1"
          disk_size    = 10
          ip_addr      = "192.168.1.3"
        },
        {
          name         = "windows"
          image        = "centos-cloud/centos-7"
          machine_type = "windows-cloud/windows-2016"
          disk_size    = 50
          ip_addr      = "192.168.1.4"
        },
    ]
}

module "team" {
    source = "../team-module"

    project = var.project

    credentials = file("account.json")

    team_name = "team2"

    cidr_range = "192.168.2.0/24"

    enemy_teams = {
        # project -> team_network_name
        "emu-cloud-team-1" = "team1-network"
    }

    scoring_engine = {
        # project -> scording_network_name
        "emu-cloud-scoring" = "scoring-network"
    }
}
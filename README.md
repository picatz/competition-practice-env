# competition-practice-env

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2Fpicatz%2Fcompetition-practice-env)

Read the wiki [here](https://github.com/picatz/competition-practice-env/wiki).

<p align="center">
  <img alt="scoreboard" src="https://github.com/picatz/competition-practice-env/blob/master/scoreboard.png"/>
<p>


<p align="center">
  <img alt="diagram" src="https://github.com/picatz/competition-practice-env/blob/master/diagram.png"/>
<p>

The scoring engine application, like the rest of the infrastructure, is [defined as HCL](https://github.com/picatz/competition-practice-env/blob/master/scoring_engine/template/service_registry.hcl):

```hcl
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

  service "rdp" {
    protocol = "tcp"
    ip       = "192.168.1.4"
    port     = 3389
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

  service "rdp" {
    protocol = "tcp"
    ip       = "192.168.2.4"
    port     = 3389
  }
}

```
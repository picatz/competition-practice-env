# competition-practice-env
Read the wiki [here](https://github.com/picatz/competition-practice-env/wiki).

<p align="center">
  <img alt="scoreboard" src="https://github.com/picatz/competition-practice-env/blob/master/scoreboard.png"/>
<p>


<p align="center">
  <img alt="diagram" src="https://github.com/picatz/competition-practice-env/blob/master/diagram.png"/>
<p>

The scoring engine application, like the rest of the infrastructure, is [defined as HCL](https://github.com/picatz/competition-practice-env/blob/master/scoring_engine/template/service_registry.hcl):

```hcl
// The IP address and port to serve the engine API
// and web UI on. While this is a customizable value,
// you probably don't want to change these.
server {
  ip   = "0.0.0.0"
  port = "6767"
}

// The ammount of time to wait until scoring the next round
// in the scoring engine.
scoring_interval = "1m"

// The state save information. This allows for white-team to be
// able to use a copy of the game's state. This will contain the
// game's service setup and point information in the even the
// engine crashes and the in-memory values are lost.
state {
  save_interval = "5m"
  save_path     = "/tmp/service-registry.json"
}

// Each team is defined in a team block.

// The team block for team-1 containing the scored services
// the engine will score.
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

// The team block for team-2 containing the scored services
// the engine will score.
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
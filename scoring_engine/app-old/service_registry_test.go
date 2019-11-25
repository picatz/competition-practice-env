package main

import (
	"testing"
)

func TestService(t *testing.T) {
	service := NewService("ssh", "192.168.1.2", 22)

	if service.Kind != "ssh" {
		t.Fatalf("expected service kind to be \"ssh\" got: %q", service.Kind)
	}

	if service.IP != "192.168.1.2" {
		t.Fatalf("expected service IP to be \"192.168.1.2\" got: %q", service.IP)
	}

	if service.Port != 22 {
		t.Fatalf("expected service port to be \"22\" got: %q", service.Port)
	}
}

func TestServiceRegisty(t *testing.T) {
	serviceRegistry := NewServiceRegistry()

	if len(serviceRegistry.Services) != 0 {
		t.Fatal("Unexpected number of services found in the brand-new service registry")
	}

	serviceRegistry.AddService("team-1", NewService("ssh", "192.168.1.2", 22))

	if len(serviceRegistry.Services) != 1 {
		t.Fatal("Unexpected number of services found in the service registry")
	}

	team1Services := serviceRegistry.ServicesForTeam("team-1")

	if len(team1Services) != 1 {
		t.Fatal("Unexpected number of services found in the service registry for team-1")
	}

	// artificially bump the score of a service without actually scoring it for test
	serviceRegistry.Services["team-1"][0].Points = 1

	scores, err := serviceRegistry.GetScores()

	if err != nil {
		t.Fatal(err)
	}

	if len(scores) != 1 {
		t.Fatal("Unexpected number of service scores found in the service registry for team-1")
	}

	if scores["team-1"] != 1 {
		t.Fatal("Unexpected score of for team found in the service registry for team-1")
	}
}

func TestLoadServiceRegistry(t *testing.T) {
	srvReg, err := LoadServiceRegistryConfig("./test-fixtures/example_service_regisry.hcl")
	if err != nil {
		t.Fatal(err)
	}

	if len(srvReg.Teams()) != 2 {
		t.Fatalf("Unexpected number of teams found in the service registry, got: %d", len(srvReg.Teams()))
	}

	if len(srvReg.Services["team-1"]) != 2 {
		t.Fatalf("Unexpected number of services found in the service registry, got: %d", len(srvReg.Services))
	}
}

func TestServiceRegistryStart(t *testing.T) {
	srvReg, err := LoadServiceRegistryConfig("./test-fixtures/localhost_service_registry.hcl")
	if err != nil {
		t.Fatal(err)
	}

	err = srvReg.Start()
	if err != nil {
		t.Fatal(err)
	}
}

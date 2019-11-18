package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/gobuffalo/packr"
	"github.com/hashicorp/hcl/v2/hclsimple"
)

// LoadServiceRegistryConfig handles loading an HCL-style config for a Service Regisry.
//
// Reference the ./test-fixtures directroy for examples of the config.
func LoadServiceRegistryConfig(filePath string) (*ServiceRegistry, error) {
	config := ServiceRegistryConfig{}
	err := hclsimple.DecodeFile(filePath, nil, &config)
	if err != nil {
		return nil, err
	}

	sr := NewServiceRegistry()

	if config.ScoringInterval != "" {
		scoringInterval, err := time.ParseDuration(config.ScoringInterval)
		if err != nil {
			return nil, err
		}
		sr.scoringInterval = scoringInterval
	} else {
		scoringInterval, _ := time.ParseDuration("1min")
		sr.scoringInterval = scoringInterval
	}

	if config.Listener != nil {
		sr.listener = config.Listener
	} else {
		sr.listener = &ServiceRegistryListener{}
	}

	if config.State != nil {
		stateSaveInterval, err := time.ParseDuration(config.State.SaveInterval)
		if err != nil {
			return nil, err
		}
		sr.stateSaveInterval = stateSaveInterval
		sr.stateSavePath = config.State.SavePath
	} else {
		stateSaveInterval, _ := time.ParseDuration("5min")
		sr.stateSaveInterval = stateSaveInterval
		sr.stateSavePath = "/tmp/service-registry.json"
	}

	for _, team := range config.Teams {
		for _, service := range team.Services {
			sr.AddService(team.Name, service)
		}
	}

	return sr, nil
}

// ServiceRegistryConfig is a helper struct to allow multiple team blocks to be used
// in the HCL config.
type ServiceRegistryConfig struct {
	Teams []*TeamConfig `hcl:"team,block"`
	// Server listener information
	Listener *ServiceRegistryListener `hcl:"server,block"`

	// The scoring interval the registry will check the scores.
	ScoringInterval string `hcl:"scoring_interval,optional"`

	// The scoring interval the registry will check the scores.
	State *ServiceRegistryStateConfig `hcl:"state,block"`
}

// ServiceRegistryStateConfig is a helper struct that contains a service registry's state
// saving configuration stuff.
type ServiceRegistryStateConfig struct {
	SaveInterval string `hcl:"save_interval"`
	SavePath     string `hcl:"save_path"`
}

// TeamConfig is anouther helper struct to contains infromation about a team block. Then
// name of the team is the block label and the inner-part of the block allows a Service object
// to be configured.
type TeamConfig struct {
	Name     string     `hcl:"type,label"`
	Services []*Service `hcl:"service,block"`
}

// Service defines the basic infromation for a service in the engine.
type Service struct {
	sync.RWMutex
	// The kind of service such as "ssh", "ftp", "http", ect.
	Kind string `json:"kind" hcl:"type,label"`
	// The IP address the service should be available at such as "192.168.2.2".
	IP string `json:"ip" hcl:"ip"`
	// The port number the service should be available at such as "22", "80", "443", ect.
	Port int `json:"port" hcl:"port"`
	// Points keeps track of how many point a service has gotten via scoring.
	Points int `json:"points" hcl:"points,optional"`
	// Protocol defines the IP protocol to use for the testConnection, default behavior is "http"
	Protocol string `json:"protocol" hcl:"protocol,optional"`
}

// NewService creates a new Service object.
func NewService(kind, ip string, port int) *Service {
	return &Service{
		Kind:   kind,
		IP:     ip,
		Port:   port,
		Points: 0,
	}
}

// ServiceRegistryListener contains setup infromation for the server.
type ServiceRegistryListener struct {
	IP   string `hcl:"ip"`
	Port int    `hcl:"port"`
}

// ServiceRegistry keeps track of all the teams and their services.
type ServiceRegistry struct {
	sync.RWMutex
	// Server listener information
	listener *ServiceRegistryListener

	// State saving configuation
	stateSaveInterval time.Duration
	stateSavePath     string

	// The scoring interval the registry will check the scores.
	scoringInterval time.Duration

	// Services are registered in connection to a team name.
	Services map[string][]*Service `json:"services" hcl:"services"`
}

// NewServiceRegistry creates a new ServiceRegistry object.
func NewServiceRegistry() *ServiceRegistry {
	return &ServiceRegistry{
		Services: map[string][]*Service{},
	}
}

// AddService adds a new Service object to the ServiceRegistry
func (sr *ServiceRegistry) AddService(team string, service *Service) {
	sr.Lock()
	defer sr.Unlock()
	sr.Services[team] = append(sr.Services[team], service)
}

// Teams gets a list of teams that have registered services.
func (sr *ServiceRegistry) Teams() []string {
	sr.RLock()
	defer sr.RUnlock()
	teams := []string{}
	for team := range sr.Services {
		teams = append(teams, team)
	}
	return teams
}

// ServicesForTeam gets a list of registered services for a given team name.
func (sr *ServiceRegistry) ServicesForTeam(team string) []*Service {
	sr.RLock()
	defer sr.RUnlock()
	return sr.Services[team]
}

func testConnection(protocol, host string) error {
	log.Printf("Testing connection %s - %s", protocol, host)
	conn, err := net.DialTimeout(protocol, host, 2*time.Second)
	if err != nil {
		return err
	}
	return conn.Close()
}

// ScoreServices scores all the services in the registry.
func (sr *ServiceRegistry) ScoreServices() error {
	sr.Lock()
	defer sr.Unlock()

	if sr.Services == nil || len(sr.Services) == 0 {
		return fmt.Errorf("no services found in the service registry")
	}

	wg := sync.WaitGroup{}

	for teamName, services := range sr.Services {
		wg.Add(1)
		go func(teamName string, services []*Service) {
			defer wg.Done()
			for _, service := range services {
				var protocol string
				if service.Protocol == "" {
					protocol = "tcp"
				} else {
					protocol = service.Protocol
				}
				host := fmt.Sprintf("%s:%d", service.IP, service.Port)
				err := testConnection(protocol, host)
				if err == nil {
					service.Points = service.Points + 1
				} else {
					log.Printf("%s - %s - %s - %s", teamName, service.Kind, host, err.Error())
				}
			}
		}(teamName, services)
	}

	wg.Wait()

	return nil
}

// GetScores returns the current composite score for all services per team.
func (sr *ServiceRegistry) GetScores() (map[string]int, error) {
	sr.Lock()

	if sr.Services == nil || len(sr.Services) == 0 {
		return nil, fmt.Errorf("no services found in the service registry")
	}

	scores := map[string]int{}

	for teamName, services := range sr.Services {
		scores[teamName] = 0
		for _, service := range services {
			scores[teamName] = scores[teamName] + service.Points
		}
	}

	sr.Unlock()

	return scores, nil
}

// Start setups and starts a service registry server.
func (sr *ServiceRegistry) Start() error {
	if sr.Services == nil || len(sr.Services) == 0 {
		return fmt.Errorf("no services found in the service registry")
	}

	if sr.listener == nil {
		log.Println("No `listener {}` block found, using defaults")
		sr.listener = &ServiceRegistryListener{IP: "0.0.0.0", Port: 6767}
	}

	wg := sync.WaitGroup{}

	wg.Add(1)
	go func() {
		defer wg.Done()
		for {
			log.Printf("waiting %v to save state to %s", sr.stateSaveInterval, sr.stateSavePath)
			time.Sleep(sr.stateSaveInterval)
			log.Printf("saving state to %s", sr.stateSavePath)
			file, err := os.Open(sr.stateSavePath)
			if err != nil {
				if strings.Contains(err.Error(), "no such file or directory") {
					file, err = os.Create(sr.stateSavePath)
					if err != nil {
						log.Fatal(err)
					}
				} else {
					log.Fatal(err)
				}
			}
			sr.RLock()
			bytes, err := json.Marshal(sr)
			sr.RUnlock()
			if err != nil {
				log.Println("warning: save state error:", err)
				continue
			}
			file.Write(bytes)
			file.Close()
			log.Printf("saved state to %s", sr.stateSavePath)
		}
	}()

	wg.Add(1)
	go func() {
		defer wg.Done()
		for {
			log.Printf("waiting %v to score services", sr.scoringInterval)
			time.Sleep(sr.scoringInterval)
			log.Println("scoring services")
			err := sr.ScoreServices()
			if err != nil {
				log.Println("warning: scoring error:", err)
				continue
			}
			log.Println("scored services")
			for team, services := range sr.Services {
				for _, service := range services {
					log.Printf("team: %q, service: %q, ip: %s, port: %d, score: %d", team, service.Kind, service.IP, service.Port, service.Points)
				}
			}
		}
	}()

	box := packr.NewBox("./front-end")

	if sr.listener.IP != "" && sr.listener.Port != 0 {
		mux := http.NewServeMux()
		mux.Handle("/", http.FileServer(box))
		mux.HandleFunc("/api/v1/service_registry", func(w http.ResponseWriter, r *http.Request) {
			log.Printf("server: request: %v", r)
			sr.RLock()
			bytes, err := json.Marshal(sr)
			sr.RUnlock()
			if err != nil {
				http.Error(w, `{"error": true}`, http.StatusInternalServerError)
				return
			}
			fmt.Fprintf(w, string(bytes))
		})

		httpServer := http.Server{
			Addr:         fmt.Sprintf("%s:%d", sr.listener.IP, sr.listener.Port),
			Handler:      mux,
			IdleTimeout:  10 * time.Second,
			ReadTimeout:  10 * time.Second,
			WriteTimeout: 10 * time.Second,
		}

		log.Printf("Starting server: %q", fmt.Sprintf("%s:%d", sr.listener.IP, sr.listener.Port))
		return httpServer.ListenAndServe()
	}

	wg.Wait()

	return nil
}

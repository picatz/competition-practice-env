package main

import (
	"fmt"
	"log"
	"net"
	"time"

	// Imports the Stackdriver Logging client package.
	"cloud.google.com/go/logging"
	"golang.org/x/net/context"
	"google.golang.org/api/option"
)

type scoringEntry struct {
	Service string
	Points  int
	Team    string
	Err     error
}

func scoreHTTP(logger *logging.Logger, team, ip string) {
	conn, err := net.DialTimeout("tcp", fmt.Sprintf("%s:80", ip), 3*time.Second)
	if err != nil {
		logger.Log(logging.Entry{Payload: scoringEntry{Service: "http", Team: team, Points: 0, Err: err}})
		return
	}
	defer conn.Close()
	logger.Log(logging.Entry{Payload: scoringEntry{Service: "http", Team: team, Points: 1}})
}

func scoreES(logger *logging.Logger, team, ip string) {
	conn, err := net.DialTimeout("tcp", fmt.Sprintf("%s:9200", ip), 3*time.Second)
	if err != nil {
		logger.Log(logging.Entry{Payload: scoringEntry{Service: "es", Team: team, Points: 0, Err: err}})
		return
	}
	defer conn.Close()
	logger.Log(logging.Entry{Payload: scoringEntry{Service: "es", Team: team, Points: 1}})
}

func scoreSSH(logger *logging.Logger, team, ip string) {
	conn, err := net.DialTimeout("tcp", fmt.Sprintf("%s:22", ip), 3*time.Second)
	if err != nil {
		logger.Log(logging.Entry{Payload: scoringEntry{Service: "ssh", Team: team, Points: 0, Err: err}})
		return
	}
	defer conn.Close()
	logger.Log(logging.Entry{Payload: scoringEntry{Service: "ssh", Team: team, Points: 1}})
}

func scoreMySQL(logger *logging.Logger, team, ip string) {
	conn, err := net.DialTimeout("tcp", fmt.Sprintf("%s:3306", ip), 3*time.Second)
	if err != nil {
		logger.Log(logging.Entry{Payload: scoringEntry{Service: "mysql", Team: team, Points: 0, Err: err}})
		return
	}
	defer conn.Close()
	logger.Log(logging.Entry{Payload: scoringEntry{Service: "mysql", Team: team, Points: 1}})
}

func scoreFTP(logger *logging.Logger, team, ip string) {
	conn, err := net.DialTimeout("tcp", fmt.Sprintf("%s:21", ip), 3*time.Second)
	if err != nil {
		logger.Log(logging.Entry{Payload: scoringEntry{Service: "ftp", Team: team, Points: 0, Err: err}})
		return
	}
	defer conn.Close()
	logger.Log(logging.Entry{Payload: scoringEntry{Service: "ftp", Team: team, Points: 1}})
}

func scoreMsSQL(logger *logging.Logger, team, ip string) {
	conn, err := net.DialTimeout("tcp", fmt.Sprintf("%s:1433", ip), 3*time.Second)
	if err != nil {
		logger.Log(logging.Entry{Payload: scoringEntry{Service: "mssql", Team: team, Points: 0, Err: err}})
		return
	}
	defer conn.Close()
	logger.Log(logging.Entry{Payload: scoringEntry{Service: "mssql", Team: team, Points: 1}})
}

func scoreLDAP(logger *logging.Logger, team, ip string) {
	conn, err := net.DialTimeout("tcp", fmt.Sprintf("%s:389", ip), 3*time.Second)
	if err != nil {
		logger.Log(logging.Entry{Payload: scoringEntry{Service: "ldap", Team: team, Points: 0, Err: err}})
		return
	}
	defer conn.Close()
	logger.Log(logging.Entry{Payload: scoringEntry{Service: "ldap", Team: team, Points: 1}})
}

func main() {
	ctx := context.Background()
	// Sets your Google Cloud Platform project ID.
	projectID := "iasa-scoring-engine"
	// Creates a client.
	client, err := logging.NewClient(ctx, projectID, option.WithCredentialsFile("account.json"))
	if err != nil {
		log.Fatalf("Failed to create client: %v", err)
	}
	defer client.Close()
	// Sets the name of the log to write to.
	logName := "friday-feb-1-2019"
	logger := client.Logger(logName)

	checks := map[string]map[string]string{
		"team1": map[string]string{
			// ubuntu
			"http": "192.168.1.2",
			// ubuntu2
			"ssh": "192.168.1.5",
			"es":  "192.168.1.5",
			// centos
			"ftp": "192.168.1.3",
			// centos2
			"mysql": "192.168.1.6",
			// windows
			"mssql": "192.168.1.4",
			"ldap":  "192.168.1.4",
		},
		"team2": map[string]string{
			// ubuntu
			"http": "192.168.2.2",
			// ubuntu2
			"ssh": "192.168.2.5",
			"es":  "192.168.2.5",
			// centos
			"ftp": "192.168.2.3",
			// centos2
			"mysql": "192.168.2.6",
			// windows
			"mssql": "192.168.2.4",
			"ldap":  "192.168.2.4",
		},
	}

	// main scoring logic
	for {
		for team, services := range checks {
			for service, ip := range services {
				switch service {
				case "http":
					go scoreHTTP(logger, team, ip)
				case "ssh":
					go scoreSSH(logger, team, ip)
				case "ftp":
					go scoreFTP(logger, team, ip)
				case "mysql":
					go scoreMySQL(logger, team, ip)
				case "mssql":
					go scoreMsSQL(logger, team, ip)
				case "ldap":
					go scoreLDAP(logger, team, ip)
				}
			}
		}
		time.Sleep(20 * time.Second)
	}
}

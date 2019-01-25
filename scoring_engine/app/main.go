package main

import (
	"fmt"
	"log"
	"net"
	"net/http"
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

func scoreHTTP(logger *logging.Logger, team, url string) {
	resp, err := http.Get(url)
	if err != nil {
		logger.Log(logging.Entry{Payload: scoringEntry{Service: "http", Team: team, Points: 0, Err: err}})
		return
	}
	defer resp.Body.Close()
	logger.Log(logging.Entry{Payload: scoringEntry{Service: "http", Team: team, Points: 1}})
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

func scoreRDP(logger *logging.Logger, team, ip string) {
	conn, err := net.DialTimeout("tcp", fmt.Sprintf("%s:3389", ip), 3*time.Second)
	if err != nil {
		logger.Log(logging.Entry{Payload: scoringEntry{Service: "rdp", Team: team, Points: 0, Err: err}})
		return
	}
	defer conn.Close()
	logger.Log(logging.Entry{Payload: scoringEntry{Service: "rdp", Team: team, Points: 1}})
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
	logName := "my-log-3"
	logger := client.Logger(logName)

	checks := map[string]map[string]string{
		"team1": map[string]string{
			"http": "https://www.google.com",
		},
		"team2": map[string]string{
			"http": "https://www.google.com",
		},
	}

	// main scoring logic
	for {
		for team, services := range checks {
			for service, uri := range services {
				switch service {
				case "http":
					scoreHTTP(logger, team, uri)
				case "ssh":
					fmt.Println("not implemented")
				}
			}
		}
		time.Sleep(5 * time.Second)
	}
}

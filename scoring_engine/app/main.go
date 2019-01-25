package main

import (
	"log"
	"net/http"

	// Imports the Stackdriver Logging client package.
	"cloud.google.com/go/logging"
	"golang.org/x/net/context"
	"google.golang.org/api/option"
)

type httpEntry struct {
	Up   bool
	Team string
	Err  error
}

func scorHTTP(logger *logging.Logger, services map[string]string) {
	for team, url := range services {
		resp, err := http.Get(url)
		if err != nil {
			logger.Log(logging.Entry{Payload: httpEntry{Team: team, Up: false, Err: err}})
			continue
		}
		defer resp.Body.Close()
		logger.Log(logging.Entry{Payload: httpEntry{Team: team, Up: true}})
	}
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
	logName := "my-log-2"
	logger := client.Logger(logName)
	services := map[string]string{"team1": "https://www.google.com", "team2": "https://www.google.com"}
	scorHTTP(logger, services)
}

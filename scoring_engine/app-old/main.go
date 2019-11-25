package main

import (
	"flag"
	"fmt"
	"log"
	"os"
)

var (
	configPathFlag  string
	serviceRegistry *ServiceRegistry
)

func init() {
	flag.StringVar(&configPathFlag, "config", "", "Path to config for scoring engine")
	flag.Parse()

	if configPathFlag == "" {
		fmt.Println("No -config given!")
		os.Exit(1)
	}

	var err error

	serviceRegistry, err = LoadServiceRegistryConfig(configPathFlag)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func main() {
	log.Fatal(serviceRegistry.Start())
}

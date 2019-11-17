#!/bin/bash

# Check if the gcloud command-line tool is installed
if ! command -v gcloud; then
    echo "Install the Google Cloud SDK before using this script:"
    echo "https://cloud.google.com/sdk/"
    exit 1
fi

# The emich.edu organization in google cloud
EMICH_ORG_ID="943027493068"

# Check if a project name was given at the command-line as the first argument
if [ $# -eq 0 ];then
    echo "No project name given"
fi

# Create project from the given name
gcloud projects create "$1" --organization="$EMICH_ORG_ID"
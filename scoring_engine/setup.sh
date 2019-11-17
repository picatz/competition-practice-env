#!/bin/bash

# Check if the gcloud command-line tool is installed
if ! command -v gcloud; then
    echo "Install the Google Cloud SDK before using this script:"
    echo "https://cloud.google.com/sdk/"
    exit 1
fi

# Check if a project name was given at the command-line as the first argument
if [ $# -eq 0 ];then
    echo "No project name given"
    exit 1
fi

# Set gcloud config to use the given project
gcloud config set project "$1"

# Enable the compute engine API
gcloud services enable compute.googleapis.com

# Create the service account with account.json file if it doesn't exist
gcloud iam service-accounts create terraform \
    --display-name "Terraform Service Account" \
    --description "Service account to use with Terraform"

gcloud projects add-iam-policy-binding "$1" \
  --member serviceAccount:"terraform@$1.iam.gserviceaccount.com" \
  --role roles/editor

gcloud iam service-accounts keys create account.json \
    --iam-account "terraform@$1.iam.gserviceaccount.com"


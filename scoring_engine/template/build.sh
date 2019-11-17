if gcloud compute images list | grep -q "engine"; then
    exit 0
fi

packer build -var "project=$1" template.json
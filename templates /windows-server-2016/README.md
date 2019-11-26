# Packer Template for Custom Windows Server 2016

Requires the [`gcloud`](https://cloud.google.com/sdk/) command-line tool to be installed and authenticated.

```console
$ gcloud config set project $GCLOUD_PROJECT_NAME
...
```

```console
$ gcloud compute firewall-rules create allow-winrm --allow tcp:5986
...
```

```console
$ packer build -var 'admin_password=D2hedmnTm=Sa?6?' -var 'gcp_project=$GCLOUD_PROJECT_NAME' template.json
...
```

```console
$ gcloud compute firewall-rules delete allow-winrm
...
```

```console
$ gcloud compute images delete custom-windows-2016-server
...
```
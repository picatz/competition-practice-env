# Ubuntu Server

This is an example packer template to build a GCP compute image using ubuntu 18.04lts with a stackdriver logging agent pre-installed.

> **Note** `wall` has been removed to prevent abuse, since people just can't resist the temptation.

## Build Image

```console
$ packer build template.json
...
==> Builds finished. The artifacts of successful builds are:
--> googlecompute: A disk image was created: ubuntu-server
```

## Delete Image

You'll need to do this for both teams (`iasa-team-0001`, `iasa-team-0010`).

```console
$ gcloud config set project iasa-team-0001
$ gcloud compute images delete ubuntu-server
The following images will be deleted:
 - [ubuntu-server]

Do you want to continue (Y/n)?  Y

Deleted [https://www.googleapis.com/compute/v1/projects/iasa-team-0001/global/images/ubuntu-server].
```

```console
$ gcloud config set project iasa-team-0010 
$ gcloud compute images delete ubuntu-server
The following images will be deleted:
 - [ubuntu-server]

Do you want to continue (Y/n)?  Y

Deleted [https://www.googleapis.com/compute/v1/projects/iasa-team-0010/global/images/ubuntu-server].
```
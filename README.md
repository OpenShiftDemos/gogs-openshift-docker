# Gogs for OpenShift
Gogs is the Go Git service. Learn more about it at https://gogs.io/

Running containers on OpenShift comes with certain security and other
requirements. This repository contains:

* A Dockerfile for building an OpenShift-compatible Gogs image
* Various scripts used in the Docker image
* OpenShift templates for deploying the image
* Usage instructions

## Prerequisites
* An account in an OpenShift 3.2+ environment and a project

* Gogs requires a database to store its information. Provisioning a database is
  out-of-scope for this repository. If you wish to run the database on
  OpenShift, it is suggested that you deploy PostgreSQL using persistent
  storage. More information on the OpenShift PostgreSQL deployment is here:

  https://docs.openshift.org/latest/using_images/db_images/postgresql.html

## Deployment
Gogs can be easily deployed using the included templates in `openshift` folder.
If your have persistent volumes available in your cluster:

```
oc new-app -f https://raw.githubusercontent.com/OpenShiftDemos/gogs-openshift-docker/master/openshift/gogs-persistent-template.yaml --param=HOSTNAME=gogs-demo.yourdomain.com
```
Otherwise:
```
oc new-app -f https://raw.githubusercontent.com/OpenShiftDemos/gogs-openshift-docker/master/openshift/gogs-template.yaml --param=HOSTNAME=gogs-demo.yourdomain.com
```

Note that hostname is required during Gogs installation in order to configure repository urls correctly.

## ToDos
* git via ssh support

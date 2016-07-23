# Gogs for OpenShift
Gogs is the Go Git service. Learn more about it at https://gogs.io/

Running containers on OpenShift comes with certain security and other
requirements. This repository contains:

* A Dockerfile for building an OpenShift-compatible Gogs image
* Various scripts used in the Docker image
* An OpenShift template for deploying the image
* Usage instructions

## Prerequisites
* An account in an OpenShift 3.2+ environment and a project

* Gogs requires a database to store its information. Provisioning a database is
  out-of-scope for this repository. If you wish to run the database on
  OpenShift, it is suggested that you deploy PostgreSQL using persistent
  storage. More information on the OpenShift PostgreSQL deployment is here:

  https://docs.openshift.org/latest/using_images/db_images/postgresql.html

## Initial deployment
Gogs can be easily deployed using the included template:

    oc process -f gogs.yaml | oc create -f -

If you wish to change the route URL or change the name of the application
components, you can do so:

    oc process -f gogs.yaml -v APPLICATION_NAME=foo,HOSTNAME_HTTP=www.bar.baz \
    | oc create -f

HTTPS is currently unsupported. Pull requests welcome.

Once Gogs is running, continue to Initial Setup

## Initial setup
The template creates a route by default. Given the project name `gogs` and the
default template, that might look something like:

    http://gogs-gogs.apps.yourdomain.com

Visit this URL and you will be greeted with the initial setup / installation
page for Gogs. Follow the instructions. The installation process will also set
up the necessary tables in the database.

Some notes:

* If your database is hosted on OpenShift and in the same project, you can
  simply use the service's name as the database host. For example, if your
  database service is called `postgresql` then the database host line can just
  be `postgresql:5432`.

* The value of "Application URL" is the FQDN of your route, with context, if
  relevant. Using the example above, our "Application URL" is
  `http://gogs-gogs.apps.yourdomain.com`.

* Be sure to set an administration user, or the first user to register will
  automatically become an administrator.

## ConfigMap
After the initial installation, Gogs has created a file on the local container
filesystem `/etc/gogs/conf/app.ini`. Unfortunately, this config file will not be
persisted if the container restarts.

It is a "waste" to use an entire persistent volume for a ~12KiB file, so,
instead we will use a
[ConfigMap](https://docs.openshift.org/latest/dev_guide/configmaps.html).

First, find the name of the deployed pod using the `oc` tool, or the web
console:

    oc get pod
    NAME                 READY     STATUS    RESTARTS   AGE
    gogs-1-h1vfn         1/1       Running   0          5m
    postgresql-1-fznew   1/1       Running   0          2m

You can use `oc exec` to execute a command inside the container. In this case,
we will use it to cat out the contents of the Gogs config file and place them
into a ConfigMap:

    oc create configmap gogs --from-file=appini=<(oc exec gogs-1-h1vfn -- \
    cat /etc/gogs/conf/app.ini)

## Volume Mount
We can use the data stored in the ConfigMap as a volume and actually mount it
into our running container's filesystem. The following command will update the
deployment definition for Gogs to add the volume definition and volume mount:

    oc volume dc/gogs --add --overwrite --name=config-volume -m /etc/gogs/conf/ \
    --source='{"configMap":{"name":"gogs","items":[{"key":"appini","path":"app.ini"}]}}'

Note that this will trigger a new deployment of the Gogs pod(s). It assumes that
you did not change the name of the application in the initial template process
step. If you *did* change the name of the application, make sure you substitute
`dc/gogs` for the appropriate name of your deployment.

## Persistent Storage for Repositories
Gogs stores the actual git repository data on the filesystem inside the
container. This, too, requires some more work so that data is persisted across
container restarts.

Configuration of persistent volumes and claims is outside of scope of this
readme, but more documentation on it can be found
[here](https://docs.openshift.org/latest/dev_guide/persistent_volumes.html).

Some sample claim/volume definitions are in this repository. Once your volume
and claim exist, you could do something like the following:

    oc volume dc/gogs --add --overwrite -t persistentVolumeClaim \
    --claim-name gogs-pvc -m /home/gogs/gogs-repositories --name repos

As Gogs only currently supports writing to a local filesystem, horizontal
scaling of the Gogs server may prove difficult.


## Shortcut Instructions

gogs (create your admin in ui)

    oc project gogs
    oc new-app -f https://raw.githubusercontent.com/eformat/gogs-openshift-docker/master/gogs-persistent.yaml

get POSTGRES USER PASSWORD

    oc exec $(oc get pods | grep postgres | awk '{print $1}') env | grep POSTGRES

login to gogs url, setup:

* postgres settings

    postgresql:5432
    POSTGRESQL_USER=gogs
    POSTGRESQL_PASSWORD=<password>
    POSTGRESQL_DATABASE=gogs
    

* gogs settings

    application url: http://gogs-gogs.192.168.137.2.xip.io
    repos: /var/tmp
    setup an admin user / pwd (you)


once started, set configmap with admin setup

    oc project gogs
    oc create configmap gogs --from-file=appini=<(oc exec $(oc get pods | grep gogs | awk '{print $1}') -- cat /etc/gogs/conf/app.ini)
    oc volume dc/gogs --add --overwrite --name=config-volume -m /etc/gogs/conf/ \
      --source='{"configMap":{"name":"gogs","items":[{"key":"appini","path":"app.ini"}]}}'

## ToDos
* add liveness/readiness probe(s)
* complete template with persistent postgresql - DONE
* git via ssh support

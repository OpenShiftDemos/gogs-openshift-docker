OpenShift Gogs Templates
===
Note that Gogs route url is required to be provided as a paramter to the template since Gogs needs this url for self-configuration.

Use a version of Gogs available on Docker Hub or just ```latest```:
https://hub.docker.com/r/openshiftdemos/gogs/tags/

### Using persistent volumes

```
$ oc process \
        -f http://bit.ly/openshift-gogs-persistent-template \
        --param=HOSTNAME=your-gogs-hostname \
        --param=GOGS_VERSION=0.11.4 \
        | oc create -f -
```

### Without persistent volumes (ephemeral)

```
$ oc process \
        -f http://bit.ly/openshift-gogs-template \
        --param=HOSTNAME=your-gogs-hostname \
        --param=GOGS_VERSION=0.11.4 \
        | oc create -f -
```
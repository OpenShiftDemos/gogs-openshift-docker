oc new-app wkulhanek/gogs:11.4 -lapp=gogs --name=gogs
oc set volume dc/gogs --add  --overwrite --name=gogs-volume-1 --mount-path=/home/gogs/gogs-repositories/ --type persistentVolumeClaim --claim-name=gogs-pvc
oc expose svc gogs

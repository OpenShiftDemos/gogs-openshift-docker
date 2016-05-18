FROM centos:7
MAINTAINER Erik Jacobs <erikmjacobs@gmail.com>
ADD gogs /root/gogs
RUN rpm --import /root/gogs/key && yum -y localinstall /root/gogs/gogs*.rpm
EXPOSE 3000
CMD ["/usr/bin/gogs", "run", "web"]

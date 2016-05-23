FROM centos:7
MAINTAINER Erik Jacobs <erikmjacobs@gmail.com>

ENV HOME=/var/lib/gogs
ADD root /
RUN rpm --import https://rpm.packager.io/key && \
    yum -y install epel-release && \
    yum -y --setopt=tsflags=nodocs install gogs nss_wrapper gettext && \
    yum -y clean all && \
    mkdir -p /var/lib/gogs
RUN /usr/bin/fix-permissions /var/lib/gogs && \
    /usr/bin/fix-permissions /home/gogs && \
    /usr/bin/fix-permissions /opt/gogs && \
    /usr/bin/fix-permissions /etc/gogs && \
    /usr/bin/fix-permissions /var/log/gogs
EXPOSE 3000
USER 997
CMD ["/usr/bin/rungogs"]

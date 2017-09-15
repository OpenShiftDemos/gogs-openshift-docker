FROM centos:7

MAINTAINER Siamak Sadeghianfar <siamaksade@gmail.com>

ARG GOGS_VERSION="0.11.29"

LABEL name="Gogs - Go Git Service" \
      vendor="Gogs" \
      io.k8s.display-name="Gogs - Go Git Service" \
      io.k8s.description="Easiest, fastest, and most painless way of setting up a self-hosted Git service." \
      summary="Easiest, fastest, and most painless way of setting up a self-hosted Git service." \
      io.openshift.expose-services="3000,gogs" \
      io.openshift.tags="gogs" \
      version="${GOGS_VERSION}" \
      release="1"

ENV HOME=/var/lib/gogs

COPY ./root /

RUN rpm --import https://rpm.packager.io/key && \
    yum -y install epel-release && \
    yum -y install git nss_wrapper gettext && \
    yum -y clean all && \
    cd /opt && \
    curl -o linux_amd64.tar.gz -L https://cdn.gogs.io/${GOGS_VERSION}/linux_amd64.tar.gz && \
    tar xvfz linux_amd64.tar.gz && \
    rm -rf linux_amd64.tar.gz && \
    mkdir -p /var/lib/gogs && \
    mkdir -p /home/gogs && \
    useradd -r gogs

RUN /usr/bin/fix-permissions /var/lib/gogs && \
    /usr/bin/fix-permissions /home/gogs && \
    /usr/bin/fix-permissions /opt/gogs

EXPOSE 3000
USER 997

CMD ["/usr/bin/rungogs"]

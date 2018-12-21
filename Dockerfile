FROM centos:7
MAINTAINER karel.bemelmans@unibet.com

RUN set -x \
  && yum update -y \
  && yum install -y epel-release \
  && yum install -y \
    device-mapper-libs \
    git \
    java-1.8.0-openjdk \
    python2-pip \
    subversion \
    unzip \
    jq \
  && pip install awscli

# Add go user and group
RUN groupadd -g 500 go \
  && useradd -u 500 -g 500 -d /var/lib/go-agent --no-create-home -s /bin/bash -G go go

# Install GoCD Agent from zip file
ARG GO_MAJOR_VERSION=18.12.0
ARG GO_BUILD_VERSION=8222
ARG GO_VERSION="${GO_MAJOR_VERSION}-${GO_BUILD_VERSION}"
ARG GOCD_SHA256=f51c6bc6e5ebeb9fe9777017971be9d412437732669597a93160f3f7bf2d0017

RUN curl -L --silent https://download.gocd.org/binaries/${GO_VERSION}/generic/go-agent-${GO_VERSION}.zip \
       -o /tmp/go-agent.zip \
  && echo "${GOCD_SHA256}  /tmp/go-agent.zip" | sha256sum -c - \
  && unzip /tmp/go-agent.zip -d /usr/local \
  && ln -s /usr/local/go-agent-${GO_MAJOR_VERSION} /usr/local/go-agent \
  && chown -R go:go /usr/local/go-agent-${GO_MAJOR_VERSION} \
  && rm /tmp/go-agent.zip

RUN mkdir -p /etc/default \
  && cp /usr/local/go-agent-${GO_MAJOR_VERSION}/go-agent.default /etc/default/go-agent \
  && chown go:go /etc/default /etc/default/go-agent \
  && sed -i -e "s|DAEMON=Y|DAEMON=N|" /etc/default/go-agent

RUN mkdir /etc/go && chown go:go /etc/go \
  && mkdir -p /var/lib/go-agent/config && chown -R go:go /var/lib/go-agent \
  && mkdir /var/log/go-agent && chown go:go /var/log/go-agent

# Copy log config
COPY config/*.xml /var/lib/go-agent/config/

# add the entrypoint config and run it when we start the container
COPY ./docker-entrypoint.sh /
RUN chmod 500 /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

FROM amazonlinux:latest
MAINTAINER karel.bemelmans@unibet.com

RUN set -x \
  && yum update -y \
  && yum install -y \
    device-mapper-libs \
    git \
    java-1.7.0-openjdk \
    subversion \
    unzip

# Add go user and group
RUN groupadd -g 500 go \
  && useradd -u 500 -g 500 -d /var/lib/go-agent --no-create-home -s /bin/bash -G go go

# Install GoCD Server from zip file
ARG GO_MAJOR_VERSION=16.12.0
ARG GO_BUILD_VERSION=4352
ARG GO_VERSION="${GO_MAJOR_VERSION}-${GO_BUILD_VERSION}"
ARG GOCD_SHA256=c9a204d63987ebd7819f6b04a93ca79d1b2a8969cddb6e86444d92f7ab657747

RUN curl -L --silent https://download.gocd.io/binaries/${GO_VERSION}/generic/go-agent-${GO_VERSION}.zip \
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
  && mkdir /var/lib/go-agent && chown go:go /var/lib/go-agent \
  && mkdir /var/log/go-agent && chown go:go /var/log/go-agent

# add the entrypoint config and run it when we start the container
COPY ./docker-entrypoint.sh /
RUN chmod 500 /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

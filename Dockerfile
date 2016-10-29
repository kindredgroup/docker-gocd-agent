FROM unibet/alpine-jre:7
MAINTAINER karel.bemelmans@unibet.com

# Install more apk packages we might need
RUN apk --update add \
  bash \
  curl \
  git \
  subversion

# Add go user and group
RUN addgroup -g 1000 go && adduser -u 1000 -h /var/lib/go-server -H -S -G go go

# Install GoCD Server from zip file
ARG GO_MAJOR_VERSION=16.11.0
ARG GO_BUILD_VERSION=4185
ARG GO_VERSION="${GO_MAJOR_VERSION}-${GO_BUILD_VERSION}"
ARG GOCD_SHA256=2d1d750be75340a6e87058be91c8a0af2187985bef916d4901b03e06875d5bd1

RUN curl -L --silent https://download.go.cd/binaries/${GO_VERSION}/generic/go-agent-${GO_VERSION}.zip \
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
RUN chown go:go /docker-entrypoint.sh && chmod 500 /docker-entrypoint.sh

USER go
ENTRYPOINT ["/docker-entrypoint.sh"]

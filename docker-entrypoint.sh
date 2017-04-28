#!/bin/bash -e

# if docker is mounted in this agent make sure to create docker user
if [ -n "$DOCKER_GID_ON_HOST" ] && [ ! "$DOCKER_GID_ON_HOST" == 500 ]; then
  echo "Setting docker user gid to same as host..."
  groupadd -g $DOCKER_GID_ON_HOST docker
  usermod -a -G docker go
fi

# autoregister agent with server
if [ -n "$AGENT_KEY" ]
then
  mkdir -p /var/lib/go-agent/config
  echo "agent.auto.register.key=$AGENT_KEY" > /var/lib/go-agent/config/autoregister.properties

  if [ -n "$AGENT_RESOURCES" ]; then
    echo "agent.auto.register.resources=$AGENT_RESOURCES" >> /var/lib/go-agent/config/autoregister.properties
  fi
  if [ -n "$AGENT_ENVIRONMENTS" ]; then
    echo "agent.auto.register.environments=$AGENT_ENVIRONMENTS" >> /var/lib/go-agent/config/autoregister.properties
  fi
  if [ -n "$AGENT_HOSTNAME" ]; then
    echo "agent.auto.register.hostname=$AGENT_HOSTNAME" >> /var/lib/go-agent/config/autoregister.properties
  fi
fi

# copy logging config
test -d /var/lib/go-agent/config || mkdir -p /var/lib/go-agent/config
cp /usr/local/go-agent/config/*.properties /var/lib/go-agent/config

# log to std out instead of file
cat >/var/lib/go-agent/log4j.properties <<EOL
log4j.rootCategory=INFO, ConsoleAppender

log4j.logger.net.sourceforge.cruisecontrol=INFO
log4j.logger.com.thoughtworks.go=INFO
log4j.logger.org.springframework.context.support=INFO
log4j.logger.httpclient.wire=INFO

# console output...
log4j.appender.ConsoleAppender=org.apache.log4j.RollingFileAppender
log4j.appender.ConsoleAppender.layout=org.apache.log4j.PatternLayout
log4j.appender.ConsoleAppender.layout.ConversionPattern=%d{ISO8601} [%-9t] %-5p %-16c{4}:%L %x- %m%n
EOL

# update config to point to correct go.cd server hostname and port
GO_SERVER_URL=${GO_SERVER_URL:-"https://127.0.0.1:8154/go"}
sed -i -e "s|^GO_SERVER_URL=.*|GO_SERVER_URL=${GO_SERVER_URL}|" /etc/default/go-agent

# wait for server to be available
until curl -Lks -o /dev/null "${GO_SERVER_URL}"
do
  sleep 5
  echo "Waiting for ${GO_SERVER_URL}"
done

# We have to run as user go here.
chown -R go:go /var/lib/go-agent

echo "Starting go.cd agent..."
/bin/su - go -c "GO_SERVER_URL=$GO_SERVER_URL AGENT_BOOTSTRAPPER_ARGS=\"$AGENT_BOOTSTRAPPER_ARGS\" AGENT_MEM=$AGENT_MEM AGENT_MAX_MEM=$AGENT_MAX_MEM /usr/local/go-agent/agent.sh"

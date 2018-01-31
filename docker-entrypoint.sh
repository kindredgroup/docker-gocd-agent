#!/bin/bash -e

STARTUP_TIMEOUT=${STARTUP_TIMEOUT:-"3600"}

export AGENT_WORK_DIR=/var/lib/go-agent

# if docker is mounted in this agent make sure to create docker user
if [ -n "$DOCKER_GID_ON_HOST" ] && [ ! "$DOCKER_GID_ON_HOST" == 500 ]; then
  echo "Setting docker user gid to same as host..."
  groupadd -g $DOCKER_GID_ON_HOST docker
  usermod -a -G docker go
fi

# autoregister agent with server
if [ -n "$AGENT_KEY" ]
then
  mkdir -p $AGENT_WORK_DIR/config
  echo "agent.auto.register.key=$AGENT_KEY" > $AGENT_WORK_DIR/config/autoregister.properties

  if [ -n "$AGENT_RESOURCES" ]; then
    echo "agent.auto.register.resources=$AGENT_RESOURCES" >> $AGENT_WORK_DIR/config/autoregister.properties
  fi
  if [ -n "$AGENT_ENVIRONMENTS" ]; then
    echo "agent.auto.register.environments=$AGENT_ENVIRONMENTS" >> $AGENT_WORK_DIR/config/autoregister.properties
  fi
  if [ -n "$AGENT_HOSTNAME" ]; then
    echo "agent.auto.register.hostname=$AGENT_HOSTNAME" >> $AGENT_WORK_DIR/config/autoregister.properties
  fi
fi

# update config to point to correct go.cd server hostname and port
GO_SERVER_URL=${GO_SERVER_URL:-"https://127.0.0.1:8154/go"}
sed -i -e "s|^GO_SERVER_URL=.*|GO_SERVER_URL=${GO_SERVER_URL}|" /etc/default/go-agent

# wait for server to be available
SLEEP_INTERVAL=5
TOTAL_SLEEP=0
until curl -Lks -o /dev/null "${GO_SERVER_URL}"
do
  if (( TOTAL_SLEEP > STARTUP_TIMEOUT )); then
    echo "Timeout reached for GoCD Master URL to be available" >&1
    exit 1
  fi
  sleep $SLEEP_INTERVAL
  echo "Waiting ${SLEEP_INTERVAL}s for ${GO_SERVER_URL}"
  TOTAL_SLEEP=$((TOTAL_SLEEP+SLEEP_INTERVAL))
done

# We have to run as user go here.
chown -R go:go /var/lib/go-agent

export GO_AGENT_SYSTEM_PROPERTIES="${GO_AGENT_SYSTEM_PROPERTIES}${GO_AGENT_SYSTEM_PROPERTIES:+ }-Dgo.console.stdout=true"
export AGENT_BOOTSTRAPPER_JVM_ARGS="${AGENT_BOOTSTRAPPER_JVM_ARGS}${AGENT_BOOTSTRAPPER_JVM_ARGS:+ }-Dgo.console.stdout=true"

# Health endpoint listen on IP so that it can be checked by Kubernetes, ASG, what have you..
export GO_AGENT_SYSTEM_PROPERTIES="${GO_AGENT_SYSTEM_PROPERTIES}${GO_AGENT_SYSTEM_PROPERTIES:+ }-Dgo.agent.status.api.bind.host=0.0.0.0"

echo "Starting go.cd agent..."
/bin/su - go -c "AGENT_WORK_DIR=$AGENT_WORK_DIR GO_AGENT_SYSTEM_PROPERTIES=\"$GO_AGENT_SYSTEM_PROPERTIES\" AGENT_BOOTSTRAPPER_JVM_ARGS=\"$AGENT_BOOTSTRAPPER_JVM_ARGS\" GO_SERVER_URL=$GO_SERVER_URL AGENT_BOOTSTRAPPER_ARGS=\"$AGENT_BOOTSTRAPPER_ARGS\" AGENT_MEM=$AGENT_MEM AGENT_MAX_MEM=$AGENT_MAX_MEM /usr/local/go-agent/agent.sh"

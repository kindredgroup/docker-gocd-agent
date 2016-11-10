# Alpine Linux GoCD Server Docker image

This agent is designed to run as a stateless agent, do not use mounted volumes.

```
docker run -t  \
  -e "GO_SERVER_URL=https://localhost:8154/go" \
  -e "AGENT_KEY=secretkey" \
  -e "AGENT_RESOURCES=docker" \
  -e "AGENT_ENVIRONMENTS=Production" \
  -e "AGENT_HOSTNAME=deploy-agent-01" \
  -d unibet/gocd-agent
```

Also check the [GoCD Server repository](https://github.com/unibet/docker-gocd-server).

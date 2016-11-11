# Alpine Linux GoCD Server Docker image

This agent is designed to run as a stateless agent, do not use mounted volumes.

```
docker run -t  \
  -e "GO_SERVER_URL=https://localhost:8154/go" \
  -e "AGENT_KEY=secretkey" \
  -e "AGENT_RESOURCES=docker" \
  -e "AGENT_ENVIRONMENTS=Production" \
  -e "AGENT_HOSTNAME=deploy-agent-01" \
  -e "DOCKER_GID_ON_HOST=496" \
  -d unibet/gocd-agent
```

Also check the [GoCD Server repository](https://github.com/unibet/docker-gocd-server).

## Automated build and push to Docker hub

Since this image uses the base Amazon Linux image from ECR, it's not possible to have an automated build by simply linking it to Docker Hub. ECR requires a login before pulling, so we push this repository from our internal Go build server to Docker Hub.

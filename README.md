# Amazon Linux GoCD Agent Docker image

This GoCD Agent is a docker image built on top of Amazon Linux. We run this on AWS EC2 and having the container also run Amazon Linux saves us some work of getting docker-in-docker to work. If the OS distribution of the host and container match, mounting the Docker binary and socket _should_ be enough.

## Example usage

This agent is designed to run as a stateless agent, do not use mounted volumes.

```
docker run -t  \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /usr/bin/docker:/usr/bin/docker \
  -e "GO_SERVER_URL=https://localhost:8154/go" \
  -e "AGENT_KEY=secretkey" \
  -e "AGENT_RESOURCES=docker" \
  -e "AGENT_ENVIRONMENTS=Production" \
  -e "AGENT_HOSTNAME=deploy-agent-01" \
  -e "DOCKER_GID_ON_HOST=496" \
  -d unibet/gocd-agent
```

Also check the [GoCD Server repository](https://github.com/unibet/docker-gocd-server).

## Maintenance status

Actively maintained.

Status updated: 11/11/2016


## LICENSE

The MIT License (MIT)

Copyright (c) 2016 Unibet Group

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

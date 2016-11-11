#!/bin/bash -xe
#
# Environment variables needed:
#
# - DOCKER_HUB_USERNAME
# - DOCKER_HUB_PASSWORD

ECR_IMAGE_NAME="unibet/gocd-agent"
ECR_IMAGE_TAG="16.11.0"

# Login to ECR and pull the latest version of the base image
$(aws ecr get-login --region us-west-2 --registry-ids 137112412989)
docker pull 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest

# 1. Build the production container.
docker build -t ${ECR_IMAGE_NAME}:${ECR_IMAGE_TAG} .

# 2. Push it to Docker Hub
docker login --username ${DOCKER_HUB_USERNAME} --password ${DOCKER_HUB_PASSWORD}
docker push ${ECR_IMAGE_NAME}:${ECR_IMAGE_TAG}
docker push ${ECR_IMAGE_NAME}:latest

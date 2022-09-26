REGISTRY=quay.io
ORG=tonyskapunk
IMAGE_NAME=httpok
TAG=latest

podman build . \
  --file Containerfile \
  --tag ${REGISTRY}/${ORG}/$IMAGE_NAME:${TAG}

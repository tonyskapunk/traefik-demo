#!/bin/bash

BE_NUM=5
PORT=8080

# Start pod
echo === Start pod
podman pod create \
  --name demo \
  -p 8080:80 \
  -p 8888:8080 \


# Start test http servers
echo
echo === Start test http servers
echo "Press enter to continue..."
read

for n in $(seq ${BE_NUM}); do
    cont_port=$(( ${PORT} + ${n} ))
    podman run \
      --detach \
      --rm \
      --name be-${n} \
      --pod demo \
      --env UID=be-${n} \
      --env PORT=${cont_port} \
      quay.io/tonyskapunk/httpok:latest
done

# Traefik
echo
echo === Start Traefik
echo "Press enter to continue..."
read

podman run \
  --detach \
  --rm \
  --name traefik \
  --pod demo \
  -v ${PWD}/conf:/etc/traefik:Z \
  docker.io/library/traefik:latest


echo
echo === Test Traefik
echo "Press enter to continue..."
read

curl -I localhost:8888/ping
curl -I localhost:8888/dashboard

echo
echo === Test individual routes
echo "Press enter to continue..."
read

for n in $(seq ${BE_NUM}); do
    echo = ${n}
    curl -I localhost:8080/app -H "cluster: ${n}"
done

echo
echo === Test BEs through proxy
echo "Press enter to continue..."
read

for n in $(seq 100); do
    curl -s -I localhost:8080/app | grep X-Uid
done


# Teardown
echo
echo === Teardown
echo "Press enter to teardown..."
read

podman pod stop demo
podman pod rm demo

## Debug:
# podman run --rm -it --name net --pod demo -e HTTP_PORT=1180 -e HTTPS_PORT=11443 praqma/network-multitool

#!/bin/bash

CONTAINER_NAME="mc-local-test"
DATA_DIR="./test"

# 1. Stop and remove existing test container if it exists
echo "Cleaning up old container..."
podman rm -f $CONTAINER_NAME 2>/dev/null

# 2. Fix permissions and SELinux labels for the current user
# This ensures IntelliJ and Podman stay in sync
echo "Syncing permissions for $(whoami)..."
sudo chown -R $USER:$USER $DATA_DIR
chmod -R 775 $DATA_DIR
chcon -R -t container_file_t $DATA_DIR

# 3. Start the container using keep-id for seamless file access
echo "Starting Minecraft (NeoForge 1.21.1)..."
podman run -d \
  --name $CONTAINER_NAME \
  --userns=keep-id \
  --user $(id -u):$(id -g) \
  -e EULA=TRUE \
  -e TYPE=NEOFORGE \
  -e VERSION=1.21.1 \
  -e MEMORY=6G \
  -v $DATA_DIR:/data:z \
  -p 25565:25565 \
  docker.io/itzg/minecraft-server:latest

echo "------------------------------------------------"
echo "Server is starting! Use the following to see logs:"
echo "podman logs -f $CONTAINER_NAME"
echo "------------------------------------------------"

podman logs -f $CONTAINER_NAME
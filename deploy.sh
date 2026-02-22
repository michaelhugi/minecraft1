#!/bin/bash

# --- Configuration ---
SERVER_USER="mihu"
SERVER_IP="192.168.0.201"
DEST_DIR="/mnt/containers/minecraft1"
LOCAL_SRC="./server_files/"
MC_SERVICE_NAME="mc1" # This must match the name in your docker-compose.yml

echo "🚚 1. Syncing files and deleting removed mods..."
# --delete ensures server matches laptop exactly
rsync -avz --delete "$LOCAL_SRC" "$SERVER_USER@$SERVER_IP:$DEST_DIR/"

echo "🔧 2. Fixing permissions..."
ssh "$SERVER_USER@$SERVER_IP" "sudo chown -R $SERVER_USER:$SERVER_USER $DEST_DIR && chmod -R 775 $DEST_DIR"

echo "🔄 3. Restarting Minecraft container ($MC_SERVICE_NAME)..."
# We use 'podman compose' to restart only the mc1 service
ssh "$SERVER_USER@$SERVER_IP" "cd $DEST_DIR && podman compose restart $MC_SERVICE_NAME"

echo "✅ Deployment and Restart complete!"
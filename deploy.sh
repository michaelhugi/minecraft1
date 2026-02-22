#!/bin/bash

# --- Configuration ---
SERVER_USER="mihu"
SERVER_IP="192.168.0.201"
DEST_DIR="/mnt/containers/minecraft1"
LOCAL_SRC="/home/michaelhugi/Dev/minecraft1/server_files"
SERVICE_NAME="koenixtool.service"
CONTAINER_NAME="mc1"

echo "🚚 1. Pre-syncing files (Server is still ONLINE)..."
# Sync to home dir first - this is the slow part (network)
rsync -rvz --delete "$LOCAL_SRC" "$SERVER_USER@$SERVER_IP:~/"

echo "🛑 2. Stopping Systemd Service (Downtime starts NOW)..."
ssh "$SERVER_USER@$SERVER_IP" "systemctl --user stop $SERVICE_NAME"

echo "🛡️ 3. Rapid Deploy with Sudo (Instant local merge)..."
ssh -t "$SERVER_USER@$SERVER_IP" "
    # This move is lightning fast because the files are already on the server
    sudo rsync -av --delete ~/server_files/ $DEST_DIR/ &&
    sudo chown -R $SERVER_USER:$SERVER_USER $DEST_DIR &&
    sudo chmod -R 775 $DEST_DIR &&
    rm -rf ~/server_files
"

echo "🚀 4. Restarting Systemd Service (Downtime ends)..."
ssh "$SERVER_USER@$SERVER_IP" "systemctl --user start $SERVICE_NAME"

echo "✅ Deployment complete! Total downtime minimized."
echo "📟 Showing logs (Ctrl+C to exit logs)..."
sleep 2
ssh "$SERVER_USER@$SERVER_IP" "podman logs -f $CONTAINER_NAME"
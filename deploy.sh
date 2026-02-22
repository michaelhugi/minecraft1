#!/bin/bash

# --- Configuration ---
SERVER_USER="mihu"
SERVER_IP="192.168.0.201"
DEST_DIR="/mnt/containers/minecraft1"
# LOCAL_SRC points to the folder containing 'mods' and 'config'
LOCAL_SRC="/home/michaelhugi/Dev/minecraft1/server_files"
SERVICE_NAME="koenixtool.service"
CONTAINER_NAME="mc1"

echo "🚚 1. Pre-syncing mods and config (Server is ONLINE)..."
# We only sync these two specific subfolders
rsync -rvz --delete "$LOCAL_SRC/mods" "$SERVER_USER@$SERVER_IP:~/server_files_temp/"
rsync -rvz --delete "$LOCAL_SRC/config" "$SERVER_USER@$SERVER_IP:~/server_files_temp/"

echo "🛑 2. Stopping Systemd Service..."
ssh "$SERVER_USER@$SERVER_IP" "systemctl --user stop $SERVICE_NAME"

echo "🛡️ 3. Deploying Mods & Config via Sudo..."
ssh -t "$SERVER_USER@$SERVER_IP" "
    # Merge only mods and config into the destination
    sudo rsync -av --delete ~/server_files_temp/mods/ $DEST_DIR/mods/ &&
    sudo rsync -av --delete ~/server_files_temp/config/ $DEST_DIR/config/ &&

    # Fix ownership so the container can read them
    sudo chown -R $SERVER_USER:$SERVER_USER $DEST_DIR/mods $DEST_DIR/config &&
    sudo chmod -R 775 $DEST_DIR/mods $DEST_DIR/config &&

    # Clean up temp files
    rm -rf ~/server_files_temp
"

echo "🚀 4. Restarting Systemd Service..."
ssh "$SERVER_USER@$SERVER_IP" "systemctl --user start $SERVICE_NAME"

echo "✅ Deployment complete! World and root files were not touched."
sleep 2
ssh "$SERVER_USER@$SERVER_IP" "podman logs -f $CONTAINER_NAME"
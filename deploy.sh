#!/bin/bash

# --- Configuration ---
SERVER_USER="mihu"
SERVER_IP="192.168.0.201"
DEST_DIR="/mnt/containers/minecraft1"
LOCAL_SRC="/home/michaelhugi/Dev/minecraft1/server_files/"
SERVICE_NAME="koenixtool.service"
CONTAINER_NAME="mc1"

echo "🚚 1. Pre-syncing to Temp folder..."
# Sync everything to temp first so we don't hold up the SSH session
rsync -rvz --delete "$LOCAL_SRC" "$SERVER_USER@$SERVER_IP:~/server_files_temp/"

echo "🛑 2. Stopping Systemd Service..."
ssh "$SERVER_USER@$SERVER_IP" "systemctl --user stop $SERVICE_NAME"

echo "🛡️ 3. Targeted Deployment..."
ssh -t "$SERVER_USER@$SERVER_IP" "
    # A. Update Root Files (whitelist, etc.) WITHOUT deleting the World
    # Notice: NO --delete flag here. This is the 'Safe' part.
    sudo rsync -av ~/server_files_temp/ $DEST_DIR/ --exclude='mods/' --exclude='config/' &&

    # B. Sync Mods (WITH deletion)
    # This ensures server mods match laptop exactly.
    sudo rsync -av --delete ~/server_files_temp/mods/ $DEST_DIR/mods/ &&

    # C. Sync Config (WITH deletion)
    sudo rsync -av --delete ~/server_files_temp/config/ $DEST_DIR/config/ &&

    # D. Fix ownership
    sudo chown -R $SERVER_USER:$SERVER_USER $DEST_DIR &&
    sudo chmod -R 775 $DEST_DIR &&

    # E. Clean up temp files
    rm -rf ~/server_files_temp
"

echo "🚀 4. Restarting Systemd Service..."
ssh "$SERVER_USER@$SERVER_IP" "systemctl --user start $SERVICE_NAME"

echo "✅ Done! Mods/Config synced with delete. Root files updated (World safe)."
sleep 2
ssh "$SERVER_USER@$SERVER_IP" "podman logs -f $CONTAINER_NAME"
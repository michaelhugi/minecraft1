#!/bin/bash

# Configuration
SERVER_USER="mihu"
SERVER_IP="192.168.0.201"
DEST_DIR="/mnt/containers/minecraft1"

echo "🚀 Deploying Minecraft Create Mod files to $SERVER_IP..."

# 1. Create remote directories if they don't exist
ssh $SERVER_USER@$SERVER_IP "mkdir -p $DEST_DIR/mods $DEST_DIR/config"

# 2. Sync local files to the server
# (We will add the rsync command here once we have your mods ready)

echo "✅ Deployment complete!"
#!/bin/bash
set -euo pipefail

# ---------------------------
# Variables
# ---------------------------
VERSION="0.28.1"
ALERTMANAGER_USER="alertmanager"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/alertmanager"
SERVICE_FILE="/etc/systemd/system/alertmanager.service"

# ---------------------------
# Download & Install
# ---------------------------
wget https://github.com/prometheus/alertmanager/releases/download/v${VERSION}/alertmanager-${VERSION}.linux-amd64.tar.gz
tar -xvf alertmanager-${VERSION}.linux-amd64.tar.gz

# Move binaries
cp alertmanager-${VERSION}.linux-amd64/alertmanager $INSTALL_DIR/
cp alertmanager-${VERSION}.linux-amd64/amtool $INSTALL_DIR/

# Cleanup
rm -rf alertmanager-${VERSION}.linux-amd64*

# ---------------------------
# Create Alertmanager User
# ---------------------------
id -u $ALERTMANAGER_USER &>/dev/null || \
    useradd --no-create-home --shell /bin/false $ALERTMANAGER_USER

mkdir -p $CONFIG_DIR
chown -R $ALERTMANAGER_USER:$ALERTMANAGER_USER $CONFIG_DIR
chown $ALERTMANAGER_USER:$ALERTMANAGER_USER $INSTALL_DIR/alertmanager $INSTALL_DIR/amtool

# ---------------------------
# Alertmanager Configuration
# ---------------------------
cat > $CONFIG_DIR/alertmanager.yml <<'EOF'
global:
  resolve_timeout: 1m
  slack_api_url: 'https://hooks.slack.com/services/XXXXX/XXXXX/XXXXX'

route:
  receiver: 'telegram'
  routes:
    - match:
        severity: critical
      receiver: 'telegram'

receivers:
- name: 'telegram'
  telegram_configs:
  - bot_token: {REPLACE-YOUR-BOT-TOKEN-PLEASE}
    chat_id: 96100908
    api_url: "https://api.telegram.org"
    send_resolved: true
    parse_mode: ""
EOF

chown $ALERTMANAGER_USER:$ALERTMANAGER_USER $CONFIG_DIR/alertmanager.yml

# ---------------------------
# Systemd Service
# ---------------------------
cat > $SERVICE_FILE <<EOF
[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=$ALERTMANAGER_USER
Group=$ALERTMANAGER_USER
Type=simple
WorkingDirectory=$CONFIG_DIR
ExecStart=$INSTALL_DIR/alertmanager \\
  --config.file=$CONFIG_DIR/alertmanager.yml \\
  --web.external-url=http://0.0.0.0:9093

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# ---------------------------
# Start Service
# ---------------------------
systemctl daemon-reload
systemctl enable --now alertmanager

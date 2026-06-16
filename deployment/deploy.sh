#!/bin/bash
# Deployment script for Godzilla dashboard to VPS

VPS_USER="emg32"
VPS_HOST="157.173.101.159"
VPS_PORT="24032"
DEPLOY_PATH="/home/emg32/godzilla"

echo "================================================"
echo "  Deploying Godzilla Dashboard to VPS"
echo "================================================"

# Create remote directory
echo "Creating directory on VPS..."
ssh -p $VPS_PORT $VPS_USER@$VPS_HOST "mkdir -p $DEPLOY_PATH/web"

# Copy web dashboard
echo "Uploading dashboard..."
scp -P $VPS_PORT ../web/dashboard.html $VPS_USER@$VPS_HOST:$DEPLOY_PATH/web/

# Copy mqtt_bridge scripts
echo "Uploading MQTT bridge scripts..."
ssh -p $VPS_PORT $VPS_USER@$VPS_HOST "mkdir -p $DEPLOY_PATH/mqtt_bridge"
scp -P $VPS_PORT ../mqtt_bridge/*.py $VPS_USER@$VPS_HOST:$DEPLOY_PATH/mqtt_bridge/
scp -P $VPS_PORT ../mqtt_bridge/requirements.txt $VPS_USER@$VPS_HOST:$DEPLOY_PATH/mqtt_bridge/

# Setup web server
echo "Setting up web server..."
ssh -p $VPS_PORT $VPS_USER@$VPS_HOST << 'EOF'
cd /home/emg32/godzilla

# Install Python dependencies
echo "Installing Python packages..."
pip3 install -r mqtt_bridge/requirements.txt

# Create systemd service for web server
echo "Creating web server service..."
sudo tee /etc/systemd/system/godzilla-web.service > /dev/null << 'SERVICE'
[Unit]
Description=Godzilla Web Dashboard
After=network.target

[Service]
Type=simple
User=emg32
WorkingDirectory=/home/emg32/godzilla/web
ExecStart=/usr/bin/python3 -m http.server 8080
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE

# Reload systemd and start service
sudo systemctl daemon-reload
sudo systemctl enable godzilla-web.service
sudo systemctl start godzilla-web.service

echo "Web server started on port 8080"
EOF

echo ""
echo "================================================"
echo "  Deployment Complete!"
echo "================================================"
echo "Dashboard URL: http://157.173.101.159:8080/dashboard.html"
echo ""
echo "To start MQTT bridge on VPS, run:"
echo "ssh -p $VPS_PORT $VPS_USER@$VPS_HOST"
echo "cd godzilla/mqtt_bridge"
echo "python3 serial_to_mqtt.py"
echo "================================================"

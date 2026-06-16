#!/bin/bash
# Setup MQTT Bridge as a permanent service (if Arduino is connected to VPS)

echo "================================================"
echo "  Setting up MQTT Bridge as a Service"
echo "================================================"
echo ""
echo "NOTE: This is only needed if Arduino is connected"
echo "      directly to the VPS USB port."
echo ""
read -p "Is Arduino connected to VPS? (y/n): " response

if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Skipping MQTT Bridge service setup."
    exit 0
fi

read -p "Enter Arduino serial port (e.g., /dev/ttyUSB0): " SERIAL_PORT

# Create systemd service file
sudo tee /etc/systemd/system/godzilla-bridge.service > /dev/null << EOF
[Unit]
Description=Godzilla MQTT Bridge
After=network.target mosquitto.service

[Service]
Type=simple
User=emg32
WorkingDirectory=/home/emg32/godzilla/mqtt_bridge
ExecStart=/usr/bin/python3 serial_to_mqtt.py
Environment="SERIAL_PORT=${SERIAL_PORT}"
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo "✓ Service file created"

# Update serial port in Python script
sed -i "s|SERIAL_PORT = 'COM.*'|SERIAL_PORT = '${SERIAL_PORT}'|g" /home/emg32/godzilla/mqtt_bridge/serial_to_mqtt.py

# Add user to dialout group for serial access
sudo usermod -a -G dialout emg32

# Reload systemd
sudo systemctl daemon-reload
echo "✓ Systemd reloaded"

# Enable service
sudo systemctl enable godzilla-bridge.service
echo "✓ Service enabled"

# Start service
sudo systemctl start godzilla-bridge.service
echo "✓ Service started"

# Check status
echo ""
echo "================================================"
echo "  Service Status"
echo "================================================"
sudo systemctl status godzilla-bridge.service

echo ""
echo "================================================"
echo "  Setup Complete!"
echo "================================================"
echo "MQTT Bridge is now running permanently"
echo ""
echo "Useful commands:"
echo "  sudo systemctl status godzilla-bridge    # Check status"
echo "  sudo systemctl stop godzilla-bridge      # Stop service"
echo "  sudo systemctl start godzilla-bridge     # Start service"
echo "  sudo systemctl restart godzilla-bridge   # Restart service"
echo "  sudo journalctl -u godzilla-bridge -f    # View logs"
echo "================================================"

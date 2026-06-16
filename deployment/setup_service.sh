#!/bin/bash
# Setup Godzilla web server as a permanent service

echo "================================================"
echo "  Setting up Godzilla as a Permanent Service"
echo "================================================"

# Create systemd service file
sudo tee /etc/systemd/system/godzilla-web.service > /dev/null << 'EOF'
[Unit]
Description=Godzilla Temperature Dashboard
After=network.target

[Service]
Type=simple
User=emg32
WorkingDirectory=/home/emg32/godzilla/web
ExecStart=/usr/bin/python3 -m http.server 8083
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo "✓ Service file created"

# Reload systemd
sudo systemctl daemon-reload
echo "✓ Systemd reloaded"

# Enable service (start on boot)
sudo systemctl enable godzilla-web.service
echo "✓ Service enabled (will start on boot)"

# Start service now
sudo systemctl start godzilla-web.service
echo "✓ Service started"

# Check status
echo ""
echo "================================================"
echo "  Service Status"
echo "================================================"
sudo systemctl status godzilla-web.service

echo ""
echo "================================================"
echo "  Setup Complete!"
echo "================================================"
echo "Dashboard is now running permanently at:"
echo "http://157.173.101.159:8083/dashboard.html"
echo ""
echo "Useful commands:"
echo "  sudo systemctl status godzilla-web    # Check status"
echo "  sudo systemctl stop godzilla-web      # Stop service"
echo "  sudo systemctl start godzilla-web     # Start service"
echo "  sudo systemctl restart godzilla-web   # Restart service"
echo "  sudo journalctl -u godzilla-web -f    # View logs"
echo "================================================"

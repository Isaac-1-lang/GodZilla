# VPS Deployment Guide

Complete guide to deploy Godzilla dashboard to your VPS.

## VPS Connection Details
- **Host**: 157.173.101.159
- **Username**: emg32
- **Password**: emg32
- **SSH Port**: 24032

## Quick Deploy

### For Windows Users:

```bash
cd deployment
deploy_windows.bat
```

### For Linux/Mac Users:

```bash
cd deployment
chmod +x deploy.sh
./deploy.sh
```

---

## Manual Deployment Steps

### Step 1: Connect to VPS

```bash
ssh emg32@157.173.101.159 -p 24032
# Password: emg32
```

### Step 2: Create Project Directory

```bash
mkdir -p ~/godzilla/web
mkdir -p ~/godzilla/mqtt_bridge
```

### Step 3: Upload Files from Your Computer

**Upload Dashboard:**
```bash
scp -P 24032 web/dashboard.html emg32@157.173.101.159:/home/emg32/godzilla/web/
```

**Upload MQTT Bridge Scripts:**
```bash
scp -P 24032 mqtt_bridge/*.py emg32@157.173.101.159:/home/emg32/godzilla/mqtt_bridge/
scp -P 24032 mqtt_bridge/requirements.txt emg32@157.173.101.159:/home/emg32/godzilla/mqtt_bridge/
```

### Step 4: Install Dependencies on VPS

SSH into VPS and run:

```bash
ssh emg32@157.173.101.159 -p 24032

# Install pip if not installed
sudo apt update
sudo apt install python3-pip -y

# Install Python packages
cd ~/godzilla/mqtt_bridge
pip3 install -r requirements.txt
```

### Step 5: Setup Web Server

**Option A: Simple Python HTTP Server**

```bash
cd ~/godzilla/web
python3 -m http.server 8080
```

Access at: `http://157.173.101.159:8080/dashboard.html`

**Option B: Using systemd (Persistent Service)**

Create service file:

```bash
sudo nano /etc/systemd/system/godzilla-web.service
```

Add this content:

```ini
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
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable godzilla-web.service
sudo systemctl start godzilla-web.service
sudo systemctl status godzilla-web.service
```

### Step 6: Setup MQTT Bridge Service (Keep Running)

**Important Note:** The MQTT bridge needs to run on the computer where Arduino is connected. If Arduino is connected to your local PC (not the VPS), keep the bridge running locally.

**Option A: Make Web Server Permanent on VPS**

Run on VPS:

```bash
cd ~/godzilla/mqtt_bridge
python3 serial_to_mqtt.py
```

**Option B: Run in Background with Screen**

```bash
# Install screen
sudo apt install screen -y

# Start new screen session
screen -S godzilla

# Run the bridge
cd ~/godzilla/mqtt_bridge
python3 serial_to_mqtt.py

# Detach from screen: Press Ctrl+A then D
# Reattach later: screen -r godzilla
```

**Option C: Create systemd Service**

Create service file:

```bash
sudo nano /etc/systemd/system/godzilla-bridge.service
```

Add content (UPDATE COM PORT):

```ini
[Unit]
Description=Godzilla MQTT Bridge
After=network.target

[Service]
Type=simple
User=emg32
WorkingDirectory=/home/emg32/godzilla/mqtt_bridge
ExecStart=/usr/bin/python3 serial_to_mqtt.py
Restart=always
Environment="SERIAL_PORT=/dev/ttyUSB0"

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable godzilla-bridge.service
sudo systemctl start godzilla-bridge.service
sudo systemctl status godzilla-bridge.service
```

---

## Configure MQTT Broker on VPS

If MQTT broker (Mosquitto) is not installed:

```bash
# Install Mosquitto
sudo apt update
sudo apt install mosquitto mosquitto-clients -y

# Enable WebSocket support
sudo nano /etc/mosquitto/mosquitto.conf
```

Add these lines:

```
listener 1883
protocol mqtt

listener 9001
protocol websockets

allow_anonymous true
```

Restart Mosquitto:

```bash
sudo systemctl restart mosquitto
sudo systemctl enable mosquitto
sudo systemctl status mosquitto
```

Test broker:

```bash
# Subscribe (Terminal 1)
mosquitto_sub -h 127.0.0.1 -t "godzilla/temperature"

# Publish (Terminal 2)
mosquitto_pub -h 127.0.0.1 -t "godzilla/temperature" -m '{"temperature":25.5,"candidate":"NIYOBYOSE Isaac Precieux"}'
```

---

## Accessing the Dashboard

### Local Network:
`http://157.173.101.159:8080/dashboard.html`

### If Port 8080 is Blocked:

Configure firewall:

```bash
sudo ufw allow 8080/tcp
sudo ufw allow 1883/tcp
sudo ufw allow 9001/tcp
sudo ufw reload
```

---

## Useful Commands

### Check Services:
```bash
sudo systemctl status godzilla-web
sudo systemctl status godzilla-bridge
sudo systemctl status mosquitto
```

### View Logs:
```bash
sudo journalctl -u godzilla-web -f
sudo journalctl -u godzilla-bridge -f
sudo journalctl -u mosquitto -f
```

### Restart Services:
```bash
sudo systemctl restart godzilla-web
sudo systemctl restart godzilla-bridge
sudo systemctl restart mosquitto
```

### Stop Services:
```bash
sudo systemctl stop godzilla-web
sudo systemctl stop godzilla-bridge
```

### File Management:
```bash
# List files
ls -la ~/godzilla/

# Edit files
nano ~/godzilla/web/dashboard.html
nano ~/godzilla/mqtt_bridge/serial_to_mqtt.py

# Check Python version
python3 --version

# Check installed packages
pip3 list | grep mqtt
pip3 list | grep serial
```

---

## Troubleshooting

### Cannot Connect via SSH:
- Verify port: 24032
- Check firewall settings
- Try: `telnet 157.173.101.159 24032`

### Web Server Not Accessible:
```bash
# Check if running
netstat -tulpn | grep 8080

# Try different port
python3 -m http.server 8000
```

### MQTT Not Connecting:
```bash
# Test broker
mosquitto_pub -h 157.173.101.159 -t test -m "hello"
mosquitto_sub -h 157.173.101.159 -t test

# Check if running
sudo systemctl status mosquitto

# Check ports
netstat -tulpn | grep 1883
netstat -tulpn | grep 9001
```

### Serial Port Issues:
```bash
# List available serial ports
ls -la /dev/tty*

# Check permissions
sudo usermod -a -G dialout emg32
```

---

## Project Structure on VPS

```
/home/emg32/godzilla/
├── web/
│   └── dashboard.html
└── mqtt_bridge/
    ├── serial_to_mqtt.py
    ├── test_mqtt_subscriber.py
    ├── test_mqtt_publisher.py
    └── requirements.txt
```

---

## Security Notes

**IMPORTANT:** Change default password after first login:

```bash
passwd
# Enter current password: emg32
# Enter new password
```

Consider:
- Setting up SSH keys instead of password
- Disabling password authentication
- Configuring MQTT authentication
- Setting up nginx reverse proxy with SSL

---

## Final Access URLs

- **Dashboard**: http://157.173.101.159:8080/dashboard.html
- **MQTT Broker**: mqtt://157.173.101.159:1883
- **MQTT WebSocket**: ws://157.173.101.159:9001

---

**Deployment Complete! 🦖**

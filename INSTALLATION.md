# Godzilla Installation Guide

Complete step-by-step installation instructions for the Godzilla Temperature Monitoring System.

## Prerequisites

- Arduino Uno
- DHT11 Temperature Sensor
- I2C LCD 16x2
- USB Cable
- Computer with Windows
- Internet connection

---

## Part 1: Install Arduino IDE

### Step 1: Download Arduino IDE
1. Go to: https://www.arduino.cc/en/software
2. Download "Windows Win 10 and newer, 64 bits"
3. Run the installer and follow instructions
4. Launch Arduino IDE

### Step 2: Install Required Libraries
1. Open Arduino IDE
2. Go to **Tools → Manage Libraries** (or press Ctrl+Shift+I)
3. Search and install these libraries:
   - **DHT sensor library** by Adafruit
   - **Adafruit Unified Sensor** (dependency for DHT)
   - **LiquidCrystal I2C** by Frank de Brabander

![Library Manager](https://i.imgur.com/library.png)

### Step 3: Connect Arduino
1. Connect Arduino Uno to computer via USB
2. In Arduino IDE: **Tools → Board → Arduino AVR Boards → Arduino Uno**
3. In Arduino IDE: **Tools → Port → COM3** (or whichever COM port shows up)

### Step 4: Upload Code
1. Open `embedded/godzilla_sensor.ino`
2. Click the **Upload** button (→ arrow icon)
3. Wait for "Done uploading" message
4. Open **Tools → Serial Monitor** to see temperature readings

**Note:** If you see gibberish in Serial Monitor, set baud rate to **9600**

---

## Part 2: Install Python & Required Packages

### Step 1: Check if Python is Installed
1. Open Command Prompt (press Win+R, type `cmd`, press Enter)
2. Type: `python --version`
3. If you see Python 3.x, skip to Step 3

### Step 2: Install Python (if not installed)
1. Go to: https://www.python.org/downloads/
2. Download "Python 3.11" or newer
3. Run installer
4. ✅ **IMPORTANT:** Check "Add Python to PATH" during installation
5. Click "Install Now"
6. Restart Command Prompt

### Step 3: Install Python Packages
Open Command Prompt and run:

```bash
# Navigate to project folder
cd path\to\Godzilla\mqtt_bridge

# Install required packages
pip install -r requirements.txt
```

Or install manually:
```bash
pip install paho-mqtt
pip install pyserial
```

---

## Part 3: Configure and Run

### Step 1: Find Your Arduino COM Port

**Method 1 - Using Arduino IDE:**
- Open Arduino IDE
- Go to **Tools → Port**
- Note the COM port (e.g., COM3, COM4)

**Method 2 - Using Device Manager:**
1. Press Win+X, select "Device Manager"
2. Expand "Ports (COM & LPT)"
3. Find "Arduino Uno (COM3)" or similar

### Step 2: Update COM Port in Python Script
1. Open `mqtt_bridge/serial_to_mqtt.py`
2. Find line: `SERIAL_PORT = 'COM3'`
3. Change COM3 to your actual port (e.g., COM4, COM5)
4. Save file

### Step 3: Run the Bridge Script
```bash
cd mqtt_bridge
python serial_to_mqtt.py
```

You should see:
```
Connecting to MQTT broker at 157.173.101.159:1883
Connected to MQTT Broker!
Opening serial port COM3
Serial port opened successfully
Starting data bridge...
Received: {'temperature': 25.0, 'candidate': 'NIYOBYOSE Isaac Precieux'}
Published to godzilla/temperature
```

---

## Part 4: Test MQTT Connection

### Option A: Using Test Subscriber (Recommended)
Open a **new** Command Prompt window:
```bash
cd mqtt_bridge
python test_mqtt_subscriber.py
```

You should see messages appearing every 5 seconds!

### Option B: Using MQTT Explorer (Visual Tool)
1. Download from: http://mqtt-explorer.com/
2. Install and open
3. Click "+" to add connection:
   - Name: Godzilla
   - Host: 157.173.101.159
   - Port: 1883
4. Click "CONNECT"
5. Expand "godzilla" → "temperature" to see live data

---

## Part 5: Open Web Dashboard

### Step 1: Update Broker IP (Already Done)
The broker IP (157.173.101.159) is already configured.

### Step 2: Open Dashboard
1. Navigate to `web/dashboard.html`
2. Right-click → Open with → Chrome/Firefox/Edge
3. You should see the Godzilla dashboard with live temperature!

**Note:** Some browsers block WebSocket on local files. If it doesn't work:
- Use Firefox (works best with local files)
- Or run a local web server:
  ```bash
  cd web
  python -m http.server 8000
  ```
  Then open: http://localhost:8000/dashboard.html

---

## Troubleshooting

### Arduino Issues

**Problem: Port not found**
- Unplug and replug USB cable
- Try different USB port
- Install CH340 driver if using clone Arduino

**Problem: Upload error**
- Close Serial Monitor before uploading
- Check correct board selected (Arduino Uno)
- Try pressing reset button on Arduino

**Problem: LCD shows nothing**
- Check I2C address (try 0x3F if 0x27 doesn't work)
- Adjust LCD contrast potentiometer
- Check wiring: SDA→A4, SCL→A5

**Problem: Sensor reads NaN or error**
- Check DHT11 wiring (DATA→Pin 2)
- Wait 2 seconds after power-up
- Try different sensor (might be faulty)

### Python Issues

**Problem: "python" not recognized**
- Reinstall Python with "Add to PATH" checked
- Try `py` instead of `python`

**Problem: "pip" not recognized**
- Try: `python -m pip install paho-mqtt`

**Problem: Serial port busy**
- Close Arduino IDE Serial Monitor
- Close any other program using the port
- Restart computer

**Problem: Permission denied on COM port**
- Run Command Prompt as Administrator
- Check Device Manager for port conflicts

### MQTT Issues

**Problem: Cannot connect to broker**
- Check internet connection
- Verify broker IP: 157.173.101.159
- Check firewall settings
- Try: `ping 157.173.101.159`

**Problem: No data in dashboard**
- Check browser console (F12) for errors
- Try Firefox instead of Chrome
- Verify Python bridge is running
- Check test subscriber works first

---

## Quick Start Checklist

- [ ] Arduino IDE installed
- [ ] Libraries installed (DHT, LiquidCrystal_I2C)
- [ ] Arduino code uploaded
- [ ] Python 3.x installed
- [ ] Python packages installed (paho-mqtt, pyserial)
- [ ] COM port configured in serial_to_mqtt.py
- [ ] Python bridge running
- [ ] Test subscriber shows data
- [ ] Web dashboard open and connected

---

## System Requirements

**Hardware:**
- Arduino Uno
- DHT11 sensor
- I2C LCD 16x2
- USB cable

**Software:**
- Windows 10 or newer
- Arduino IDE 2.x
- Python 3.8 or newer
- Web browser (Firefox recommended)

**Network:**
- Internet connection to reach MQTT broker

---

## Support

If you encounter issues:
1. Check Arduino Serial Monitor (9600 baud) for sensor readings
2. Run test_mqtt_subscriber.py to verify broker connection
3. Check all wiring connections
4. Verify COM port is correct
5. Check Python script output for errors

## File Structure
```
Godzilla/
├── embedded/
│   ├── godzilla_sensor.ino    # Upload this to Arduino
│   └── config.h               # Configuration file
├── mqtt_bridge/
│   ├── serial_to_mqtt.py      # Run this after Arduino
│   ├── test_mqtt_subscriber.py # Test script
│   ├── test_mqtt_publisher.py  # Test script
│   └── requirements.txt        # Python dependencies
├── web/
│   └── dashboard.html         # Open in browser
└── README.md
```

---

**Ready to start!** Follow the steps in order and you'll have your system running in no time! 🦖

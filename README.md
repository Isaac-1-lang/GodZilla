# Godzilla - Temperature Monitoring System

An embedded temperature sensor project that reads temperature values, displays them on an LCD screen, and publishes data to an MQTT broker for web visualization.

## Candidate Information
**Name**: NIYOBYOSE Isaac Precieux

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      GODZILLA SYSTEM DIAGRAM                    │
└─────────────────────────────────────────────────────────────────┘

    ┌──────────────┐         ┌──────────────────┐
    │   DHT11      │────────▶│  Arduino Uno     │
    │  Sensor      │  Pin 2  │                  │
    └──────────────┘         │  ┌────────────┐  │
                             │  │ Processing │  │
    ┌──────────────┐         │  │ & Display  │  │
    │  I2C LCD     │◀────────│  └────────────┘  │
    │  16x2        │ SDA/SCL │                  │
    │              │  A4/A5  │   Serial Port    │
    │ NIYOBYOSE    │         │   (9600 baud)    │
    │ Isaac        │         └─────────┬────────┘
    │ Temp: 25°C   │                   │
    └──────────────┘                   │ USB Cable
                                       │ (COM Port)
                                       │
                                       ▼
                        ┌──────────────────────────┐
                        │   Computer/Laptop        │
                        │                          │
                        │  ┌────────────────────┐  │
                        │  │ Python Script      │  │
                        │  │ serial_to_mqtt.py  │  │
                        │  │                    │  │
                        │  │ - Reads Serial     │  │
                        │  │ - Parses JSON      │  │
                        │  │ - Publishes MQTT   │  │
                        │  └─────────┬──────────┘  │
                        └────────────┼─────────────┘
                                     │ WiFi/Internet
                                     │
                                     ▼
                          ┌──────────────────────┐
                          │   MQTT Broker        │
                          │   157.173.101.159    │
                          │   Port: 1883         │
                          │                      │
                          │   Topic:             │
                          │   godzilla/temp      │
                          └──────────┬───────────┘
                                     │
                                     │ WebSocket
                                     │ Port: 9001
                                     ▼
                          ┌──────────────────────┐
                          │   Web Browser        │
                          │   dashboard.html     │
                          │                      │
                          │   📊 Live Display    │
                          │   🦖 Godzilla UI     │
                          └──────────────────────┘
```

## Serial Communication Protocol

**Communication Parameters:**
- **Baud Rate**: 9600 bps
- **Data Bits**: 8
- **Parity**: None
- **Stop Bits**: 1
- **Flow Control**: None

**Data Format (JSON):**
```json
{"temperature":25.5,"candidate":"NIYOBYOSE Isaac Precieux"}
```

**Serial Message Structure:**
- **Format**: JSON string terminated with newline (\n)
- **Frequency**: Every 5 seconds
- **Direction**: Arduino → Computer (TX → RX)
- **Encoding**: UTF-8

## Project Components

- **Embedded Sensor**: Reads temperature and displays on LCD with candidate name
- **Serial Bridge**: Python script bridges Arduino serial to MQTT
- **MQTT Broker**: Central message broker at 157.173.101.159
- **Web Dashboard**: HTML interface to visualize real-time temperature data

## Setup

### Hardware Requirements
- Arduino Uno
- DHT11 temperature sensor
- I2C LCD Display 16x2 (with SDA, SCL, VCC, GND)
- Computer with Python (for MQTT bridge)

### Wiring
**DHT11 Sensor:**
- VCC → 5V
- GND → GND
- DATA → Pin 2

**I2C LCD:**
- VCC → 5V
- GND → GND
- SDA → A4
- SCL → A5

### MQTT Broker
- **Broker IP**: 157.173.101.159
- **MQTT Port**: 1883 (for Python bridge)
- **WebSocket Port**: 9001 (for web dashboard)
- **Topic**: godzilla/temperature

## Testing & Verification

### Check if data is being sent to broker

**Method 1: Using Test Subscriber Script**
```bash
cd mqtt_bridge
python test_mqtt_subscriber.py
```
This will show all messages being published to the broker in real-time.

**Method 2: Using Test Publisher Script**
```bash
cd mqtt_bridge
python test_mqtt_publisher.py
```
This sends fake temperature data to test if the broker is working.

**Method 3: Using MQTT Explorer (GUI Tool)**
- Download MQTT Explorer: http://mqtt-explorer.com/
- Connect to: 157.173.101.159:1883
- Subscribe to topic: godzilla/temperature

**Method 4: Using mosquitto_sub command**
```bash
mosquitto_sub -h 157.173.101.159 -p 1883 -t "godzilla/temperature"
```

## Quick Start

**New to the project?** See [INSTALLATION.md](INSTALLATION.md) for complete step-by-step setup instructions.

### Installation Steps

1. **Arduino Uno Setup:**
   - Install libraries: `LiquidCrystal_I2C`, `DHT sensor library`
   - Upload `embedded/godzilla_sensor.ino`
   - Note the COM port (e.g., COM3)

2. **Python Bridge Setup:**
   ```bash
   cd mqtt_bridge
   pip install -r requirements.txt
   # Edit serial_to_mqtt.py to set your COM port and broker IP
   python serial_to_mqtt.py
   ```

3. **Web Dashboard:**
   - Update broker IP in `web/dashboard.html`
   - Open in browser

## File Structure
- `/embedded/` - Arduino Uno code for sensor and LCD
- `/mqtt_bridge/` - Python script to bridge Serial to MQTT
- `/web/` - HTML dashboard for data visualization

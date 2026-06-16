#!/usr/bin/env python3
"""
Godzilla MQTT Bridge
Reads temperature data from Arduino via Serial and publishes to MQTT broker
"""

import serial
import paho.mqtt.client as mqtt
import json
import time
import sys

# Configuration
SERIAL_PORT = 'COM14'  # Change to your Arduino port (COM3, COM4 on Windows, /dev/ttyUSB0 on Linux)
BAUD_RATE = 9600
MQTT_BROKER = '157.173.101.159'
MQTT_PORT = 1883
MQTT_TOPIC = 'godzilla/temperature'

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected to MQTT Broker!")
    else:
        print(f"Failed to connect, return code {rc}")

def main():
    # Setup MQTT client
    client = mqtt.Client("GodzillaBridge")
    client.on_connect = on_connect
    
    try:
        print(f"Connecting to MQTT broker at {MQTT_BROKER}:{MQTT_PORT}")
        client.connect(MQTT_BROKER, MQTT_PORT, 60)
        client.loop_start()
    except Exception as e:
        print(f"Error connecting to MQTT broker: {e}")
        sys.exit(1)
    
    # Setup Serial connection
    try:
        print(f"Opening serial port {SERIAL_PORT}")
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
        time.sleep(2)  # Wait for Arduino to reset
        print("Serial port opened successfully")
    except Exception as e:
        print(f"Error opening serial port: {e}")
        sys.exit(1)
    
    print("Starting data bridge...")
    
    try:
        while True:
            if ser.in_waiting > 0:
                line = ser.readline().decode('utf-8').strip()
                
                if line.startswith('{'):
                    try:
                        # Parse JSON data
                        data = json.loads(line)
                        print(f"Received: {data}")
                        
                        # Publish to MQTT
                        client.publish(MQTT_TOPIC, json.dumps(data))
                        print(f"Published to {MQTT_TOPIC}")
                        
                    except json.JSONDecodeError:
                        print(f"Invalid JSON: {line}")
                else:
                    print(f"Arduino: {line}")
            
            time.sleep(0.1)
            
    except KeyboardInterrupt:
        print("\nStopping bridge...")
    finally:
        ser.close()
        client.loop_stop()
        client.disconnect()
        print("Bridge stopped")

if __name__ == "__main__":
    main()

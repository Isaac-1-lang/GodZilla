#!/usr/bin/env python3
"""
MQTT Test Subscriber
Use this to verify if data is being published to the broker
"""

import paho.mqtt.client as mqtt
import json
from datetime import datetime

# Configuration
MQTT_BROKER = '157.173.101.159'
MQTT_PORT = 1883
MQTT_TOPIC = 'godzilla/temperature'

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("✓ Connected to MQTT Broker successfully!")
        print(f"✓ Subscribed to topic: {MQTT_TOPIC}")
        print("-" * 50)
        print("Waiting for messages... (Press Ctrl+C to stop)")
        print("-" * 50)
        client.subscribe(MQTT_TOPIC)
    else:
        print(f"✗ Failed to connect, return code {rc}")
        print("Return codes:")
        print("  1: Connection refused - incorrect protocol version")
        print("  2: Connection refused - invalid client identifier")
        print("  3: Connection refused - server unavailable")
        print("  4: Connection refused - bad username or password")
        print("  5: Connection refused - not authorized")

def on_message(client, userdata, msg):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"\n[{timestamp}] Message received!")
    print(f"Topic: {msg.topic}")
    print(f"Payload: {msg.payload.decode()}")
    
    try:
        data = json.loads(msg.payload.decode())
        print(f"Temperature: {data.get('temperature', 'N/A')}°C")
        print(f"Candidate: {data.get('candidate', 'N/A')}")
    except json.JSONDecodeError:
        print("Note: Payload is not valid JSON")
    print("-" * 50)

def on_disconnect(client, userdata, rc):
    if rc != 0:
        print(f"✗ Unexpected disconnection. Return code: {rc}")

def main():
    print("=" * 50)
    print("   GODZILLA MQTT TEST SUBSCRIBER")
    print("=" * 50)
    print(f"Broker: {MQTT_BROKER}:{MQTT_PORT}")
    print(f"Topic: {MQTT_TOPIC}")
    print("=" * 50)
    
    client = mqtt.Client("GodzillaTestSubscriber")
    client.on_connect = on_connect
    client.on_message = on_message
    client.on_disconnect = on_disconnect
    
    try:
        print("\nConnecting to broker...")
        client.connect(MQTT_BROKER, MQTT_PORT, 60)
        client.loop_forever()
    except KeyboardInterrupt:
        print("\n\nStopping subscriber...")
        client.disconnect()
        print("Subscriber stopped.")
    except Exception as e:
        print(f"\n✗ Error: {e}")

if __name__ == "__main__":
    main()

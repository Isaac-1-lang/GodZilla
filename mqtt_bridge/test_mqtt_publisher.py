#!/usr/bin/env python3
"""
MQTT Test Publisher
Use this to manually send test data to the broker
"""

import paho.mqtt.client as mqtt
import json
import time
import random

# Configuration
MQTT_BROKER = '157.173.101.159'
MQTT_PORT = 1883
MQTT_TOPIC = 'godzilla/temperature'

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("✓ Connected to MQTT Broker!")
    else:
        print(f"✗ Failed to connect, return code {rc}")

def main():
    print("=" * 50)
    print("   GODZILLA MQTT TEST PUBLISHER")
    print("=" * 50)
    print(f"Broker: {MQTT_BROKER}:{MQTT_PORT}")
    print(f"Topic: {MQTT_TOPIC}")
    print("=" * 50)
    
    client = mqtt.Client("GodzillaTestPublisher")
    client.on_connect = on_connect
    
    try:
        print("\nConnecting to broker...")
        client.connect(MQTT_BROKER, MQTT_PORT, 60)
        client.loop_start()
        time.sleep(2)
        
        print("\nSending test messages (Ctrl+C to stop)...\n")
        
        count = 1
        while True:
            # Generate test temperature data
            temp = round(random.uniform(20.0, 30.0), 1)
            data = {
                "temperature": temp,
                "candidate": "NIYOBYOSE Isaac Precieux"
            }
            
            payload = json.dumps(data)
            result = client.publish(MQTT_TOPIC, payload)
            
            if result.rc == mqtt.MQTT_ERR_SUCCESS:
                print(f"[{count}] ✓ Published: {payload}")
            else:
                print(f"[{count}] ✗ Failed to publish")
            
            count += 1
            time.sleep(5)
            
    except KeyboardInterrupt:
        print("\n\nStopping publisher...")
    except Exception as e:
        print(f"\n✗ Error: {e}")
    finally:
        client.loop_stop()
        client.disconnect()
        print("Publisher stopped.")

if __name__ == "__main__":
    main()

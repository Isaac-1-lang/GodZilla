/*
 * Configuration file for Godzilla project - Arduino Uno
 * Update these values according to your setup
 */

#ifndef CONFIG_H
#define CONFIG_H

// Sensor Configuration
#define DHT_PIN 2
#define DHT_TYPE DHT11

// I2C LCD Configuration
#define LCD_ADDRESS 0x27  // Common I2C address, try 0x3F if this doesn't work
#define LCD_COLS 16
#define LCD_ROWS 2
// SDA and SCL pins are default (A4=SDA, A5=SCL on Arduino Uno)

// Reading interval (milliseconds)
#define READ_INTERVAL 5000

// Candidate Information
#define CANDIDATE_NAME "NIYOBYOSE Isaac"
#define CANDIDATE_FULL_NAME "NIYOBYOSE Isaac Precieux"

#endif

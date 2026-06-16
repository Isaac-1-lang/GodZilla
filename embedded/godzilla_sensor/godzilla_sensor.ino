#include <DHT.h>
#include <LiquidCrystal_I2C.h>

#define DHTPIN 8
#define DHTTYPE DHT11

DHT dht(DHTPIN, DHTTYPE);
LiquidCrystal_I2C lcd(0x27, 16, 2);

String name = "NIYOBYOSE Isaac";
int scrollPos = 0;
unsigned long lastScroll = 0;

void setup() {
  Serial.begin(9600);
  delay(2000);

  dht.begin();
  delay(2000);

  lcd.init();
  lcd.backlight();
  lcd.clear();

  lcd.setCursor(0, 0);
  lcd.print("Booting...");
  delay(1000);
  lcd.clear();

  Serial.println("Setup complete");
}

void loop() {
  float temp = dht.readTemperature();

  // ===== Serial to PC =====
  if (!isnan(temp)) {
    Serial.print("{\"temperature\":");
    Serial.print(temp, 1);
    Serial.print(",\"device\":\"Godzilla\"}");
    Serial.println();
  } else {
    Serial.println("{\"error\":\"DHT11 read failed\"}");
  }

  // ===== LCD Row 0 — Scrolling name =====
  if (name.length() > 16) {
    if (millis() - lastScroll > 300) {
      String text = name + "    ";
      lcd.setCursor(0, 0);
      for (int i = 0; i < 16; i++) {
        lcd.print(text[(scrollPos + i) % text.length()]);
      }
      scrollPos++;
      if (scrollPos >= (int)text.length()) scrollPos = 0;
      lastScroll = millis();
    }
  } else {
    lcd.setCursor(0, 0);
    lcd.print(name);
    // pad spaces to clear leftover characters
    for (int i = name.length(); i < 16; i++) lcd.print(" ");
  }

  // ===== LCD Row 1 — Temperature only =====
  lcd.setCursor(0, 1);
  if (!isnan(temp)) {
    lcd.print("Temp: ");
    lcd.print(temp, 1);
    lcd.print((char)223);
    lcd.print("C      ");
  } else {
    lcd.print("Sensor Error!   ");
  }

  delay(1000);
}
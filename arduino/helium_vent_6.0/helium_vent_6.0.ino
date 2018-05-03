#include <Printers.h>
#include <SoftwareSerial.h>
#include <Servo.h>
#include <Wire.h>
//#include <EEPROM.h>
#include <SD.h>
#include <math.h>
#include "IntersemaBaro.h"

Intersema::BaroPressure_MS5607B baro(true);

Servo actuator;
const int chipSelect = 4;
long t_init = millis();
int t;
int actuator_pin = 8;
int open = 1150;
int close = 1690;
uint32_t dPdt;
int LED = 4;
int toggle = 2;
int arm = 6;
uint32_t pressure;
uint32_t p1;
uint32_t p;

boolean vent_open;
boolean ballast_drop;
boolean neutral_buoyancy;

void setup()
{
  Serial.begin(9600);
  pinMode(LED, OUTPUT);
  baro.init();

  manualControl();
  delay(60 * 60 * 1000);
  neutralBuoyancy(t);
  ventHelium();
}

void loop()
{

}

void ledOn()
{
  digitalWrite(LED, HIGH);
}

void ledOff()
{
  digitalWrite(LED, LOW);
}

void ledBlink()
{
  ledOn();
  delay(250);
  ledOff();
  delay(250);
}

void dropBallast()
{
  Serial.write("drop");
  ballast_drop = true;
}

void holdBallast()
{
  Serial.write("hold");
  ballast_drop = false;
}

void ventHelium()
{
  if (vent_open == true)
  {
    actuator.attach(actuator_pin, 1050, 2000);
    actuator.writeMicroseconds(open);
    delay(1000);
    actuator.detach();
    vent_open = false;
  }
  else {}
}

void holdHelium()
{
  if (vent_open == false)
  {
    actuator.attach(actuator_pin, 1050, 2000);
    actuator.writeMicroseconds(close);
    delay(1000);
    actuator.detach();
    vent_open = true;
  }
  else {}
}

void getPressure()
{
  p = (double)(baro.getHeightCentiMeters());
  pressure = ((p / 0.897992) - 9725.375344101109);
  return pressure;
}

void dPdT()
{
  uint32_t dt = 5;

  uint32_t pressure1 = getPressure();
  delay(dt * 1000);
  uint32_t pressure2 = getPressure();

  dPdt = (pressure2 - pressure1) / dt / 4;
}

void saveInitData()
{
  File dataFile = SD.open("alt_control_datalog.txt", FILE_WRITE);
  dataFile.println("New Flight");
  dataFile.println("Time (ms); Pressure (Pa); vent_open; ballast_drop; neutral_buoyancy;");
  dataFile.close();
}

void saveData()
{
  getPressure();
  File dataFile = SD.open("alt_control_datalog.txt", FILE_WRITE);
  dataFile.print((millis()-t) + "; ");
  dataFile.print(pressure + "; ");
  dataFile.print(vent_open + "; ");
  dataFile.print(ballast_drop + "; ");
  dataFile.print(neutral_buoyancy + "; ");
  dataFile.println();
  dataFile.close();
}

void manualControl()
{
  int armOn = digitalRead(arm);
  while (armOn == HIGH)
  {
    ledBlink();
    int tglOn = digitalRead(toggle);
    if (armOn == HIGH && tglOn == LOW)
    {
      holdHelium();
    }
    else if (armOn == HIGH && tglOn == HIGH)
    {
      ventHelium();
    }
  }
}

void neutralBuoyancy(int t)
{
  ledOn();
  long startTime = millis();
  while (startTime - millis() < t)
  {
    saveData();
    dPdT();
    if (dPdT < 0 && vent_open == false)
    {
      holdBallast();
      ventHelium();
      neutral_buoyancy = false;
    }
    else if (dPdT == 0 && vent_open == true)
    {
      holdBallast();
      holdHelium();
      neutral_buoyancy = true;
    }
    else if (dPdT > 0)
    {
      dropBallast();
      holdHelium();
      neutral_buoyancy = false;
    }
  }
  ledOff();
}



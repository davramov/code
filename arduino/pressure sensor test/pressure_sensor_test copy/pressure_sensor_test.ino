#include <Wire.h>
#include <EEPROM.h>
#include <math.h>
#include "IntersemaBaro.h"

Intersema::BaroPressure_MS5607B baro(true);

uint32_t pressure;
double p1;
double p;
int i = 0;


void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  baro.init();
  //pressure = baro.getHeightCentiMeters();
}

void loop() {
  // put your main code here, to run repeatedly:
//  while(i < EEPROM.length()){
//    //pressure = ((baro.getHeightCentiMeters()/0.897992)-9332.375344101109)/1000;
//    p = (double)(baro.getHeightCentiMeters());
//    p1 = ((p/0.897992)-9725.375344101109);
//    pressure = (uint32_t)(p1)/1000;
//    EEPROM.write(i, pressure);
//    delay(1000);
//    i++;
//  }
  p = (double)(baro.getHeightCentiMeters());
  p1 = ((p/0.897992)-9725.375344101109);
  pressure = (uint32_t)(p1);
//  pressure = baro.getHeightCentiMeters()/100;
  Serial.print(pressure);
  Serial.println('\n');
  delay(1000);
//  
  
}

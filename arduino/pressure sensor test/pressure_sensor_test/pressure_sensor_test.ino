#include <Wire.h>
#include <EEPROM.h>
#include <math.h>
#include "IntersemaBaro.h"

Intersema::BaroPressure_MS5607B baro(true);

uint32_t pressure;
double p1;
double p;
int i = 0;
int t_init;
#include <SD.h>

const int chipSelect = 4;


void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  baro.init();
  t_init = millis()/1000;
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
//  pinMode(8,HIGH);
//  p = (double)(baro.getHeightCentiMeters());
//  p1 = ((p/0.897992)-9725.375344101109);
//  pressure = (uint32_t)(p1);
////  pressure = baro.getHeightCentiMeters()/100;
//  Serial.print(pressure);
//  Serial.println('\n');
// 
  //pinMode(8,LOW);
  baro.init();
  int t = millis()/1000-t_init;
  p = (double)(baro.getHeightCentiMeters());
  p1 = ((p/0.897992)-9725.375344101109);
  pressure = (uint32_t)(p1);
  Serial.print(pressure);
  Serial.println('\n');


  
  File dataFile = SD.open("alt_control_datalog.txt", FILE_WRITE);
  if (dataFile){
    dataFile.println(pressure);
    dataFile.println(t);
    dataFile.close();
    
  }
  else{
    Serial.println("error opening txt");
  }
  delay(1000);
  
//  
  
}

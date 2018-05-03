#include <Servo.h> 
#include <Wire.h>
#include <EEPROM.h>
#include <math.h>
#include "IntersemaBaro.h"

Intersema::BaroPressure_MS5607B baro(true);

Servo actuator;  // create servo objects to control the linear actuator
int actuator_pin = 12;
int linearValue = 1500;   //current positional value being sent to the linear actuator. 
int toggle = 2; //switch that controls whether switch is up or down if 'arm' is not set
int arm = 7; //switch that controls whether venting timer is initiated
int LED = 4;
long startTime;
int elapsedTime;
int32_t pressure;
double p1;
double p;

boolean cycle_complete = false;
boolean vent_open = false;

void setup() 
{ 
  Serial.begin(9600);
  baro.init();
  actuator.attach(actuator_pin, 1050, 2000);
  pinMode(toggle,INPUT_PULLUP);
  pinMode(arm,INPUT_PULLUP);
  pinMode(LED,OUTPUT);
} 

void loop() { 

  
  int armOn = digitalRead(arm);
  int tglOn = digitalRead(toggle);
  
  //TOGGLE switch in the UP & CLOSED position
  //ARMING switch in the DOWN position
  if(armOn == HIGH && tglOn == LOW){
    if(vent_open == false){
      actuator.attach(actuator_pin, 1050, 2000);
      actuator.writeMicroseconds(1690);
      delay(1000);
      actuator.detach();
      vent_open = true;
    }
    else{  
    }  
  } 
  //TOGGLE switch in the DOWN & OPEN position
  //ARMING switch in the DOWN position
  else if(armOn == HIGH && tglOn == HIGH){
    if(vent_open = true){
      actuator.attach(actuator_pin, 1050, 2000);
      actuator.writeMicroseconds(1150); 
      delay(1000);
      actuator.detach();
      vent_open = false;
    }
    else{     
    }
  }
  
  //ARMING swithcin the UP position
  if(armOn == LOW){  
    digitalWrite(LED,HIGH);
    actuator.attach(actuator_pin, 1050, 2000);
    actuator.writeMicroseconds(1690);
    delay(1000);
    
    actuator.detach();
    startTime = millis();
    while(cycle_complete == false){
      p = (double)(baro.getHeightCentiMeters());
      p1 = ((p/0.897992)-9725.375344101109);
      pressure = (uint32_t)(p1);
      Serial.print(pressure);
      Serial.println('\n');
      
      if((double)(millis() - startTime) >= 3600000 || (int32_t)pressure <= 13000){
        uint32_t p = pressure/1000;
        elapsedTime = (int)((millis()-startTime)/60000);
        EEPROM.write(0,elapsedTime); //Records time in minutes
        EEPROM.write(1,p); //Records pressure in kPa
        actuator.attach(actuator_pin, 1050, 2000);
        actuator.writeMicroseconds(1150);
        delay(5000);
        actuator.detach();
        for (int i=0;i<120;i++) delay(60000);
        cycle_complete = true;
     }
     delay(1000);
    }   
  }
  digitalWrite(LED,HIGH);
  delay(500);
  digitalWrite(LED,LOW);
  delay(500);
}


#include <Printers.h>
#include <SoftwareSerial.h>

#include <Servo.h> 
#include <Wire.h>
#include <EEPROM.h>
#include <math.h>
#include "IntersemaBaro.h"

//IntersemaBaro.h and subsequent calls to it are for calling the pressure from the pressure sensor

Intersema::BaroPressure_MS5607B baro(true);

SoftwareSerial XBee(2,3);

//These variables control timer and pressure thresholds. Change values here to control specific durations of steps.
//Time in minutes. Pressure in Pa (Val 0-100,000) -> 100,000 Pa = 1 atm
int time_arm_delay = 60*(60000);
int low_pressure_threshold = 13000;
int time_vent_closed_linger = 10*(60000);
int time_ballast_drop = 5*(60000);
int time_neutral_buoyancy = 30*60000;


Servo actuator;  // create servo objects to control the linear actuator
int actuator_pin = 12; //Actuator connected to digital pin 12
int linearValue = 1500;   //current positional value being sent to the linear actuator. 
int toggle = 2; //switch that controls whether switch is up or down if 'arm' is not set
int arm = 6; //switch that controls whether venting timer is initiated
int LED = 4; // LED connected to digital pin 4

//Open and closed values for actuators. Changing these values here will change 
//them in the rest of the code where they are called
int open = 1150;
int close = 1690;

int dT = 5; // time in seconds for dPdT calculations. Change it here to change
//it everywhere in the code where dT is used.


//These variables are used to calculate elapsed time, pressure, and dPdT
//for the opening of the valve when switch is in the armed position
long startTime;
int elapsedTime;
int32_t pressure;
int32_t pressure1;
int32_t pressure2;
int32_t dPdT;
double p2;
double p1;
double p;


boolean cycle_complete = false;
boolean vent_open = false;
boolean forever = true;



void setup() 
{ 
  Serial.begin(9600);
  XBee.begin(9600);
  //initializes the pressure sensor
  baro.init();
  //attaches the actuator and gives the range of position values
  actuator.attach(actuator_pin, 1050, 2000);
  
  //set the mode for the two switches and LED
  pinMode(toggle,INPUT_PULLUP);
  pinMode(arm,INPUT_PULLUP);
  pinMode(LED,OUTPUT);
} 

//Loop is comprised of two main components, corresponding to whether the armOn switch is primed or not.
//If armOn is HIGH, then the tglOn switch can be used to control the state of the valve (open or closed).
//Otherwirse, if armOn is LOW, the timer/pressure sensor trigger is armed. Once reaching optimal altitude,
//the vent will open. Once open, the pressure differential will be calculated and is used to determine whether
//to keep the valve open (when dPdT < 0), to close the vent (dPdT >= 0), and in the future to release ballast
//when dPdT > 0 

//LED flashes when trigger is not armed, and is solid when armed.

void loop() { 

  
  int armOn = digitalRead(arm);
  int tglOn = digitalRead(toggle);
  
  //TOGGLE switch in the UP & CLOSED position
  //ARMING switch in the DOWN position
  if(armOn == HIGH && tglOn == LOW){
    if(vent_open == false){
      actuator.attach(actuator_pin, 1050, 2000);
      actuator.writeMicroseconds(close);
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
      actuator.writeMicroseconds(open); 
      delay(1000);
      actuator.detach();
      vent_open = false;
    }
    else{     
    }
  }
  
  //ARMING switch in the UP position
  if(armOn == LOW){  
    digitalWrite(LED,HIGH);
    actuator.attach(actuator_pin, 1050, 2000);
    actuator.writeMicroseconds(close);
    delay(1000);
    actuator.detach();

    vent_open = false;

    
    startTime = millis();
    while(cycle_complete == false){
      p = (double)(baro.getHeightCentiMeters());
      p1 = ((p/0.897992)-9725.375344101109); //this step callibrates the pressure sensor values
      pressure = (uint32_t)(p1);

      
      if((double)(millis() - startTime) >= time_arm_delay || (int32_t)pressure <= low_pressure_threshold){ //3600000
        uint32_t p = pressure/1000;
        elapsedTime = (int)((millis()-startTime)/60000);
        //EEPROM.write(0,elapsedTime); //Records time in minutes
        //EEPROM.write(1,p); //Records pressure in kPa
        actuator.attach(actuator_pin, 1050, 2000);
        actuator.writeMicroseconds(open);
        delay(5000);
        actuator.detach();

        vent_open = true;

        
        while(forever == true){
          p = (double)(baro.getHeightCentiMeters());
          p1 = ((p/0.897992)-9725.375344101109);
          pressure1 = (uint32_t)(p1);

          delay(dT*1000);
          
          p = (double)(baro.getHeightCentiMeters());
          p1 = ((p/0.897992)-9725.375344101109);
          pressure2 = (uint32_t)(p1);



          
          dPdT = (pressure2-pressure1)/dT/4;
          Serial.print(dPdT);
          Serial.println('\n');
          Serial.print(pressure1);
          Serial.println('\n');
          Serial.print(pressure2);
          Serial.println('\n');
          
          //if dPdT < 0, pressure is decreasing and the balloon is rising. Keep vent open
          if(dPdT < 0 && vent_open == false){
            Serial.write("hold");
            actuator.attach(actuator_pin, 1050, 2000);
            actuator.writeMicroseconds(open);
            delay(5000);
            actuator.detach();
            
            //Tells the ballast system not to release any sand
            

            vent_open = true;
          }
          
          // if dPdT >= 0, pressure is staying constant or increasing. The balloon is either maintaining altitude or falling. Close vent.
          else if(dPdT >= 0 && vent_open == true){
            Serial.write("hold");
            actuator.attach(actuator_pin, 1050, 2000);
            actuator.writeMicroseconds(close);
            delay(5000);
            actuator.detach();
            
            
            //Tells the ballast system not to release any sand
            vent_open = false;
          }
          else if(dPdT > 0){
            Serial.write("drop");
            delay(5000);
            Serial.write("hold");
          }
          

          //When ballast system is rebuilt, add third criteria where dPdT > 0, pressure is increasing and balloon is falling. In this case ballast is released.
        }
        
        for (int i=0;i<120;i++) delay(60000);
        cycle_complete = true;
     }
     delay(1000);
    }   
  }

  //LED flashes when not armOn = HIGH
  digitalWrite(LED,HIGH);
  delay(500);
  digitalWrite(LED,LOW);
  delay(500);
}



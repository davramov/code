#include <Printers.h>
#include <SoftwareSerial.h>

#include <Servo.h>
#include <Wire.h>
#include <EEPROM.h>
#include <math.h>
#include "IntersemaBaro.h"

//IntersemaBaro.h and subsequent calls to it are for calling the pressure from the pressure sensor
//int in and int out refer to the relative position of the two pressure sensors inside and outside of the balloon
Intersema::BaroPressure_MS5607B baro(true);
int in = 8;
int out = 9;


SoftwareSerial XBee(2,3);

//These variables control timer and pressure thresholds. Change values here to control specific durations of steps.
//Time in minutes. Pressure in Pa (Val 0-100,000) -> 100,000 Pa = 1 atm
int time_arm_delay = 60*(60000);
int low_pressure_threshold = 13000;
int time_vent_closed_linger = 10*(60000);
int time_ballast_drop = 5*(60000);
int time_neutral_buoyancy = 30*(60000);


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
boolean neutral_buoyancy = false;


void setup()
{
  Serial.begin(9600);
  XBee.begin(9600);
  //initializes the pressure sensor
  baro.init();
  //attaches the actuator and gives the range of position values
  actuator.attach(actuator_pin, 1050, 2000);
  //Tells ballast system not to drop sand
  Serial.write("hold");
  //set the mode for the two switches and LED
  pinMode(toggle,INPUT_PULLUP);
  pinMode(arm,INPUT_PULLUP);
  pinMode(LED,OUTPUT);
  pinMode(in,OUTPUT);
  pinMode(out,OUTPUT);
  digitalWrite(in,LOW);
  digitalWrite(out,LOW);
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
    //LED light is solid
    digitalWrite(LED,HIGH);
    //Close the helium valve
    actuator.attach(actuator_pin, 1050, 2000);
    actuator.writeMicroseconds(close);
    delay(1000);
    actuator.detach();

    vent_open = false;

    //Initiate timer
    startTime = millis();
    while(cycle_complete == false){
      
      digitalWrite(out,HIGH);
      p = (double)(baro.getHeightCentiMeters());
      p1 = ((p/0.897992)-9725.375344101109); //this step callibrates the pressure sensor values
      pressure = (uint32_t)(p1);
      digitalWrite(out,LOW);
      Serial.print(pressure);
      //This if statement checks to see whether the time or pressure has
      //exceeded their relative thresholds. These values can be adjusted at the
      //top of the script
      if((double)(millis() - startTime) >= time_arm_delay || (int32_t)pressure <= low_pressure_threshold){ //3600000
        uint32_t p = pressure/1000;
        elapsedTime = (int)((millis()-startTime)/60000);
        //EEPROM.write(0,elapsedTime); //Records time in minutes
        //EEPROM.write(1,p); //Records pressure in kPa

        //The vent opens
        actuator.attach(actuator_pin, 1050, 2000);
        actuator.writeMicroseconds(open);
        delay(5000);
        actuator.detach();

        vent_open = true;
        neutral_buoyancy = false;

        while(neutral_buoyancy == false){
          digitalWrite(out,HIGH);
          p = (double)(baro.getHeightCentiMeters());
          p1 = ((p/0.897992)-9725.375344101109);
          pressure1 = (uint32_t)(p1);
          Serial.print(pressure1);
          Serial.println('\n');
          //modify dT variable at top of script
          delay(dT*1000);

          p = (double)(baro.getHeightCentiMeters());
          p1 = ((p/0.897992)-9725.375344101109);
          pressure2 = (uint32_t)(p1);
          digitalWrite(out,LOW);
          //modify dT variable at top of script
          dPdT = (pressure2-pressure1)/dT/4;


          if(dPdT < 0 && vent_open == false){
            //Tells the ballast system not to release any sand
            Serial.write("hold");

            //Opens the helium vent
            actuator.attach(actuator_pin, 1050, 2000);
            actuator.writeMicroseconds(open);
            delay(5000);
            actuator.detach();

            vent_open = true;
          }

          // if dPdT >= 0, pressure is staying constant or increasing.
          //The balloon is either maintaining altitude or falling.
          //Close vent, don't drop ballast
          else if(dPdT >= 0 && vent_open == true){
            //Tells the ballast system not to release any sand
            Serial.write("hold");

            //Closes the helium vent
            actuator.attach(actuator_pin, 1050, 2000);
            actuator.writeMicroseconds(close);
            delay(5000);
            actuator.detach();

            vent_open = false;
            neutral_buoyancy = true;
          }
        }

        delay(time_vent_closed_linger);
        Serial.write("drop");
        delay(time_ballast_drop);
        Serial.write("hold");

        startTime = millis();
        while(millis()-startTime < time_neutral_buoyancy){
          
          digitalWrite(out,HIGH);
          p = (double)(baro.getHeightCentiMeters());
          p1 = ((p/0.897992)-9725.375344101109);
          pressure1 = (uint32_t)(p1);

          //modify dT variable at top of script
          delay(dT*1000);

          p = (double)(baro.getHeightCentiMeters());
          p1 = ((p/0.897992)-9725.375344101109);
          pressure2 = (uint32_t)(p1);
          digitalWrite(out,LOW);
          //modify dT variable at top of script
          dPdT = (pressure2-pressure1)/dT/4;

          //if dPdT < 0, pressure is decreasing and the balloon is rising
          //Keep vent open, and don't drop ballast
          if(dPdT < 0 && vent_open == false){
            //Tells the ballast system not to release any sand
            Serial.write("hold");

            //Opens the helium vent
            actuator.attach(actuator_pin, 1050, 2000);
            actuator.writeMicroseconds(open);
            delay(5000);
            actuator.detach();

            vent_open = true;
          }

          // if dPdT >= 0, pressure is staying constant or increasing.
          //The balloon is either maintaining altitude or falling.
          //Close vent, don't drop ballast
          else if(dPdT >= 0 && vent_open == true){
            //Tells the ballast system not to release any sand
            Serial.write("hold");

            //Closes the helium vent
            actuator.attach(actuator_pin, 1050, 2000);
            actuator.writeMicroseconds(close);
            delay(5000);
            actuator.detach();

            vent_open = false;
          }
          else if(dPdT > 0){
            Serial.write("drop");
            delay(5000);
            Serial.write("hold");
          }
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

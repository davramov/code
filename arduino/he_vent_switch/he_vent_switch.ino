#include <Servo.h> 
#include <EEPROM.h>
//Defines
#define LINEARACTUATORPIN 12        //Linear Actuator Digital Pin



Servo LINEARACTUATOR;  // create servo objects to control the linear actuator
int linearValue = 1500;   //current positional value being sent to the linear actuator. 
int toggle = 2;
int LED = 4;
boolean vent_open_status = false;


void setup() 
{ 
  //initialize servo/linear actuator objects
  LINEARACTUATOR.attach(LINEARACTUATORPIN, 1050, 2000);      // attaches/activates the linear actuator as a servo object 
  pinMode(toggle,INPUT_PULLUP);
  //pinMode(LED,OUTPUT);

  //use the writeMicroseconds to set the linear actuators to their default positions
  LINEARACTUATOR.writeMicroseconds(1999);
  vent_open_status = false;
  
  
} 

void loop() { 

//  //use the writeMicroseconds to set the actuator to the new position

  int tglOn = digitalRead(toggle);
  
  if(vent_open_status == false){
    if(tglOn == LOW){
    
    }
    else if(tglOn == HIGH){
      LINEARACTUATOR.writeMicroseconds(1150);
      vent_open_status = true;
    }
  }
  
  else if(vent_open_status == true){
    if(tglOn == HIGH){
    }
    else if(tglOn == LOW){
      LINEARACTUATOR.writeMicroseconds(1900);
      vent_open_status = false;
    }
  }
} 


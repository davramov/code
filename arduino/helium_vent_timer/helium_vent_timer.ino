#include <Servo.h> 
//Defines
#define LINEAR_ACTUATOR_PIN 12        //Linear Actuator Digital Pin



Servo LINEAR_ACTUATOR;  // create servo objects to control the linear actuator
int linearValue = 1500;   //current positional value being sent to the linear actuator. 
int toggle = 2;
int LED = 4;

void setup() 
{ 
  //initialize servo/linear actuator objects
  LINEAR_ACTUATOR.attach(LINEAR_ACTUATOR_PIN, 1050, 2000);      // attaches/activates the linear actuator as a servo object 
  pinMode(toggle,INPUT_PULLUP);
  pinMode(LED,OUTPUT);
  for(int i = 0; i<5; i++){
    digitalWrite(LED,HIGH);
    delay(500);
    digitalWrite(LED,LOW);
    delay(500);
  }
  //Open
  LINEAR_ACTUATOR.writeMicroseconds(1150);
  
  //stay open for 2 minutes
  for (int i=0;i<2;i++) delay(60000);

  //Closed
  LINEAR_ACTUATOR.writeMicroseconds(1900);

} 

void loop() { 


  int tglOn = digitalRead(toggle);
  
  //Switch pointed TOWARDS LED
  if(tglOn == LOW){
    digitalWrite(LED,HIGH);
    //Closed
    LINEAR_ACTUATOR.writeMicroseconds(1900);
    //after switch, wait 1 hour
    for (int i=0;i<60;i++) delay(60000);

   //Open
    LINEAR_ACTUATOR.writeMicroseconds(1150);
    for (int i=0;i<120;i++) delay(60000);
    
  }

  //Switch pointed AWAY from LED
  else if(tglOn == HIGH){
    digitalWrite(LED,LOW);
    LINEAR_ACTUATOR.writeMicroseconds(1900);
    digitalWrite(LED,HIGH);
    delay(100);
    digitalWrite(LED,LOW);
    delay(100);
  }
  
} 


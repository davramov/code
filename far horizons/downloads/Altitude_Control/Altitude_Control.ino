/*
 
*/ 

#include <Servo.h> 
 
Servo myservo;  // create servo object to control a servo 
                // twelve servo objects can be created on most boards
 
int pos = 0;    // variable to store the servo position 
int i;
 
int toggle = 2; //digital pin for toggle
int LED = 4; //'ready' light
 
void setup() 
{ 
  pinMode(toggle,INPUT_PULLUP);
  pinMode(LED, OUTPUT);
 /* connect servo and set to "closed" position */
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object 

/* make sure spigot is "closed" */
for(i=0;i<20;i++) {myservo.write(110+i); delay(100);}


/* detach servo to avoid energy wasting "grinding" */
myservo.detach();

 
} 
 
void loop() 
{
int tglOn = digitalRead(toggle);
if(tglOn == LOW){
digitalWrite(LED,HIGH);
  
/* now wait for 45 minutes */
for (i=0;i<1;i++) delay(60000);


/* now open the spigot */

/* attach servo */
  myservo.attach(9);

/* open spigot */
  for(pos = 130; pos>=0; pos-=10)     // goes from 130 degrees to 0 degrees 
  {                                
    myservo.write(pos);              // tell servo to go to position in variable 'pos' 
    delay(100);                       // waits 100ms for the servo to reach the position 
  } 

/* let sand flow for 4 minutes */
for (i=0;i<4;i++) delay(60000);

/* now close spigot again */
  for(pos = 0; pos <= 130; pos += 5) // goes from 0 degrees to 130 degrees 
    {                                  // in steps of 5 degree 
      myservo.write(pos);              // tell servo to go to position in variable 'pos' 
      delay(100);                       // waits 100ms for the servo to reach the position 
    }   

/* and detach the servo so it won't "grind" */
  myservo.detach(); 
}
else{
/* just wait a lot */
myservo.detach();
}
delay(5000);
} 


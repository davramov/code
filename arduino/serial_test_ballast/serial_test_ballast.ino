#include <SoftwareSerial.h>
#include <Servo.h>
char c;
String control;
int LED = 8;
SoftwareSerial XBee(2,3);
Servo myservo;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  XBee.begin(9600);
//  pinMode(LED,OUTPUT);
  //control = drop;
  //XBee.write(drop);
}

void loop() {
  // put your main code here, to run repeatedly:
//
//  if (Serial.available()) {
//
//    Serial.write(Serial.read());
//  }
  
  if (Serial.available()){
    String reading = Serial.readString();
    reading.trim();
    if(reading == "drop"){
      
      
//      Serial.write("dropping ballast");
      myservo.attach(9);
      myservo.write(125);
      delay(2000);
      myservo.detach();
    }
    else if(reading == "hold"){
      
//      Serial.write("not dropping ballast");
      myservo.attach(9);
      myservo.write(0);
      delay(2000);
      myservo.detach();
    }
//    Serial.write(XBee.read());
  }

  
  

}

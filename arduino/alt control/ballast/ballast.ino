#include <Servo.h>

Servo myservo;  

void setup() {
  // put your setup code here, to run once:
myservo.attach(9);
myservo.write(0);
delay(10000);
myservo.write(125);
delay(10000);
myservo.detach();
}

void loop() {
  // put your main code here, to run repeatedly:

}

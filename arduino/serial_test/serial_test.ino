#include <SoftwareSerial.h>

char c;
SoftwareSerial XBee(2,3);


void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  XBee.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:

  if (Serial.available()) {

    XBee.write(Serial.read());
  }
  if (XBee.available()){
    Serial.write(XBee.read());
  }

}

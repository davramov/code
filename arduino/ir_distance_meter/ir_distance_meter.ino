int x;
void setup() {
  // put your setup code here, to run once:
Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  x = analogRead(2);
  Serial.println(x);
  analogWrite(2,0);
  analogWrite(3,0);
  analogWrite(4,0);
  analogWrite(5,0); 
  if(x<20){
    analogWrite(2,255);
  }
  if(x > 20 && x <100) {
    analogWrite(3,40);
  }
  if(x >100 && x < 300){
    analogWrite(4,255);
  }
  if(x >300){
    analogWrite(5,255);
  }
  
}

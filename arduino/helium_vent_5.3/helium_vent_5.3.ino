#include <Printers.h>
#include <SoftwareSerial.h>
#include <Servo.h>
#include <Wire.h>
//#include <EEPROM.h>
#include <SD.h>
#include <math.h>
#include "IntersemaBaro.h"

//IntersemaBaro.h and subsequent calls to it are for calling the pressure from the pressure sensor
Intersema::BaroPressure_MS5607B baro(true);

//used for SD card reader
const int chipSelect = 4;
int t;

//These variables control timer and pressure thresholds. Change values here to control specific durations of steps.
//Time in minutes. Pressure in Pa (Val 0-100,000) -> 100,000 Pa = 1 atm
int time_arm_delay = 60 * (60000);
int low_pressure_threshold = 13000;
int time_vent_closed_linger = 10 * (60000);
int time_ballast_drop = 5 * (60000);
int time_neutral_buoyancy = 30 * (60000);

Servo actuator;  // create servo objects to control the linear actuator
int actuator_pin = 8; //Actuator connected to digital pin 12
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
boolean ballast_drop = false;
boolean neutral_buoyancy = false;

void setup()
{
  Serial.begin(9600);
    
  baro.init(); //initializes the pressure sensor

  Serial.write("hold");   //Tells ballast system not to drop sand

  pinMode(toggle, INPUT_PULLUP);    //set the mode for the two switches and LED
  pinMode(arm, INPUT_PULLUP);
  pinMode(LED, OUTPUT);

  p = (double)(baro.getHeightCentiMeters());
  p1 = ((p / 0.897992) - 9725.375344101109);
  pressure = (uint32_t)(p1);

  File dataFile = SD.open("alt_control_datalog.txt", FILE_WRITE);
  dataFile.println("New Flight");
  dataFile.println("Time (ms); Pressure (Pa); vent_open; ballast_drop; neutral_buoyancy;");
  dataFile.print(millis() + "; ");
  dataFile.print(pressure + "; ");
  dataFile.print(vent_open + "; ");
  dataFile.print(ballast_drop + "; ");
  dataFile.print(neutral_buoyancy + "; ");
  dataFile.println();
  dataFile.close();
}

//Loop is comprised of two main components, corresponding to whether the armOn switch is primed or not.
//If armOn is HIGH, then the tglOn switch can be used to control the state of the valve (open or closed).
//Otherwise, if armOn is LOW, the timer/pressure sensor trigger is armed. Once reaching optimal altitude,
//the vent will open. Once open, the pressure differential will be calculated and is used to determine whether
//to keep the valve open (when dPdT < 0), to close the vent (dPdT >= 0), and in the future to release ballast
//when dPdT > 0

//LED flashes when trigger is not armed, and is solid when armed.

void loop()
{
  int armOn = digitalRead(arm);
  int tglOn = digitalRead(toggle);

  if (armOn == HIGH && tglOn == LOW) {  //TOGGLE switch in the UP & CLOSED position
    if (vent_open == false) {           //ARMING switch in the DOWN position
      actuator.attach(actuator_pin, 1050, 2000);
      actuator.writeMicroseconds(close);
      delay(1000);
      actuator.detach();
      vent_open = true;
    }
    else{}
  }

  else if (armOn == HIGH && tglOn == HIGH)  //TOGGLE switch in the DOWN & OPEN position
  { //ARMING switch in the DOWN position
    if (vent_open = true)
    {
      actuator.attach(actuator_pin, 1050, 2000);
      actuator.writeMicroseconds(open);
      delay(1000);
      actuator.detach();
      vent_open = false;
    }
    else{}
  }

  if (armOn == LOW)   //ARMING switch in the UP position
  {
    digitalWrite(LED, HIGH);  //LED light is solid
    actuator.attach(actuator_pin, 1050, 2000);  //Close the helium valve
    actuator.writeMicroseconds(close);
    delay(1000);
    actuator.detach();

    vent_open = false;
    ballast_drop = false;
    neutral_buoyancy = false;

    startTime = millis();   //Initiate timer

    while (cycle_complete == false)
    {
      t = (millis() - startTime) / 1000;
      p = (double)(baro.getHeightCentiMeters());
      p1 = ((p / 0.897992) - 9725.375344101109); //this step callibrates the pressure sensor values
      pressure = (uint32_t)(p1);

      File dataFile = SD.open("alt_control_datalog.txt", FILE_WRITE);
      if (dataFile)
      {
        dataFile.print(t + "; ");
        dataFile.print(pressure + "; ");
        dataFile.print(vent_open + "; ");
        dataFile.print(ballast_drop + "; ");
        dataFile.print(neutral_buoyancy + "; ");
        dataFile.println();
        dataFile.close();
      }

      //This if statement checks to see whether the time or pressure has
      //exceeded their relative thresholds. These values can be adjusted at the
      //top of the script
      if ((double)(millis() - startTime) >= time_arm_delay || (int32_t)pressure <= low_pressure_threshold)
      {
        uint32_t p = pressure / 1000;
        t = ((millis() - startTime) / 1000);
        p = (double)(baro.getHeightCentiMeters());
        p1 = ((p / 0.897992) - 9725.375344101109); //this step callibrates the pressure sensor values
        pressure = (uint32_t)(p1);

        dataFile = SD.open("alt_control_datalog.txt", FILE_WRITE);
        if (dataFile)
        {
          dataFile.print(t + "; ");
          dataFile.print(pressure + "; ");
          dataFile.print(vent_open + "; ");
          dataFile.print(ballast_drop + "; ");
          dataFile.print(neutral_buoyancy + "; ");
          dataFile.println();
          dataFile.close();
        }

        actuator.attach(actuator_pin, 1050, 2000); //The vent opens
        actuator.writeMicroseconds(open);
        delay(5000);
        actuator.detach();

        vent_open = true;
        neutral_buoyancy = false;
        ballast_drop = false;

        t = (millis() - startTime) / 1000;
        p = (double)(baro.getHeightCentiMeters());
        p1 = ((p / 0.897992) - 9725.375344101109); //this step callibrates the pressure sensor values
        pressure = (uint32_t)(p1);

        dataFile = SD.open("alt_control_datalog.txt", FILE_WRITE);
        if (dataFile)
        {
          dataFile.print(t + "; ");
          dataFile.print(pressure + "; ");
          dataFile.print(vent_open + "; ");
          dataFile.print(ballast_drop + "; ");
          dataFile.print(neutral_buoyancy + "; ");
          dataFile.println();
          dataFile.close();
        }

        while (neutral_buoyancy == false)
        {
          t = (millis() - startTime) / 1000;
          p = (double)(baro.getHeightCentiMeters());
          p1 = ((p / 0.897992) - 9725.375344101109);
          pressure1 = (uint32_t)(p1);
          Serial.print(pressure1);
          Serial.println('\n');

          dataFile = SD.open("alt_control_datalog.txt", FILE_WRITE);
          if (dataFile)
          {
            dataFile.print(t + "; ");
            dataFile.print(pressure1 + "; ");
            dataFile.print(vent_open + "; ");
            dataFile.print(ballast_drop + "; ");
            dataFile.print(neutral_buoyancy + "; ");
            dataFile.println();
            dataFile.close();
          }

          delay(dT * 1000); //modify dT variable at top of script

          t = (millis() - startTime) / 1000;
          p = (double)(baro.getHeightCentiMeters());
          p1 = ((p / 0.897992) - 9725.375344101109);
          pressure2 = (uint32_t)(p1);

          dataFile = SD.open("alt_control_datalog.txt", FILE_WRITE);
          if (dataFile)
          {
            dataFile.print(t + "; ");
            dataFile.print(pressure2 + "; ");
            dataFile.print(vent_open + "; ");
            dataFile.print(ballast_drop + "; ");
            dataFile.print(neutral_buoyancy + "; ");
            dataFile.println();
            dataFile.close();
          }

          dPdT = (pressure2 - pressure1) / dT / 4; //modify dT variable at top of script

          if (dPdT < 0 && vent_open == false)
          {
            Serial.write("hold"); //Tells the ballast system not to release any sand

            actuator.attach(actuator_pin, 1050, 2000); //Opens the helium vent
            actuator.writeMicroseconds(open);
            delay(5000);
            actuator.detach();

            vent_open = true;
            neutral_buoyancy = false;
            ballast_drop = false;
          }

          else if (dPdT >= 0 && vent_open == true)  // if dPdT >= 0, pressure is staying constant or increasing.
          { //The balloon is either maintaining altitude or falling.
            Serial.write("hold"); //Tells the ballast system not to release any sand
            
            actuator.attach(actuator_pin, 1050, 2000); //Closes the helium vent
            actuator.writeMicroseconds(close);
            delay(5000);
            actuator.detach();

            vent_open = false;
            neutral_buoyancy = true;
            ballast_drop = false;
          }
        }

        delay(time_vent_closed_linger);
        Serial.write("drop");

        vent_open = false;
        ballast_drop = true;
        
        t = (millis() - startTime) / 1000;
        p = (double)(baro.getHeightCentiMeters());
        p1 = ((p / 0.897992) - 9725.375344101109);
        pressure = (uint32_t)(p1);
        
        dataFile = SD.open("alt_control_datalog.txt", FILE_WRITE);
        if (dataFile)
        {
          dataFile.print(t + "; ");
          dataFile.print(pressure + "; ");
          dataFile.print(vent_open + "; ");
          dataFile.print(ballast_drop + "; ");
          dataFile.print(neutral_buoyancy + "; ");
          dataFile.println();
          dataFile.close();
        }

        delay(time_ballast_drop);
        Serial.write("hold");

        ballast_drop = false;

        int startTime_1 = millis();
        while (millis() - startTime_1 < time_neutral_buoyancy)
        {
          t = (millis() - startTime) / 1000;
          p = (double)(baro.getHeightCentiMeters());
          p1 = ((p / 0.897992) - 9725.375344101109);
          pressure1 = (uint32_t)(p1);
          
          dataFile = SD.open("alt_control_datalog.txt", FILE_WRITE);
          if (dataFile)
          {
            dataFile.print(t + "; ");
            dataFile.print(pressure1 + "; ");
            dataFile.print(vent_open + "; ");
            dataFile.print(ballast_drop + "; ");
            dataFile.print(neutral_buoyancy + "; ");
            dataFile.println();
            dataFile.close();
          }
               
          delay(dT * 1000); //modify dT variable at top of script

          t = (millis() - startTime) / 1000;
          p = (double)(baro.getHeightCentiMeters());
          p1 = ((p / 0.897992) - 9725.375344101109);
          pressure2 = (uint32_t)(p1);
          
          dataFile = SD.open("alt_control_datalog.txt", FILE_WRITE);
          if (dataFile)
          {
            dataFile.print(t + "; ");
            dataFile.print(pressure2 + "; ");
            dataFile.print(vent_open + "; ");
            dataFile.print(ballast_drop + "; ");
            dataFile.print(neutral_buoyancy + "; ");
            dataFile.println();
            dataFile.close();
          }
          
          dPdT = (pressure2 - pressure1) / dT / 4; //modify dT variable at top of script

          if (dPdT < 0 && vent_open == false) //if dPdT < 0, pressure is decreasing and the balloon is rising
          { //Keep vent open, and don't drop ballast
            Serial.write("hold"); //Tells the ballast system not to release any sand
            
            actuator.attach(actuator_pin, 1050, 2000); //Opens the helium vent
            actuator.writeMicroseconds(open);
            delay(5000);
            actuator.detach();

            vent_open = true;
            ballast_drop = false;
            neutral_buoyancy = false;
          }
          
          else if (dPdT >= 0 && vent_open == true) // if dPdT >= 0, pressure is staying constant or increasing.
          { //The balloon is either maintaining altitude or falling
            Serial.write("hold"); //Tells the ballast system not to release any sand
            
            actuator.attach(actuator_pin, 1050, 2000); //Closes the helium vent
            actuator.writeMicroseconds(close);
            delay(5000);
            actuator.detach();

            vent_open = false;
            ballast_drop = false;
            neutral_buoyancy = true;
          }
          else if (dPdT > 0) {
            Serial.write("drop");
            ballast_drop = true;
            delay(5000);
            Serial.write("hold");
            ballast_drop = false;
          }
        }

        for (int i = 0; i < 120; i++) delay(60000);
        cycle_complete = true;
      }
      delay(1000);
    }
  }
  digitalWrite(LED, HIGH); //LED flashes when not armOn = HIGH
  delay(500);
  digitalWrite(LED, LOW);
  delay(500);
}

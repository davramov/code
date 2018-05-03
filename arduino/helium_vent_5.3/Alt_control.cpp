#include "Arduino.h"
#include "Alt_control.h"

Controller::Controller()
{
  int open_actuator = 1150;
  int close_actuator = 1690;
  int actuator_pin = 8;
}

void Controller::drop_ballast()
{

}

void Controller::hold_ballast()
{

}

void Controller::open_vent()
{
  actuator.attach(actuator_pin, 1050, 2000);
  actuator.writeMicroseconds(open_actuator);
  delay(1000);
  actuator.detach();
  vent_open = false;
}

void Controller::close_vent()
{
  actuator.attach(actuator_pin, 1050, 2000);
  actuator.writeMicroseconds(close_actuator);
  delay(1000);
  actuator.detach();
  vent_open = true;
}

void Controller::save_pressure()
{
  dataFile = SD.open("alt_control_datalog.txt", FILE_WRITE);

  if (dataFile)
  {
    dataFile.println(pressure);
    dataFile.println(t);
    dataFile.close();
  }

}

void Controller::dPdT()
{

}


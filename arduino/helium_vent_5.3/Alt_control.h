#ifndef Alt_control_h
#define Alt_control_h

#include "Arduino.h"

class Altitude_control
{
  public:
    void drop_ballast();
    void hold_ballast();
    void helium_vent();
    void helium_closed();
    void save_pressure();
    void dPdT();
        
  private:
}



#endif

OBJ

  pst   : "Parallax Serial Terminal"
  alt   : "29124_altimeter"

CON

  _clkmode      = xtal1 + pll16x  ' Change to xtal1 + pll8x for Propeller Backpack.
  _xinfreq      = 5_000_000       ' Change to 10_000_000    for Propeller Backpack.

  START_ALT     = 200             ' Your starting altitude in feet.

PUB start | a

  pst.start(115200)                                       ' Start Parallax serial terminal.
  alt.start(alt#QUICKSTART, alt#BACKGROUND)              ' Start altimeter for QuickStart with background processing.
  alt.set_resolution(alt#HIGHEST)                        ' Set to highest resolution.
  alt.set_altitude(alt.m_from_ft(START_ALT * 100))       ' Set the starting altitude, based on average local pressure.                  
  repeat
    a := alt.altitude(alt.average_press)                 ' Get the current altitude in cm, from new average local pressure.
    pst.str(string(pst#HM, "Altitude:"))                 ' Print header.
    pst.str(alt.formatn(a, alt#METERS | alt#CECR, 8))    ' Print altitude in meters, clear-to-end, and CR.
    pst.str(alt.formatn(a, alt#TO_FEET | alt#CECR, 17))  ' Print altitude in feet, clear-to-end, and CR.
    if (pst.rxcount)                                     ' Respond to any key by clearing screen.
      pst.rxflush
      pst.char(pst#CS)
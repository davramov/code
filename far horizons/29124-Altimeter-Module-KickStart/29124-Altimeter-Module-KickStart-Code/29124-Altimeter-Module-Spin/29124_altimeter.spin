'':::::::[ 29124 Altimeter Module Driver ]::::::::::::::::::::::::::::::::::::::::
{{
'''┌───────────────────────────────────────┐
'''│     29124 Altimeter Module Driver     │
'''│   (c) Copyright 2011 Parallax, Inc.   │
'''│   See end of file for terms of use.   │
'''└───────────────────────────────────────┘

This object provides the drivers necessary to read data from the Parallax #29124
Altimeter Module, along with the computation necessary to convert the readings
to temperature, pressure, and altitude. In addition to a foreground aqcuisitionmode,
it provides a selectable background mode in which data are acquired, converted, and
averaged continuously. Also provided are units conversion and string formatting to
ease the recording and/or display of the acquired data.
''
'' `SPECIAL `DISCLAIMER
''
This object is provided to demonstrate the capabilities of the Parallax 29124 Altimeter
module and the Measurement Specialities sensor. NO CLAIMS ARE MADE FOR ACCURACY, AND IT
MUST NOT BE RELIED UPON FOR AVIATION OR NAVIGATION APPLICATIONS OR TO PROVIDE ACCURATE
WEATHER FORECASTING, AND IT MUST NOT BE USED IN MEDICAL APPLICATIONS. Consult the appropriate
Measurement Specialties datasheets and appnotes for the details necessary to provide your
own firmware for any applications of their sensors that might entail risk to life, limb,
or property as a result of inaccurate readings or malfunction. This Special Disclaimer
supplements the "AS-IS" provision of the MIT License at the end of this file and and does
not replace it.
''
'' `Note `Regarding `Sensor `Chips
''
This object defaults to computations for the MS5607 sensor. If the MS5211 sensor is used
instead, see the `start or `start_explicit method for how to specify this alternative.
'''
'' `Revision `History
''
'' 2011.09.20: v1.0  Initial release.
'' 2011,09.21: v1.01
''   Added CECR to formatting (clear-to-end+CR for PST), and some constants.
''   Added `set_altitude macro method.
''   Added wait in `set_resolution to make sure new resolution percolated through samples.
'''
'' `Contact `Information
''
'' Parallax Tech Support: support@parallax.com (916-624-8333)
}}

''=======[ Introduction ]=========================================================

{{ The Parallax #29124 Altimeter Module uses the Measurement Specialties MS5607 or
   MS5611 digital thermometer/pressure sensor, which is capable of both SPI and I²C
   communication. This module provides the necessary I²C drivers, along with the
   following:
''
''   • The math necessary to compute temperature in degrees C and temperature-
'-     compensated pressure from the sensor's readings and internal calibration
'-     constants.
''   • Integer-based methods for converting pressure to altitude and altitude and
'-     pressure to an equivalent sea-level pressure.
''   • Built-in computation of average and median temperature and pressure.
''   • Choice of foreground or background data acquisition. Background acquisition
'-     requires its own cog and does running average and median computations for
''     quicker access to results.
''   • Methods to convert between Inches of Hg and Millibars, Feet and Meters, and
'-     Celsius and Fahrenheit.
''   • String formatting methods to make presentation of the results easier.
''
'''
   All measurement units used in this object are in integer hundredths; so, for
   example a temperature measurement of 2543 would represent 25.43 degrees.
''
   To use this module, it must first be started using one of the start methods.
   After that the various other acquisition, conversion, and formatting methods can
   be employed to obtain and, optionally, to massage the results for presentation
   or recording.    
}}

''=======[ External Connections ]=================================================

{{ The chip drivers in this object use I²C exclusively, which means that only four
   of the module's available seven pins need to be connected:

'''   ┌────────────────┐
'''   │  #29124    CS •│ N/C
'''   │           SDO •│ N/C
'''   │   ┌─┐     SDA •│ I²C serial data (SDA)
'''   │   │ │     SCL •│ I²C serial clock (SCL)
'''   │   └─┘      PS •│ N/C
'''   │ Altimeter VIN •│ 2.7 - 5.0VDC (Module is regulated to 2.5VDC.)
'''   │  Module   GND •│ Logic ground (Vss)
'''   └────────────────┘

   The voltage going to the VIN pin should equal Vdd for the chip connected to
   the module, since all outputs are pulled up internally to that voltage.
   Both SCL and SDA are pulled up internally, so external pull-ups are optional.
''
   Two start methods are provided: a convenience method for several of Parallax's
   Propeller development boards, and one to which explicit pinout information can be
   provided. The default setups for the supported Propeller development boards are
   shown below.
''
'' `Propeller `Demo `Board:

   The module is assumed to be plugged directly into the header connector strip
   as shown below, overhanding the solderless breadboard. It is powered through the
   P7 pin.

'''                  │=│ 5V
'''   Solderless     │=│ Vdd
'''   Breadboard     │=│ Vdd
'''                  │=│ P0
'''   ┌──────────────┴─┤ P1
'''   │  #29124    CS •│ P2
'''   │           SDO •│ P3
'''   │   ┌─┐     SDA •│ P4
'''   │   │ │     SCL •│ P5
'''   │   └─┘      PS •│ P6
'''   │ Altimeter VIN •│ P7
'''   │  Module   GND •│ Vss
'''   └──────────────┬─┤ Vss

'' `P8X32A `QuickStart `Board:

   The module is assumed to be plugged directly into the inside row of the header
   connector strip at the very left-hand end (top in the illustration below). The
   P10 pin provides power; P12, a ground return.

''' ┌───┐
''' ┤   ├──────────────────┐
''' │   │ ← USB Connector  │
''' └───┘                  │
'''                        │
'''   ┌────────────────┬─┐ │
'''   │  #29124    CS •│=│ │  P0:P1
'''   │           SDO •│=│ │  P2:P3
'''   │   ┌─┐     SDA •│=│ │  P4:P5
'''   │   │ │     SCL •│=│ │  P6:P7
'''   │   └─┘      PS •│=│ │  P8:P9
'''   │ Altimeter VIN •│=│ │ P10:P11
'''   │  Module   GND •│=│ │ P12:P13
'''   └──────────────┬─┘=│ │
'''                  │= =│ │
'''                  │= =│ │
'''                  │= =│ │
'''                  │= =│ │

'' `Spinneret, `Propeller `Backpack, `and `MoBoProp

   The Spinneret, Propeller Backpack, and MoBoProp have daughterboard connectors into
   which a Parallax Proto-DB can be plugged. The easiest way to connect the altimeter
   module to the Proto-DB is as follows:

'''                Top View
'''  ┌──────────────────────────────────┐
'''  │             Proto-DB             │
'''  │                                  │
'''  │                                  │
'''  │ ••                               │
'''  │ •• ← Motherboard Connector       │
'''  │ ••   on bottom                   │
'''  │ ••                               │
'''  │ ••       ┌────────────────┐      │
'''  │ ••       │  #29124    CS •│      │
'''  │          │           SDO •│      │
'''  │    E•→SCL│   ┌─┐     SDA •│      │
'''  │    F•→SDA│   │ │     SCL •│      │
'''  │  Vdd•┐   │   └─┘      PS •│      │
'''  │      ┻───│ Altimeter VIN •│-Vdd  │
'''  │  Gnd ────│  Module   GND •│-Gnd  │
'''  └──────────┴────────────────┴──────┘

   Be sure to make the connection between the Vdd pad and its corresponding bus. Also note that
   the SCL and SDA wires cross over each other to make their connections to the E and F pads.
''
   For the Propeller Backpack, SCL and SDA will correspond to P4 and P5, respectively.
''
   For the MoBoProp "A" socket, SCL and SDA will correspond to P12 and P13, respectively.
   For the "B" socket, the pins are P4 and P5, the same as for the Backpack.
''
   For the Spinneret board, SCL is P28, and SDA is P29, the same as they are assigned to the EEPROM.
   Since the altimeter chip uses a different device address from that of the EEPROM, there is
   no address conflict. However, care must be taken not to address both at the same time from
   two different cogs. If a running Spinneret program must address the EEPROM, it will be necessary
   to run this object in foreground mode only. If this is a problem, the wires can be shifted to
   a different pair of motherboard pins.
}}


''=======[ Constants... ]==========================================================

CON

  ''-[ Chip Selection ]-

  {{ These constants are use to select between the two Measurement Systems sensor chips.
     Either can be bitwise ORed with the module parameter for `start or either pin
     assignment for `start_explicit.
  }}

  MS5607           = $00
  MS5611           = $80

  ''-[ Background vs. Foreground ]-

  {{ These constants are used with the start methods to choose between background (separate
     cog taking and averaging samples) or foreground (samples taken and averaged on request)
     modes of operation.
  }}

  BACKGROUND       = true
  FOREGROUND       = false

  ''-[ Default Module Settings ]-
  
  {{ These constants can be used with the `start method to predefine default power
     and control pin setups for various Propeller modules. They are defined as follows:

'''   Byte3 Byte2 Byte1 Byte0
'''  ┌─────┬─────┬─────┬─────┐
'''  │ Vdd │ Vss │ SCL │ SDA │
'''  └─────┴─────┴─────┴─────┘

     Each byte contains a pin number for its associated signal. If either of Vdd or Vss
     are not provided by a Propeller pin, $ff is given as the pin number. The module
     constant can also be bitwise ORed with the constant `MS5611 to select that alternate
     sensor chip.
  }} 

  DEMO_BOARD       = $07ff_0504
  QUICKSTART       = $0a0c_0604
  SPINNERET        = $ffff_1c1d
  BACKPACK         = $ffff_0405
  MOBO_A           = $ffff_0c0d
  MOBO_B           = $ffff_0405

  ''-[ I²C Commands ]-

  {{ These constants provide address and command byte values for the sensor.
  }}

  DEVICE_ADDR      = $ec
  DEVICE_READ      = $01             

  CMD_READ_ADC     = $00
  CMD_RESET        = $1e             
  CMD_CONV_ADC     = $40
  CMD_READ_PROM    = $a0

  RSLT_D1          = $00
  RSLT_D2          = $10

  RES_256          = $00
  RES_512          = $02
  RES_1024         = $04
  RES_2048         = $06
  RES_4096         = $08

  LOWEST           = RES_256
  LOW              = RES_512
  MEDIUM           = RES_1024
  HIGH             = RES_2048
  HIGHEST          = RES_4096

  ACK              = true
  NAK              = false

  ''-[ Standard Pressure ]-

  {{ This is the standard pressure at sea-level in hundredths of a millibar.
  }}             

  SEA_PRESS_STA    = 101325

  ''-[ Array sizes ]-

  {{ These determine how many samples to average and how much space to use
     for the string buffer.
  }}

  N_SAMP           = 33         'Number of samples for average and median calulations (must be odd).
  MAX_LEN          = 64         'Size of string constructor array in bytes.

  ''-[ Results Array Indices ]-

  {{ These provide general acces to the results array in the hub when the array
     address is known.
  }}

  #0, SEA_P, CUR_T, CUR_P, AVG_T, AVG_P, MED_T, MED_P, SUM_T, SUM_P, SAM_T
  SAM_P            = SAM_T + N_SAMP

  ''-[ String Constants ]-

  {{ These can be provided to the general conversion routine and to the string
     formatting routines.
  }}            

  ' Bitwise OR one of the following to determine a conversion and/or add the
  ' corresponding units designator to a formatted string.

  #0, NONE, MILLIBARS, INCHES, METERS, FEET, DEGC, DEGF

  CONV             = $10  ' Bitwise OR to force a conversion before formatting.

  TO_INCHES        = CONV | INCHES
  TO_METERS        = CONV | METERS
  TO_FEET          = CONV | FEET
  TO_MILLIBARS     = CONV | MILLIBARS
  TO_DEGF          = CONV | DEGF
  TO_DEGC          = CONV | DEGC
  
  ' Bitwise OR one of the following to add the indicated
  ' character at the end of the formatted string.
  
  CR               = $20  
  LF               = $40
  CRLF             = $60               
  COMMA            = $80
  SPACE            = $a0
  TAB              = $c0
  CECR             = $e0               

''=======[ Instance Variables ]====================================================

{{ These variables are replicated for each instance of the object.
}}

VAR

  long sea_press, cur_temp, cur_press, avg_temp, avg_press, med_temp, med_press, sum_temp, sum_press
  long temp_samples[N_SAMP], press_samples[N_SAMP]
  long stack[50], adc_delay, sample_count
  word c1, c2, c3, c4, c5, c6, ptr, str_index, buf_index 
  byte sda, scl, resolution, started, lock, locked, samp_temp, samp_press, dev5611
  byte buffer[MAX_LEN]

''=======[ Public Spin Methods... ]================================================

''-------[ Start, Stop, Pause... ]-------------------------------------------------

{{ This group of methods starts and stops the object and allows one to pause and resume
   the background data acquisition if it's running.
}}

PUB start(module, bkgnd) | port

  {{ Start the object using one of the default pinouts given in the CONstants section.
  ''
  '' `Parameters:
  ''
  ''     `module: One of the constants given in the "Default Module Settings" section.
  '-              Can be bitwise ORed with the constant `MS5611 to use that chip.
  ''     `background: `true to start a background acquisition, `false not to.
  ''
  '' `Return: 255 or the cogid + 1 of the background process on success, 0 on failure. 
  ''
  '' `Example: success := alt.start(alt#DEMO_BOARD, true)
  ''
  ''     Start the object using the default Propeller Demo Board pinout, and start a
  '-     background process. (The background process uses one additional cog and one lock.)
  '-     Assign the return value to the variable `success.
  }}

  if ((port := byte[@module][2]) =< $1f)
    dira[port]~~
  if ((port := byte[@module][3]) =< $1f)
    outa[port]~~
    dira[port]~~
  return start_explicit(byte[@module][1], byte[@module], bkgnd)

PUB start_explicit(sc, sd, bkgnd) | i

  {{ Start the object using a prescribed pinout for SCL and SDA.
  ''
  '' `Parameters:
  ''
  ''     `sc: Pin number for SCL. Can be bitwise ORed with the constant `MS5611 to use that chip.
  ''     `sd: Pin number for SDA. Can be bitwise ORed with the constant `MS5611 to use that chip.
  ''     `background: `true to start background acquisitions, `false not to.
  ''
  '' `Return: 255 or the cogid + 1 of the background process on success, 0 on failure.
  ''
  '' `Example: alt.start_explicit(7, 8 | alt#MS5611, false)
  ''
  ''     Start the object using P7 for SCL and P8 for SDA, but do not start a  background
  '-     process. Use the MS5611 chip, rather than the default MS5607
  }}

  stop
  sea_press := SEA_PRESS_STA
  set_resolution(RES_1024)
  scl := sc & $1f
  sda := sd & $1f
  dev5611 := (sc | sd) & $80
  ptr~
  _i2c_init
  _i2c_send_cmd(CMD_Reset)
  waitcnt((clkfreq >> 3 #> 400) + cnt)
  repeat i from 0 to 5
    c1[i] := _read_prom(i + 1)
  started~~
  samples
  if (bkgnd)
    if (lock := locknew + 1)
      ifnot (started := cognew(_do_background, @stack) + 1)
        lockret(lock - 1)
  return started

PUB stop

  {{ Stop the object and any background process that was started, and return its lock
     to the lock pool.
  ''
  '' `Return: none
  ''
  '' `Example: alt.stop
  ''
  ''     Stop the object.
  }}

  if (started)
    if (lock)
      cogstop(started - 1)
      lockret(lock - 1)
    started~

PUB pause

  {{ If a background process is running, wait for it to complete its current sample
     then pause it until `resume is called. Doing so before taking readings guarantees
     that all readings come from the same set of samples.
  ''
  '' `Return: none
  ''
  '' `Example: alt.pause
  ''
  ''     Pause the background process so coherent readings can be acquired.
  }}

  if (lock and not locked)
    repeat while lockset(lock - 1)
    locked~~

PUB resume

  {{ Resume the background process after a `pause.
  ''
  '' `Return: What gets returned, or 'none'.
  ''
  '' `Example: alt.resume
  ''
  ''     Resume the background process.
  }}

  if(lock and locked)
    lockclr(lock - 1)
    locked~

''-------[ Calibration... ]-------------------------------------------------------

{{ These methods set the resolution of the sensor readings and calibrate the
   altitude readings against a known sea-level-equivalent pressure, or altitude
   and pressure against a known starting altitude.
}}    

PUB set_resolution(resol) | i

  {{ Set the sensor resolution. The higher the resolution, the more precise the
     readings will be, but the longer it will take to acquire them, particularly
     in foreground mode. The default resolution on start-up is RES_1024. This
     method can be called on the fly at any time to change from the default.
  ''
  '' `Parameters:
  ''
  ''     `resol: One of RES_256, RES_512, RES_1024, RES_2048, or RES_4096
  ''
  '' `Return: none
  ''
  '' `Example: alt.set_resolution(alt#RES_4096)
  ''
  ''     Set the sensor to its highest resolution.
  }}

  if (i := lookdown(resol: RES_256, RES_512, RES_1024, RES_2048, RES_4096))
    resolution := resol
    adc_delay := clkfreq / lookup(i: 1000, 333, 250, 166, 100) #> 400
    if (lock)
      sample_count~
      repeat until sample_count => N_SAMP
    else
      samples
      
PUB set_altitude(cm) : sp

  {{ Set the current altitude, based on the argument given, and the average
     local pressure. This macro function changes the set sea-level pressure.
  ''
  '' `Parameters:
  ''
  ''     `cm: Current altitude in wole centimeters (hundredths of a meter).
  ''
  '' `Return: Computed sea_level pressure in hundredths of a millibar.
  ''
  '' `Example: alt.set_altitude(alt.m_from_ft(43200))
  }}

  set_sealevel_press(sp := sealevel_press(average_press, cm))      

PUB set_sealevel_press(mb)

  {{ Set the equivalent sea-level pressure at the current location in order to
     provide altitude corrections.
  ''
  '' `Parameters:
  ''
  ''     `mb: Equivalent sea-level pressure in hundredths of a millibar.
  ''
  '' `Return: none
  ''
  '' `Example: alt.set_sealevel_press(alt.mb_from_in(3004))
  ''
  ''     Set the equivalent sea-level pressure to 30.04 inches of Hg.
  }}

  sea_press := mb

''-------[ Result Accessors... ]--------------------------------------------------

{{ These methods provide the main data interface to the sensor and are used to
   obtain temperature and pressure data and to perform computations involving
   altitude and equivalent sea-level pressure.
}}

PUB results_addr(index)

  {{ Return the address of a particular item in the results array, using one of
     the indexing constants given in the CONstants section. (If index is zero,
     the base address of the array is returned.)
  ''
  '' `Parameters:
  ''
  ''     `index: An index into the array (or zero).
  ''
  '' `Return: The address of the selected result.
  ''
  '' `Example: res_addr := alt.results_addr(0)
  ''
  ''     Assign the hub address of the results array to the word variable `res_addr.
  }}

  return @sea_press[index]

PUB results(index)

  {{ Obtain a particular value from the results array by indexing.
  ''
  '' `Parameters:
  ''
  ''     `index: An index into the array given in the CONstants section above.
  ''
  '' `Return: The result value at that index.
  ''
  '' `Example: avg_pressure := alt.results(alt#AVG_P)
  ''
  ''     Obtain the latest reading for the average pressure in hundredths of a millibar.
  }}

  return sea_press[index]

PUB sealevel_press(mb, cm) | sp_save, dmb, alt

  {{ Given a pressure reading and a known altitude, return the equivalent
     pressure reading at sea-level. (The sea-level pressure is obtained by performing
     a binary search on the altitudes at various sea-level pressure settings.)
  ''
  '' `Parameters:
  ''
  ''     `cm: Altitude in centimeters (hundredths of a meter).
  ''
  '' `Return: The equivalent sea-level air pressure for this location.
  ''
  '' `Example: sealevel_pressure := alt.sealevel_press(102013, alt.m_from_ft(502000))
  ''
  ''     Using a pressure reading of 1020.13 mb, and an altitude of 5020.00 feet,
  '-     return the equivalent pressure at sea-level and assign it to the long variable
  '-     `sealevel_pressure.
  }}

  sp_save := sea_press
  sea_press := 1 << 16
  dmb := 1 << 15
  repeat
    if ((alt := altitude(mb)) == cm)
      quit
    elseif (alt < cm)
      sea_press += dmb
    else
      sea_press -= dmb
  while dmb >>= 1
  mb := sea_press
  sea_press := sp_save
  return mb
  
PUB altitude(mb) : alt | i, p, p2, x, qm, q0, q1, q2

  {{ Given the local pressure in hundredths of a millibar and the predetermined air pressure
     at sealevel, return the current altitude in centimeters (hundredths of a meter).
  ''
  '' `Parameters:
  ''
  ''     `mb: Pressure reading in hundredths of a millibar.
  ''
  '' `Return: What gets returned, or 'none'.
  ''
  '' `Example: Sample method call.
  ''
  ''     Explain what the sample call does.
  '-     Next lines, if needed...
  }}

  'Correct the local pressure for the pressure at sea-level:
  
  mb := ((_umultdiv(mb, constant(SEA_PRESS_STA << 2), sea_press) >> 1 + 1) >> 1) <# $1_f7ff #> $800

  'Compute an index into the table, plus fractional values for interpolation:
  
  i := mb >> 11
  p := mb & $7ff
  p2 := p * p

  'Copy the four table values surrounding the pressure into the local variables:
  
  longmove(@qm, @alt_table[i - 1], 4)

  'Compute the altitude using cubic interpolation:
  
  alt := (qm << 1) - 5 * q0 + (q1 << 2) - q2
  alt := (p2 ** alt) << 9 + (p2 * alt) >> 23 + (p2 ** (p * (3 * (q0 - q1) + q2 - qm))) ~> 2 +  (p * (q1 - qm)) ~> 12 + q0

PUB current_temp

  {{ Return the current instantaneous temperature value in hundredths of a degree Celsius. If operating in
     foreground mode and if there was a previous call to obtain a temperature, an entire new set of readings
     will be taken before this method returns.
  ''
  '' `Return: Current instantaneous temperature reading in hundredths of a degree Celsius.
  ''
  '' `Example: deg_f := alt.f_from_c(current_temp) / 100
  ''
  ''     Assign the current instantaneous temperature reading in whole degrees Fahrenheit to the
  '-     variable `deg_f.
  }}

  _get_temp
  return cur_temp

PUB current_press

  {{ Return the current instantaneous pressure value in hundredths of a millibar. If operating in
     foreground mode and if there was a previous call to obtain a pressure, an entire new set of readings
     will be taken before this method returns.
  ''
  '' `Return: current instantaneous pressure reading in hundredths of a millibar.
  ''
  '' `Example: mb := alt.current_press / 100
  ''
  ''     Assign the current instantaneous pressure readin in shole millibars to the variable `mb.
  }}

  _get_press
  return cur_press

PUB median_temp

  {{ Return the median temperature value in hundredths of a degree Celsius. The median temperature is the
     middle reading of the group of N_SAMP samples. If operating in foreground mode and if there was a
     previous call to obtain a temperature, an entire new set of readings will be taken before this method
     returns; otherwise, the value already saved will be returned instead. If operating in background mode,
     the value returned will be a running median based on the most recent N_SAMP samples, which may include
     samples used from a previous call to this method.
  ''
  '' `Return: Median temperature value in hundredths of a degree Celsius.
  ''
  '' `Example: deci_c := alt.median_temp / 10
  ''
  ''     Assign the median temperature in tenths of a degree Celsius to the variable `deci_c.
  }}

  _get_temp
  return med_temp

PUB median_press

  {{ Return the median pressure value in hundredths of a millibar. The median pressure is the
     middle reading of the group of N_SAMP samples. If operating in foreground mode and if there was a
     previous call to obtain a pressure, an entire new set of readings will be taken before this method
     returns; otherwise, the value already saved will be returned instead. If operating in background
     mode, the value returned will be a running median based on the most recent N_SAMP samples, which may
     include samples used from a previous call to this method.
  ''
  '' `Return: Median pressure value in hundredths of a millibar.
  ''
  '' `Example: pressure := alt.convert(alt.median_press, alt#INCHES)
  ''
  ''     Read the median pressure, convert it to hundredths of an inch, and assign to the variable `pressure.
  }}

  _get_press
  return med_press

PUB average_temp

  {{ Return the average temperature value in hundredths of a degree Celsius. The average temperature is the
     sum of the group of N_SAMP samples, divided by N_SAMP. If operating in foreground mode and if there was a
     previous call to obtain a temperature, an entire new set of readings will be taken before this method
     returns; otherwise, the value already saved will be returned instead. If operating in background mode,
     the value returned will be a running average based on the most recent N_SAMP samples, which may include
     samples used from a previous call to this method.
  ''
  '' `Return: Average temperature value in hundredths of a degree Celsius
  ''
  '' `Example: temp := alt.convert(alt.average_temp, alt#DEGF) / 100
  ''
  ''     Assign the average temperature, in whole degress Fahrenheit, to the variable `temp.
  }}

  _get_temp
  return avg_temp

PUB average_press

  {{ Return the average pressure value in hundredths of a millibar. The average pressure is the
     sum of the group of N_SAMP samples, divided by N_SAMP. If operating in foreground mode and if there was a
     previous call to obtain a pressure, an entire new set of readings will be taken before this method
     returns; otherwise, the value already saved will be returned instead. If operating in background mode,
     the value returned will be a running average based on the most recent N_SAMP samples, which may include
     samples used from a previous call to this method.
  ''
  '' `Return: Average pressure value in hundredths of a millibar.
  ''
  '' `Example: mb := alt.average_press
  ''
  ''     Assign the average pressure in hundredths of a millibar to the variable `mb.
  }}

  _get_press
  return avg_press

PUB sample

  {{ Take a single sample reading of temperature and pressure and merge it into the running
     average and median computation. This method is valid only in foreground mode. In
     background mode, samples are being taken continuously.
  ''
  '' `Return: none
  ''
  '' `Example: alt.sample
  ''
  ''     Take one instantaneous sample reading
  }}

  ifnot (lock)
    _sample
    samp_temp~~
    samp_press~~

PUB samples

  {{ Obtain N_SAMP consecutive samples, separated by more than 10 ms. between samples. One call
     to samples will flush and recompute from scratch the average and median values of
     temperature and pressure. This method is valid only in foreground mode. In background mode,
     samples are being taken continuously.
  ''
  '' `Return: none
  ''
  '' `Example: alt.samples
  ''
  ''     Obtain N_SAMP new data samples and compute their average and median values.
  }}

  ifnot(lock)
    repeat N_SAMP
      _sample
      waitcnt(((clkfreq / 100 #> 400)+ cnt))
    samp_temp~~
    samp_press~~

''-------[ Output Formatting... ]-------------------------------------------------

{{ These methods are provided as a convenience for those wanting to convert readings to strings
   for display or for saving in an ASCII text data file.
}}

PUB formatn(value, units, width) | t_val, field

  {{ Format a number given in hundredths as a signed-decimal string, optionally converted to
     other units, and optionally followed by a units designator and delimiter. Return a pointer
     to a TEMPORARY string. The lifetime of the returned string is finite, so it must either be used
     right away or be copied to another byte array using `bytemove. See the CONstants section for
     values that can be used in the `units parameter. 
  ''
  '' `Parameters:
  ''
  ''     `value: The value, in hundredths to convert to a string.
  ''     `units: A byte that determines the units to print and possibly convert to, along with a delimiter.
  ''     `width: The minimum field width (including the sign, digits, and decimal point only).
  ''
  '' `Return: A pointer to the formatted string.
  ''
  '' `Example: temp_str := alt.formatn(101325, alt#TO_INCHES|alt#CRLF, 7)
  ''
  ''     Convert 1013.25 mb to inches, format it as "  29.92 in", followed by a carriage return/linefeed pair.
  }}

  width := width <# constant(MAX_LEN - 1) #> 1

  if (units & CONV)
    value := convert(value, units)
    units -= CONV          

  t_val := ||value                                      
  field := 1                                                

  repeat while t_val                              
    field++
    t_val /= 10

  field #>= 4
  
  if ((width -= field + (value => 0)) > 0)                                      
    repeat width                              
      enqueue(" ")                                      

  return format(value, units)

PUB format(value, units) | div, z_pad, str, ch   

  {{ Format a number given in hundredths as a minimal-length, signed-decimal string, optionally converted to
     other units, and optionally followed by a units designator and delimiter. Return a pointer
     to a TEMPORARY string. The lifetime of the returned string is finite, so it must either be used
     right away or be copied to another byte array using `bytemove. See the CONstants section for
     values that can be used in the `units parameter. 
  ''
  '' `Parameters:
  ''
  ''     `value: The value, in hundredths to convert to a string.
  ''     `units: A byte that determines the units to print and possibly convert to, along with a delimiter.
  ''
  '' `Return: A pointer to the formatted string.
  ''
  '' `Example: temp_str := alt.formatn(101325, alt#COMMA)
  ''
  ''     Convert 1013.56 mb to inches, format it as "1013.25 mb,".
  }}

  if (units & CONV)
    value := convert(value, units)

  if (value < 0)                                         
    -value                                              
    enqueue("-")

  div := 1_000_000_000                                  
  z_pad~                                                

  repeat 10
    if (value => div)                                   
      enqueue(value / div + "0")                        
      value //= div                                     
      z_pad~~                                           
    elseif z_pad or (div =< 100)                         
      enqueue("0")
    if (div == 100)
      enqueue(".")                                      
    div /= 10
  str := @empty
  case units & $0f
    MILLIBARS: str := string(" mb")
    INCHES:    str := string(" in")
    DEGC:      str := string("°C")
    DEGF:      str := string("°F")
    METERS:    str := string(" m")
    FEET:      str := string(" ft")
  repeat while ch := byte[str++]
    enqueue(ch)
  case units & $e0
    CR:    enqueue(13)
    LF:    enqueue(10)
    CRLF:  enqueue(13)
           enqueue(10)
    COMMA: enqueue(",")
    SPACE: enqueue(" ")
    TAB:   enqueue(9)
    CECR:  enqueue(11)
           enqueue(13)    
     
  return this_string  

''-------[ Unit Conversions... ]--------------------------------------------------

{{ These methods convert back and forth between:
''
''    • Celsius and Fahrenheit
''    • Meters and Feet
''    • Millibars and Inches of Hg
}}

PUB convert(value, units)

  {{ This method is a generalized conversion routine that accepts a value and a pre-defined
     constant to indicate the type of conversion to perform. (See the CONstants section
     or this method's source code for the available conversions.)
  ''
  '' `Parameters:
  ''
  ''     `value: The value to be converted to other units.
  ''     `units: A predefined constant that determines the type of conversion to perform.
  ''
  '' `Return: The result of the conversion.
  ''
  '' `Example: feet := alt.convert(meters, alt#FEET)
  ''
  ''     Convert meters to feet or centimeters to hundredths of a foot.
  }}

  case units & $0f
    INCHES:    value := in_from_mb(value)
    MILLIBARS: value := mb_from_in(value)
    DEGF:      value := f_from_c(value)
    DEGC:      value := c_from_f(value)
    FEET:      value := ft_from_m(value)
    METERS:    value := m_from_ft(value)
  return value  

PUB mb_from_in(in) 

  {{ Convert pressure in inches of Hg to millibars (or from hundredths of an inch to
     hundredths of millibars).
  ''
  '' `Parameters:
  ''
  ''     `in: Value in inches to be converted.
  ''
  '' `Return: The equivalent value in millibars.
  ''
  '' `Example: mb := alt.mb_from_in(2995) / 100
  ''
  ''     Convert 29.95 inches of mercury to whole millibars.
  }}

  return (_umultdiv(in, constant(338637526 * 2), 10000000) + 1) >> 1

PUB in_from_mb(mb)

  {{ Convert pressure in millibars to inches of Hg (or from hundredths of millibars
     to hundredths of inches).
  ''
  '' `Parameters:
  ''
  ''     `mb: Value in millibars to be converted.
  ''
  '' `Return: The equivalent value in inches of Hg.
  ''
  '' `Example: inches := alt.in_from_mb(101345)
  ''
  ''     Convert 1013.45 millibars to hundredths of inches.
  }}

  return (_umultdiv(mb, constant(10000000 * 2), 338637526) + 1) >> 1

PUB ft_from_m(m) : ft

  {{ Convert altitude in meters to altitude in feet (or from centimeters to
     hundredths of feet).
  ''
  '' `Parameters:
  ''
  ''     `m: Altitude in meters or centimeters
  ''
  '' `Return: Equivalent altitude in feet or hundredths of a foot.
  ''
  '' `Example: feet := alt.ft_from_m(alt.altitude(alt.avg_press)) / 100
  ''
  ''     Compute the altitude in cm, and convert to whole feet.
  }}

  ft := (_umultdiv(||m, constant(10000 * 2), 3048) + 1) >> 1
  if (m < 0)
    -ft

PUB m_from_ft(ft) : m

  {{ Convert altitude in feet to meters (or from hundredths of a foot to
     centimeters).
  ''
  '' `Parameters:
  ''
  ''     `ft: Altitude in feet or hundredths of feet.
  ''
  '' `Return: Equivalent altitude in meters or centimeters.
  ''
  '' `Example: meters := alt.altitude(5280) 
  ''
  ''     Convert one mile high (5280 feet) to whole meters. 
  }}

  m := (_umultdiv(||ft, constant(3048 * 2), 10000) + 1) >> 1
  if (ft < 0)
    -m

PUB c_from_f(deg_f)

  {{ Convert temperature in hundredths of a degress Celsius to hundredths of
     degrees Fahrenheit. NOTE: This does NOT work with whole degrees -- only
     hundredths.
  ''
  '' `Parameters:
  ''
  ''     `deg_f: Temperature in hundredths of degrees Fahrenheit.
  ''
  '' `Return: Equivalent temperature in hundredths of degrees Celsius.
  ''
  '' `Example: celsius := alt.c_from_f(deg_f * 100) / 100
  ''
  ''     Convert whole degrees Fahrenheit to whole degrees Celsius.
  }}

  return (deg_f - 3200) * 5 / 9

PUB f_from_c(deg_c)

  {{ Convert temperature in hundredths of a degress Fahrenheit to hundredths of
     degrees Celsius. NOTE: This does NOT work with whole degrees -- only
     hundredths.
  ''
  '' `Parameters:
  ''
  ''     `deg_c: Temeprature in hundredths of degrees Celsius.
  ''
  '' `Return: Equivalent temperature in hundredths of degrees Fahrenheit.
  ''
  '' `Example: deg_f := alt.f_from_c(2567)
  ''
  ''     Convert 25.67°C to hundredths of degrees Fahrenehit.
  }}

  return deg_c * 9 / 5 + 3200

''=======[ Private Spin Methods... ]===============================================

''-------[ Data Acquisition... ]---------------------------------------------------

{{ This group of methods acquires data from the sensor and performs corrective computations
   according to the calibration data stored in the sensor's PROM.
}}

PRI _do_background

  {{ This is the background process that get started in a separate cog when background mode
     is selected.
  }}

  repeat
    repeat while lockset(lock - 1)
    _sample
    lockclr(lock - 1)
    waitcnt((clkfreq / 100 #> 400) + cnt)        

PRI _sample | i, addr, new_val, cur_val, new_median, nsame, j, median

  {{ Obtain one corrected sample of temperature and pressure and update the
     average and median computation.
  }}

  if (dev5611)
    _cur_temp_press_5611
  else
    _cur_temp_press_5607 
  repeat i from 0 to 1
    addr := @temp_samples * (1 - i ) + @press_samples * i
    new_val := cur_temp[i]
    cur_val := long[addr][ptr]
    sum_temp[i] += new_val - cur_val
    avg_temp[i] := sum_temp[i] / N_SAMP
    median := med_temp[i]
    if (new_val <> cur_val)
      long[addr][ptr] := new_val
      nsame~
      if (new_val =< median and cur_val => median)
        new_median := -$7fff_ffff
        repeat j from 0 to constant(N_SAMP - 1)
          cur_val := long[addr][j]
          if (cur_val < median)
            nsame++
            if (cur_val > new_median)
              new_median := cur_val
      elseif (new_val => median and cur_val =< median)
        new_median := $7fff_ffff
        repeat j from 0 to constant(N_SAMP - 1)
          cur_val := long[addr][j]
          if (cur_val > median)
            nsame++
            if (cur_val < new_median)
              new_median := cur_val
      if (nsame > constant(N_SAMP / 2))
        med_temp[i] := new_median 
  ptr := ++ptr // N_SAMP
  sample_count++

PRI _cur_temp_press_5607 | d1, d2, dt, offh, offl, sensh, sensl, ph, pl

  {{ Obtain current temperature and pressure readings from the MS5607 sensor and
     correct them based on calibration data stored in the sensor's PROM.
  }}

  d1 := _read_adc(RSLT_D1)
  d2 := _read_adc(RSLT_D2)
  
  dt := d2 - c5 << 8
  cur_temp := 2000 + ((dt ** c6) << 9 + (dt * c6) >> 23)

  offh := c4 ** dt
  offl := (c4 * dt) >> 6 | offh << 26
  offh ~>= 6
  _dadd(@offh, c2 >> 15, c2 << 17)

  sensh := c3 ** dt
  sensl := (c3 * dt) >> 7 | sensh << 25
  sensh ~>= 7
  _dadd(@sensh, c1 >> 16, c1 << 16)

  _umult(@ph, d1, sensl)
  ph += d1 * sensh
  pl := pl >> 21 | ph << 11
  ph ~>= 21
  _dsub(@ph, offh, offl)
  cur_press := ph << 17 | pl >> 15

PRI _cur_temp_press_5611 | d1, d2, dt, offh, offl, sensh, sensl, ph, pl

  {{ Obtain current temperature and pressure readings from the MS5611 sensor and
     correct them based on calibration data stored in the sensor's PROM.
  }}

  d1 := _read_adc(RSLT_D1)
  d2 := _read_adc(RSLT_D2)
  
  dt := d2 - c5 << 8
  cur_temp := 2000 + ((dt ** c6) << 9 + (dt * c6) >> 23)

  offh := c4 ** dt
  offl := (c4 * dt) >> 7 | offh << 25
  offh ~>= 7
  _dadd(@offh, c2 >> 16, c2 << 16)

  sensh := c3 ** dt
  sensl := (c3 * dt) >> 8 | sensh << 24
  sensh ~>= 8
  _dadd(@sensh, c1 >> 17, c1 << 15)

  _umult(@ph, d1, sensl)
  ph += d1 * sensh
  pl := pl >> 21 | ph << 11
  ph ~>= 21
  _dsub(@ph, offh, offl)
  cur_press := ph << 17 | pl >> 15

PRI _get_temp

  {{ Obtain a new temperature reading in foreground mode if this method has been called since the
     last data acquisition. This permits temperature and pressure to be obtained separately from the
     same sample by alternating between _get_temp and _get_press. Does nothing in background mode.
  }}

  ifnot (samp_temp)
    samples
  samp_temp~

PRI _get_press


  {{ Obtain a new pressure reading in foreground mode if this method has been called since the
     last data acquisition. This permits temperature and pressure to be obtained separately from the
     same sample by alternating between _get_temp and _get_press. Does nothing in background mode.
  }}

  ifnot(samp_press)
    samples
  samp_press~

PRI _read_prom(addr)

  {{ Read one word of data from the sensor's PROM at the address specified.
  }}

  return _i2c_receive_data(CMD_READ_PROM | addr << 1, 2)

PRI _read_adc(which) | d

  {{ Start a temperature or pressure conversion, then read the 24-bit value after
     a resolution-dependent delay.
  }}

  _i2c_send_cmd(CMD_CONV_ADC | which | resolution)
  waitcnt(adc_delay + cnt)
  return _i2c_receive_data(CMD_READ_ADC, 3)

''-------[ I2C Methods... ]----------------------------------------------------

PRI _i2c_init

  {{ Resynchronize the I2C interface after power up or a reset.
  }}

  repeat 8
    dira[scl]~
    dira[scl]~~ 
    dira[scl]~

PRI _i2c_receive_data(cmd, nbytes) : value | i

  {{ Send a read command and read `nbytes (1 - 4) bytes of data into the return long.
  }}

  _i2c_send_cmd(cmd)
  _i2c_start
  _i2c_send(DEVICE_ADDR | DEVICE_READ)
  repeat i from 1 to nbytes
    value := value << 8 | _i2c_receive(ACK & (i <> nbytes))
  _i2c_stop

PRI _i2c_send_cmd(cmd)

  {{ Send a command to the sensor.
  }}

  _i2c_start
  _i2c_send(DEVICE_ADDR)
  _i2c_send(cmd)
  _i2c_stop

PRI _i2c_send(value)

  {{ Send a byte to the sensor.
  }}

  value := ((!value) >< 8)

  repeat 8
    dira[sda] := value
    dira[scl] := false
    dira[scl] := true
    value >>= 1

  dira[sda] := false
  dira[scl] := false
  result := not(ina[sda])
  dira[scl] := true
  dira[sda] := true

PRI _i2c_receive(aknowledge)

  {{ Receive a byte from the sensor.
  }}

  dira[sda] := false

  repeat 8
    result <<= 1
    dira[scl] := false
    result |= ina[sda]
    dira[scl] := true

  dira[sda] := (aknowledge)
  dira[scl] := false
  dira[scl] := true
  dira[sda] := true

PRI _i2c_start

  {{ Send an I2C start condition.
  }}

  outa[sda] := false
  outa[scl] := false
  dira[sda] := true
  dira[scl] := true

PRI _i2c_stop

  {{ Send an I2C stop condition.
  }}

  dira[scl] := false
  dira[sda] := false

''-------[ Double Long Math... ]--------------------------------------------------

{{ These methods perform 64-bit, unsigned interger math operations.
}} 

PRI _umultdiv(x, num, denom) | producth, productl

  {{ Multiply `x and `num, then divide the resulting unsigned, 64-bit product by
     `denom to yield a 32-bit unsigned result. `x ** `num must be less than (unsigned) `denom.
  }}

  _umult(@producth, x, num)
  return _udiv(producth, productl, denom)   

PRI _umult(productaddr, mplr, mpld) | producth, productl

  {{ Multiply `mplr by `mpld and store the unsigned 64-bit product at `productaddr.
  }}

  producth := (mplr & $7fff_ffff) ** (mpld & $7fff_ffff)
  productl := (mplr & $7fff_ffff) * (mpld & $7fff_ffff)
  if (mplr < 0)
    _dadd(@producth, mpld >> 1, mpld << 31)
  if (mpld < 0)
    _dadd(@producth, mplr << 1 >> 2, mplr << 31)
  longmove(productaddr, @producth, 2)

PRI _udiv(dvndh, dvndl, dvsr) | carry, quotient

  {{ Divide the unsigned 64-bit number `dvndh:`dvndl by `dvsr, returning an unsigned 32-bit quotient.
     Saturate result to $ffff_ffff if it's too big to fit 32 bits.
  }}

  quotient~
  ifnot (_ult(dvndh, dvsr))
    return $ffff_ffff
  repeat 32
    carry := dvndh < 0
    dvndh := (dvndh << 1) + (dvndl >> 31)
    dvndl <<= 1
    quotient <<= 1
    if (not _ult(dvndh, dvsr) or carry)
      quotient++
      dvndh -= dvsr
  return quotient

PRI _dsub(difaddr, subh, subl)

  {{ Subtract the 64-bit value `subh:`subl from the 64-bit value stored at `difaddr.
  }}
  
  _dadd(difaddr, -subh - 1, -subl)

PRI _dadd(sumaddr, addh, addl) | sumh, suml

  {{ Add the 64-bit value `addh:`addl to the 64-bit value stored at `sumaddr.
  }}

  longmove(@sumh, sumaddr, 2)
  sumh += addh
  suml += addl
  if (_ult(suml, addl))
    sumh++
  longmove(sumaddr, @sumh, 2)

PRI _ult(x, y)

  {{ Test for unsigned `x < unsigned `y. Return `true if less than; `false, otherwise. 
  }}

  return x ^ $8000_0000 < y ^ $8000_0000

'-------[String-building... ]-----------------------------------------------------

PRI this_string

  {{ Zero-terminate the string being built in the buffer and return its address. Advance the buffer pointer.
     Return the buffer address of the most recent string built.
  }}
  
  enqueue(0)
  result := @buffer + str_index
  str_index := buf_index

PRI enqueue(char)


  {{ Add the byte `char to the current buffer string. If beyond the end, copy the string to beginning of the buffer.
  }}

  if (buf_index => MAX_LEN)
    if (str_index)
      bytemove(@buffer, @buffer[str_index], buf_index - str_index)
      buf_index -= str_index
      str_index~
    else
      buf_index--                        ' String has gotten too long for buffer: overwrite previous character.
  buffer[buf_index++] := char  
 
''=======[ Altitude Table ]=======================================================

{{ The DAT section contains a table of altitudes indexed by hundredths of millibars / 2048
   and used by the `altitude method to compute altitude from pressure by means of
   cubic interpolation. 
}}

DAT

alt_table     long      4433077,2323037,2025546,1832444,1686113,1566963,1465785,1377458
              long      1298823,1227784,1162875,1103025,1047431, 995470, 946651, 900579
              long       856930, 815437, 775876, 738056, 701815, 667012, 633527, 601252
              long       570095, 539971, 510808, 482539, 455106, 428455, 402538, 377311
              long       352735, 328773, 305392, 282561, 260253, 238441, 217101, 196211
              long       175750, 155700, 136041, 116758,  97835,  79257,  61010,  43082
              long        25459,   8132,  -8910, -25680, -42185, -58436, -74439, -90205
              long      -105740,-121053,-136149,-151036,-165720,-180207,-194503,-208614
              long      -222544

empty         long      0             'An empty string used by the formatting routines.

''=======[ License ]==============================================================
{{{
┌──────────────────────────────────────────────────────────────────────────────────────┐
│                            TERMS OF USE: MIT License                                 │                                                            
├──────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this  │
│software and associated documentation files (the "Software"), to deal in the Software │
│without restriction, including without limitation the rights to use, copy, modify,    │
│merge, publish, distribute, sublicense, and/or sell copies of the Software, and to    │
│permit persons to whom the Software is furnished to do so, subject to the following   │
│conditions:                                                                           │
│                                                                                      │
│The above copyright notice and this permission notice shall be included in all copies │
│or substantial portions of the Software.                                              │
│                                                                                      │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,   │
│INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A         │
│PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT    │
│HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF  │
│CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE  │
│OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                         │
└──────────────────────────────────────────────────────────────────────────────────────┘
}}
/*
MS561101BA_demo.pde - Displays the readings coming from an MS561101BA
sensor connected to an arduino which is running the MS561101BA_demo sketch
which is part of the MS561101BA arduino library.

Copyright (C) 2011 Fabio Varesano <fvaresano@yahoo.it>

Development of this code has been supported by the Department of Computer Science,
Universita' degli Studi di Torino, Italy within the Piemonte Project
http://www.piemonte.di.unito.it/


This program is free software: you can redistribute it and/or modify
it under the terms of the version 3 GNU General Public License as
published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

import processing.serial.*;
import java.util.Arrays;

Serial myPort;  // Create object from Serial class

float temp = 0.0, press = 0.0, altitude=-1.0, press_base = -1.0;

int lf = 10; // 10 is '\n' in ASCII
byte[] inBuffer = new byte[100];

PFont font;


void setup() 
{
  size(600, 600);
  myPort = new Serial(this, Serial.list()[0], 9600);  
  
  // The font must be located in the sketch's 
  // "data" directory to load successfully
  font = loadFont("CourierNew36.vlw"); 
}


void draw() {
  if(myPort.available() > 0) {
    if (myPort.readBytesUntil(lf, inBuffer) > 0) {
      String inputString = new String(inBuffer);
      inputString = trim(inputString);
      // we are going to receive a line like:
      // "temp: 25.08 degC pres: 2052.17 mbar\r\n"
      
      // split on blanks
      String [] inputStringArr = split(inputString, ' ');
      if(inputStringArr.length >= 6) {
        temp = float(inputStringArr[1]);
        press = float(inputStringArr[4]);
        //println("temp: " + temp);
        //println("press: " + press);
        if(inputStringArr.length >= 8) { // check if we also have altitude
          altitude = float(inputStringArr[7]);
          //println(altitude);
        }
        
      }
      else {
        println("badly formatted line:\r\n" + inputString);
        Arrays.fill(inBuffer, (byte) 0); // clear buffer on badly formatted lines
      }
    }
  }
  
  background(#000000);
  fill(#00ff00); // green fill
  
  // press is something like 2000.00
  if(press_base == -1) {
    press_base = press;
  }
  float h = (press - press_base) * 100;
  //println(h);
  rect(100, 300, 50, h*7);
  
  textFont(font);
  String message = "temp:\n" + temp + " degC\n" + "pressure:\n" + press + " mbar ";
  if(altitude > 0.0) { // we are receiving altitude readings from Arduino
    message += "\naltitude:\n" + altitude + " m";
  }
  text(message, 250, 250);
  textFont(font, 18);
  text("Press h to set home position", 20, 550);
}


void keyPressed() {
  if(key == 'h') {
    println("pressed h");
    
    // set hq the home quaternion as the quatnion conjugate coming from the sensor fusion
    press_base = press;
    
  }
}

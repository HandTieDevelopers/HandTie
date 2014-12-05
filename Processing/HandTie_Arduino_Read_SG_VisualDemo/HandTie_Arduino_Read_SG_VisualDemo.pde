import processing.serial.*;
import cc.arduino.*;
Arduino arduino = null;

color stretch = color(4, 79, 111);
color compress = color(84, 145, 158);
int Width = 500;
int Height = 600;
float mul = 1;
int caliVolts[] = new int[5];
double elongRatios[]=new double[5];

void setup() {
  size(Width, Height);

  // Prints out the available serial ports.
  println(Arduino.list());
  
  // Modify this line, by changing the "0" to the index of the serial
  // port corresponding to your Arduino board (as it appears in the list
  // printed by the line above).
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  
  // Alternatively, use the name of the serial port corresponding to your
  // Arduino (in double-quotes), as in the following line.
  arduino = new Arduino(this, "/dev/tty.usbmodem1411", 57600);
  
  // Set the Arduino digital pins as inputs.
    arduino.pinMode(2, Arduino.INPUT);
    
   for (int i = 0; i < 5; i++) {
    caliVolts[i]=-1;
  }
}

void draw() {
  background(210);
  line(0, Height*(0.4), Width, Height*(0.4));
//  for (int i = 0; i < 5; i++) {
//    rect(Width*(i+1)*0.15, Height*(0.1) , 50, Height*(0.6)); 
//  }
  if(arduino.digitalRead(2) == 0){
    for(int i=0; i<5; ++i){
      caliVolts[i] = arduino.analogRead(i);
      //println("button pressed: ");
    }
  }
  textSize(20);
  for (int i = 0; i < 5; i++) {
    double strainData = arduino.analogRead(i);
    elongRatios[i] = strainData / caliVolts[i];
    
    
    if(elongRatios[i]>1){
      fill(stretch);
      rect(Width*(i+1)*0.15, (float)(Height*(0.4)-Height*mul*(elongRatios[i]-1)), 50, (float)(Height*mul*(elongRatios[i]-1)));
    }
    else{
      fill(compress);
      rect(Width*(i+1)*0.15, (float)Height*(0.4), 50, (float)(Height*mul*(1-elongRatios[i])));
    }
    
    fill(0, 102, 10);
    text((float)elongRatios[i], Width*(i+1)*0.15, Height*(0.73)); 
    fill(150, 150, 150);
    text((int)strainData, Width*(i+1)*0.15, Height*(0.8)); 
    
  }
}

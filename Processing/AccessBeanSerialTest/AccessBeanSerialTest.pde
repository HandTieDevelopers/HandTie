import processing.serial.*;

int lf = 10;  // linefeed in ASCII
String myString = null; //var to hold war serial data
int value; // var to hold hold serial data from Bean
Serial myPort;  // the serial port

void setup() {
  size(500,500);
  background(0);
  // list all the available serial ports
  println(Serial.list());
  // the bean is the 5th port so I open Serial.list()[4].
  // open whatever port is the one you're using.
  myPort = new Serial(this, Serial.list()[9], 9600);
  myPort.clear();
  // throw out the first reading, in case we started reading 
  // in the middle of a string from the sender.
  myString = myPort.readStringUntil(lf);
  myString = null; 
}

void draw() {
  while (myPort.available() > 0) {
    myString = myPort.readStringUntil(lf);
    if (myString != null) {
      myString = trim(myString);
      value = int(myString);
      println(value);

      // change background colour
      if (value == 1) { background(0,0,255); }
      if (value == 2) { background(255,0,0); }
      if (value == 3) { background(0,255,0); }
      if (value == 4) { background(255,0,255); }
      if (value == 5) { background(255,100,255); }
      if (value == 6) { background(135,206,250); }
    }
  }
}

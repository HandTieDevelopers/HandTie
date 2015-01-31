import processing.serial.*;

SerialManager serialManager = new SerialManager(this);
SGManager sgManager = new SGManager();

void setup() {
   size(1024, 768);
}

void draw() {
   background(255, 255, 255, 0);
   sgManager.draw();
}

void keyPressed(){
   if (key == 'c') {
      sgManager.requestForCaliVals = true;
      serialManager.sendRequestToArduinoForCalibration();
   }
}

void serialEvent(Serial port){
   try {
      int [] analogVals = serialManager.parseDataFromArduino(port);
      sgManager.setValuesForGauges(analogVals);
   }
   catch (Exception e) {
     println(e.getMessage());
   }
}

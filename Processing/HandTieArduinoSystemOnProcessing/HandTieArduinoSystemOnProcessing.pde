import processing.serial.*;

SerialManager serialManager = new SerialManager(this);
SGManager sgManager = new SGManager();
InteractionMgr interactionMgr = new InteractionMgr(this);

void setup() {
   size(1280, 768);
}

void draw() {
   background(255, 255, 255, 0);
   sgManager.draw();
}

void keyPressed(){
   interactionMgr.performKeyPress(key);
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

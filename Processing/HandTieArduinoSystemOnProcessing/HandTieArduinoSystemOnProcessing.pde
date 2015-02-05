import processing.serial.*;

SerialManager serialManager = new SerialManager(this);
SGManager sgManager = new SGManager();
InteractionMgr interactionMgr = new InteractionMgr(this);
StudyMgr studyMgr = new StudyMgr(this);

void setup() {
   size(900, 600);
}

void draw() {
   background(255, 255, 255, 0);
   studyMgr.start();
   sgManager.draw();
}

void keyPressed(){
   studyMgr.performKeyPress(key);
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

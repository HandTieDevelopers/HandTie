import processing.serial.*;

SGManager sgManager;
SerialManager serialManager;
UIInteractionMgr uiInteractionMgr;
GRTMgr grtMgr;
//StudyMgr studyMgr;

void setup() {
   size(900, 600);
   sgManager = new SGManager();
   serialManager = new SerialManager(this);
   uiInteractionMgr = new UIInteractionMgr(this);
//   studyMgr = new StudyMgr(this);
   grtMgr = new GRTMgr(this);
   listenerRegistrations();
}

void draw() {
   background(255, 255, 255, 0);
//   studyMgr.start();
  grtMgr.draw();
   sgManager.draw();
  
}

void listenerRegistrations(){
   sgManager.registerToSerialNotifier(serialManager);
   uiInteractionMgr.registerToSerialNotifier(serialManager);
   grtMgr.registerToSerialNotifier(serialManager);
}

void keyPressed(){
   uiInteractionMgr.performKeyPress(key);
   grtMgr.performKeyPress(key);
   serialManager.performKeyPress(key);
   sgManager.performKeyPress(key);

}

void serialEvent(Serial port){
   try {
      serialManager.parseDataFromSerial(port);
   } catch (Exception e) {
      println(e.getMessage());
   }
}



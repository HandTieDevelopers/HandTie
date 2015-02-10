import processing.serial.*;

SGManager sgManager;
SerialManager serialManager;
UIInteractionMgr uiInteractionMgr;
StudyMgr studyMgr;

void setup() {
   size(900, 600);

   sgManager = new SGManager();
   serialManager = new SerialManager(this);
   uiInteractionMgr = new UIInteractionMgr(this);
   studyMgr = new StudyMgr(this);

   listenerRegistrations();
   serialManager.performKeyPress('c');
}

void draw() {
   background(255, 255, 255, 0);
   studyMgr.start();
   sgManager.draw();
}

void listenerRegistrations(){
   sgManager.registerToSerialNotifier(serialManager);
   uiInteractionMgr.registerToSerialNotifier(serialManager);
}

void keyPressed(){
   uiInteractionMgr.performKeyPress(key);
   studyMgr.performKeyPress(key);
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

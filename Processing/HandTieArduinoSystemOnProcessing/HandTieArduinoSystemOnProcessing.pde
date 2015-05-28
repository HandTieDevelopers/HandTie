import processing.serial.*;

SGManager sgManager;
SerialManager serialManager;
UIInteractionMgr uiInteractionMgr;
//StudyMgr studyMgr;
//ExperimentImageManager expImgManager;
AccelMgr accelMgr;

void setup() {
   size(900, 600);
//   expImgManager = new ExperimentImageManager(this, 0, 640, 480, 0);
   sgManager = new SGManager();
   serialManager = new SerialManager(this);
   accelMgr = new AccelMgr();
   uiInteractionMgr = new UIInteractionMgr(this);
//   studyMgr = new StudyMgr(this);

   listenerRegistrations();
}

void draw() {
   background(255, 255, 255, 0);
//   studyMgr.start();
   sgManager.draw();
//   expImgManager.draw();
   accelMgr.draw();
}

void listenerRegistrations(){
   sgManager.registerToSerialNotifier(serialManager);
   uiInteractionMgr.registerToSerialNotifier(serialManager);
//   studyMgr.registerToSerialNotifier(serialManager);
   accelMgr.registerToSerialNotifier(serialManager);
}

void keyPressed(){
   uiInteractionMgr.performKeyPress(key);
//   studyMgr.performKeyPress(key);
   serialManager.performKeyPress(key);
   sgManager.performKeyPress(key);
//   expImgManager.performKeyPress(key);
   accelMgr.performKeyPress(key);
}

void serialEvent(Serial port){
   try {
      serialManager.parseDataFromSerial(port);
   } catch (Exception e) {
      println(e.getMessage());
   }
}

//void captureEvent(Capture c) {
//   c.read();
//   expImgManager.updateUIText("camera ready");
//}


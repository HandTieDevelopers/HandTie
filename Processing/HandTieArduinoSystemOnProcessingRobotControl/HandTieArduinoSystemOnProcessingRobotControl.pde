import processing.serial.*;

SGManager sgManager;
SerialManager serialManager;
UIInteractionMgr uiInteractionMgr;
AccelMgr accelMgr;
RobotControl robotControl;
GRTMgr grtMgr;

void setup() {
   size(900, 600);
   sgManager = new SGManager();
   serialManager = new SerialManager(this);
   accelMgr = new AccelMgr();
   robotControl = new RobotControl(this);
   grtMgr = new GRTMgr();
   uiInteractionMgr = new UIInteractionMgr(this);

   listenerRegistrations();
}

void draw() {
   background(255, 255, 255, 0);
   sgManager.draw();
   accelMgr.draw();
   grtMgr.draw();
}

void listenerRegistrations(){
   sgManager.registerToSerialNotifier(serialManager);
   uiInteractionMgr.registerToSerialNotifier(serialManager);
   accelMgr.registerToSerialNotifier(serialManager);
   grtMgr.registerToSerialNotifier(serialManager);

   serialManager.registerToGRTNotifier(grtMgr);
   robotControl.registerToGRTNotifier(grtMgr);
}

void keyPressed(){
   uiInteractionMgr.performKeyPress(key);
   serialManager.performKeyPress(key);
   sgManager.performKeyPress(key);
   accelMgr.performKeyPress(key);
   robotControl.performKeyPress(key);
   grtMgr.performKeyPress(key);
}

void serialEvent(Serial port){
   try {
      serialManager.parseDataFromSerial(port);
   } catch (Exception e) {
      println(e.getMessage());
   }
}

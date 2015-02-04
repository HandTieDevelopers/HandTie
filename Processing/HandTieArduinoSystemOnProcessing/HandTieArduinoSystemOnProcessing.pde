import processing.serial.*;
import controlP5.*;

SerialManager serialManager = new SerialManager(this);
SGManager sgManager = new SGManager();
UIInteractionMgr uiInteractionMgr;

void setup() {
   size(1280, 768);
   uiInteractionMgr = new UIInteractionMgr(this);
}

void draw() {
   background(255, 255, 255, 0);
   sgManager.draw();
}

void keyPressed(){
   uiInteractionMgr.performKeyPress(key);
}

void serialEvent(Serial port){
   try {
      serialManager.parseDataFromSerial(port);
   }
   catch (Exception e) {
      println(e.getMessage());
   }
}

public void controlEvent(ControlEvent theEvent){
   uiInteractionMgr.performControlEvent(theEvent);
}

import processing.serial.*;
//import controlP5.*;

SerialManager serialManager = new SerialManager(this);
SGManager sgManager = new SGManager();
StudyMgr studyMgr = new StudyMgr(this);
public boolean ShowGaugeBar = true; 

void setup() {
   size(900, 600);
}

void draw() {
   background(255, 255, 255, 0);
   studyMgr.start();
   if(ShowGaugeBar){
     sgManager.draw();
   }
}

void keyPressed(){
   switch (key) {
        case TAB :
            ShowGaugeBar=!ShowGaugeBar;
            break;
   }
   studyMgr.performKeyPress(key);
}

void serialEvent(Serial port){
   try {
      serialManager.parseDataFromSerial(port);
   }
   catch (Exception e) {
      println(e.getMessage());
   }
}

//public void controlEvent(ControlEvent theEvent){
//   uiInteractionMgr.performControlEvent(theEvent);
//}

import processing.serial.*;

SGManager sgManager;
SerialManager serialManager;
UIInteractionMgr uiInteractionMgr;
StudyMgr studyMgr;
public boolean ShowGaugeBar = true; 

void setup() {
   size(900, 600);

   sgManager = new SGManager();
   serialManager = new SerialManager(this);
   uiInteractionMgr = new UIInteractionMgr(this);
   studyMgr = new StudyMgr(this);
}

void draw() {
   background(255, 255, 255, 0);
   // studyMgr.start();
   // if(ShowGaugeBar){
     sgManager.draw();
   // }
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

import controlP5.*;

public class UIInteractionMgr {
   HandTieArduinoSystemOnProcessing mainClass;

   ControlP5 cp5;

   public UIInteractionMgr (HandTieArduinoSystemOnProcessing mainClass) {
      this.mainClass = mainClass;

      cp5 = new ControlP5(mainClass);
      createUIForSerial();
   }

   private void createUIForSerial(){
      // cp5.addButton("calibrate")
      //    .setValue(0)
      //    .setPosition()
      //    .setSize()
      // ;
   }

   public void performControlEvent(ControlEvent theEvent){

   }

   public void performKeyPress(char k){
      switch (k) {
         case 'c' :
            gaugeCalibration();
            break;
      }
   }

   public void gaugeCalibration(){
      mainClass.sgManager.requestForCaliVals = true;
      mainClass.serialManager.sendToArduino("0");
   }

   // public void performMousePress(){

   // }

}
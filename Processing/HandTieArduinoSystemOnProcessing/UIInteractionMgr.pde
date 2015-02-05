import controlP5.*;

public class UIInteractionMgr {
   HandTieArduinoSystemOnProcessing mainClass;

   ControlP5 cp5;

   //Serial UI constants


   public UIInteractionMgr (HandTieArduinoSystemOnProcessing mainClass) {
      this.mainClass = mainClass;

      cp5 = new ControlP5(mainClass);
      createUIForSerial();
   }

   private void createUIForSerial(){
      cp5.addRadioButton("Adjustment")
         .setPosition(10,20)
         .setItemWidth(30)
         .setItemHeight(30)
         .addItem("change all", 0)
         .addItem("change individually", 1)
         .setColorLabel(color(0))
         ;
      cp5.addNumberbox("Amplified Target Value")
         .setPosition(100,200)
         .setSize(100,14)
         .setRange(0,200)
         .setMultiplier(0.1) // set the sensitifity of the numberbox
         .setDirection(Controller.HORIZONTAL)
         .setValue(100)
         .setColorLabel(color(0))
         // .getCaptionLabel().setSize(12).setFont(createFont("Georgia",10));
         ;
      // cp5.addButton("calibrate")
      //    .setValue(0)
      //    .setPosition()
      //    .setSize()
      // ;
   }

   public void performControlEvent(ControlEvent theEvent){
      if (millis() < 1500) return;
      println("performControlEvent: " + theEvent.getController().getName());

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

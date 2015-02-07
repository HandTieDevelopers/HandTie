import controlP5.*;

public class UIInteractionMgr implements ControlListener{
   HandTieArduinoSystemOnProcessing mainClass;

   ControlP5 cp5;

   //Serial UI constants


   public UIInteractionMgr (HandTieArduinoSystemOnProcessing mainClass) {
      this.mainClass = mainClass;

      cp5 = new ControlP5(mainClass);
      cp5.setColorValue(0);
      cp5.addListener(this);

      createUIForSerial();
   }

   private void createUIForSerial(){
      // cp5.addRadioButton("Adjustment")
      //    .setPosition(10,20)
      //    .setItemWidth(30)
      //    .setItemHeight(30)
      //    .addItem("change all", 0)
      //    .addItem("change individually", 1)
      //    .setColorLabel(color(0))
      //    ;
      int i;
      for (i = 0; i < mainClass.sgManager.NUM_OF_GAUGES; ++i) {
         float [] barOrigin = sgManager.getOneBarBaseCenterOfGauges(i);

         // cp5.addNumberbox("Amp Target of " + i)
         //    .setPosition(barOrigin[0]-20, barOrigin[1] + 150)
         //    .setSize(80,14)
         //    .setRange(0,1024)
         //    // .setMultiplier(1) // set the sensitifity of the numberbox
         //    .setDirection(Controller.HORIZONTAL)
         //    .setValue(sgManager.getOneCaliValForGauges(i))
         //    .setColorLabel(color(0))
         //    // .getCaptionLabel().setSize(12).setFont(createFont("Georgia",10));
         // ;
         cp5.addSlider("amp"+i)
            .setPosition(barOrigin[0]-5, barOrigin[1] + 150)
            .setSize(10,80)
            .setRange(0,1000)
            .setValue(sgManager.getOneCaliValForGauges(i))
            .setColorLabel(color(0))
            .setTriggerEvent(Slider.RELEASE)
            .setNumberOfTickMarks(21)
            .snapToTickMarks(true)
            .setDecimalPrecision(0)
         ;
      }

      float [] barOrigin = sgManager.getOneBarBaseCenterOfGauges(i-1);
      cp5.addSlider("all_amp")
         .setPosition(barOrigin[0]+30, barOrigin[1] + 150)
         .setSize(10,80)
         .setRange(0,1000)
         .setValue(500)
         .setColorLabel(color(0))
         .setTriggerEvent(Slider.RELEASE)
         .setNumberOfTickMarks(21)
         .snapToTickMarks(true)
         .setDecimalPrecision(0)

      ;
      // cp5.addButton("calibrate")
      //    .setValue(0)
      //    .setPosition()
      //    .setSize()
      // ;
   }

   public void controlEvent(ControlEvent theEvent){
      if (millis() < 1500) return;
      // println("performControlEvent: " + theEvent.getName());

      if (theEvent.getName().equals("all_amp")) {
         manualChangeToAllGaugesWithAmp(theEvent);
      } else if (theEvent.getName().contains("amp")){
         manualChangeToOneGaugeWithAmp(theEvent);
      }
   }

   private void manualChangeToAllGaugesWithAmp(ControlEvent theEvent){
      for (int i = 0; i < mainClass.sgManager.NUM_OF_GAUGES; ++i) {
         cp5.controller("amp"+i).setValue(theEvent.getValue());
      }
      String sendMessage = new String(mainClass
                                      .serialManager
                                      .MANUAL_CHANGE_TO_ALL_GAUGES_WITH_AMP +
                                      " " + theEvent.getValue());
      mainClass.serialManager.sendToArduino(sendMessage);

   }

   private void manualChangeToOneGaugeWithAmp(ControlEvent theEvent){
      String [] nameSplit = theEvent.getName().split("amp");
      int index = Integer.parseInt(nameSplit[1]);
      String sendMessage = new String(mainClass
                                      .serialManager
                                      .MANUAL_CHANGE_TO_ONE_GAUGE_WITH_AMP +
                                      " " + theEvent.getValue());
      mainClass.serialManager.sendToArduino(sendMessage);
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

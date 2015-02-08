import controlP5.*;

public class UIInteractionMgr implements ControlListener, SerialListener{
   HandTieArduinoSystemOnProcessing mainClass;

   ControlP5 cp5;

   RadioButton radioButton;

   private final static String RADIO_DISPLAY = "display";
   private final static String SLIDER_BRIDGE_ALL = "brdg_all";
   private final static String SLIDER_AMP_ALL =  "amp_all";
   private final static String SLIDERS_BRIDGE = "brdg";
   private final static String SLIDERS_AMP = "amp";
   private final static String CALIBRATE = "calibrate";

   public UIInteractionMgr (HandTieArduinoSystemOnProcessing mainClass) {
      this.mainClass = mainClass;

      cp5 = new ControlP5(mainClass);
      cp5.setColorValue(0);
      cp5.addListener(this);
      cp5.addListener(mainClass.sgManager);
      cp5.addListener(mainClass.serialManager);

      createUIForSerial();
   }

   private void createUIForSerial(){
      float [] barOrigin = sgManager.getOneBarBaseCenterOfGauges(0);
      radioButton = cp5.addRadioButton(RADIO_DISPLAY)
                       .setPosition(width*0.25, height*0.9)
                       .setItemWidth(20)
                       .setItemHeight(20)
                       .addItem("bar", 0)
                       .addItem("bridge slider", 1)
                       .addItem("amp slider", 2)
                       .setColorLabel(color(0))
                       .activate(0)
                       .setItemsPerRow(5)
                       .setSpacingColumn((int)(width*0.08))
                    ;

      int i;
      for (i = 0; i < mainClass.sgManager.NUM_OF_GAUGES; ++i) {
         barOrigin = sgManager.getOneBarBaseCenterOfGauges(i);
         cp5.addSlider(SLIDERS_AMP+i)
            .setPosition(barOrigin[0]-4, barOrigin[1]-40)
            .setSize(10,80)
            .setRange(0,1000)
            .setValue(sgManager.getOneCaliValForGauges(i))
            .setColorLabel(color(0))
            .setTriggerEvent(Slider.RELEASE)
            .setNumberOfTickMarks(21)
            .snapToTickMarks(true)
            .setDecimalPrecision(0)
            .showTickMarks(false)
            .setVisible(false)
         ;

         cp5.addSlider(SLIDERS_BRIDGE+i)
            .setPosition(barOrigin[0]-4, barOrigin[1]-40)
            .setSize(10,80)
            .setRange(0,30)
            .setValue(20)
            .setColorLabel(color(0))
            .setTriggerEvent(Slider.RELEASE)
            .setNumberOfTickMarks(31)
            .snapToTickMarks(true)
            .setDecimalPrecision(0)
            .showTickMarks(false)
            .setVisible(false)
         ;
      }

      barOrigin = sgManager.getOneBarBaseCenterOfGauges(i-1);
      cp5.addSlider(SLIDER_AMP_ALL)
         .setPosition(barOrigin[0]+35, barOrigin[1]-40)
         .setSize(10,80)
         .setRange(0,1000)
         .setValue(500)
         .setColorLabel(color(0))
         .setTriggerEvent(Slider.RELEASE)
         .setNumberOfTickMarks(21)
         .snapToTickMarks(true)
         .setDecimalPrecision(0)
         .showTickMarks(false)
         .setVisible(false)
      ;
      cp5.addSlider(SLIDER_BRIDGE_ALL)
         .setPosition(barOrigin[0]+35, barOrigin[1]-40)
         .setSize(10,80)
         .setRange(0,30)
         .setValue(20)
         .setColorLabel(color(0))
         .setTriggerEvent(Slider.RELEASE)
         .setNumberOfTickMarks(31)
         .snapToTickMarks(true)
         .setDecimalPrecision(0)
         .showTickMarks(false)
         .setVisible(false)
      ;
      cp5.addButton(CALIBRATE)
         .setValue(0)
         .setPosition(width*0.1, height*0.9)
         .setSize(48,20)
      ;
   }

   public void controlEvent(ControlEvent theEvent){
      if (millis() < 1500) return;
      println("performControlEvent: " + theEvent.getName());
      println("event value: " + theEvent.getValue());

      if (theEvent.getName().equals(SLIDER_BRIDGE_ALL)) {
         manualChangeToAllGaugesNoAmp(theEvent);
      } else if (theEvent.getName().contains(SLIDERS_BRIDGE)) {
         manualChangeToOneGaugeNoAmp(theEvent);
      } else if (theEvent.getName().equals(SLIDER_AMP_ALL)) {
         manualChangeToAllGaugesWithAmp(theEvent);
      } else if (theEvent.getName().contains(SLIDERS_AMP)){
         manualChangeToOneGaugeWithAmp(theEvent);
      } else if (theEvent.getName().equals(RADIO_DISPLAY)){
         changeDisplay(theEvent.getValue());
      } else if (theEvent.getName().equals(CALIBRATE)){
         gaugeCalibration();
      }
   }

   private void manualChangeToAllGaugesNoAmp(ControlEvent theEvent){
      for (int i = 0; i < mainClass.sgManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_BRIDGE+i).setValue(theEvent.getValue());
      }
      String sendMessage = new String(mainClass
                                      .serialManager
                                      .MANUAL_CHANGE_TO_ALL_GAUGES_NO_AMP +
                                      " " + theEvent.getValue());
      mainClass.serialManager.sendToArduino(sendMessage);
   }

   private void manualChangeToOneGaugeNoAmp(ControlEvent theEvent){
      String [] nameSplit = theEvent.getName().split(SLIDERS_BRIDGE);
      int index = Integer.parseInt(nameSplit[1]);
      String sendMessage = new String(mainClass
                                      .serialManager
                                      .MANUAL_CHANGE_TO_ONE_GAUGE_NO_AMP +
                                      " " + theEvent.getValue());
      mainClass.serialManager.sendToArduino(sendMessage);
   }

   private void manualChangeToAllGaugesWithAmp(ControlEvent theEvent){
      for (int i = 0; i < mainClass.sgManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_AMP+i).setValue(theEvent.getValue());
      }
      String sendMessage = new String(mainClass
                                      .serialManager
                                      .MANUAL_CHANGE_TO_ALL_GAUGES_WITH_AMP +
                                      " " + theEvent.getValue());
      mainClass.serialManager.sendToArduino(sendMessage);

   }

   private void manualChangeToOneGaugeWithAmp(ControlEvent theEvent){
      String [] nameSplit = theEvent.getName().split(SLIDERS_AMP);
      int index = Integer.parseInt(nameSplit[1]);
      String sendMessage = new String(mainClass
                                      .serialManager
                                      .MANUAL_CHANGE_TO_ONE_GAUGE_WITH_AMP +
                                      " " + theEvent.getValue());
      mainClass.serialManager.sendToArduino(sendMessage);
   }

   private void changeDisplay(float eventValue){
      hideAllUIItems();
      if (eventValue == 0.0f) {
         mainClass.sgManager.hideBar = false;
         mainClass.sgManager.hideText = false;
      } else if (eventValue == 1.0f){
         mainClass.sgManager.hideText = false;
         for (int i=0; i<sgManager.NUM_OF_GAUGES; ++i) {
            cp5.controller(SLIDERS_BRIDGE+i).setVisible(true);
         }
         cp5.controller(SLIDER_BRIDGE_ALL).setVisible(true);
      } else if (eventValue == 2.0f){
         mainClass.sgManager.hideText = false;
         for (int i=0; i<sgManager.NUM_OF_GAUGES; ++i) {
            cp5.controller(SLIDERS_AMP+i).setVisible(true);
         }
         cp5.controller(SLIDER_AMP_ALL).setVisible(true);
      } else if (eventValue == -1.0f){
         mainClass.sgManager.hideText = true;
      }
   }

   private void hideAllUIItems(){
      for (int i=0; i<sgManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_BRIDGE+i).setVisible(false);
         cp5.controller(SLIDERS_AMP+i).setVisible(false);
      }
      cp5.controller(SLIDER_BRIDGE_ALL).setVisible(false);
      cp5.controller(SLIDER_AMP_ALL).setVisible(false);
      mainClass.sgManager.hideBar = true;
      mainClass.sgManager.hideText = true;
   }

   public void performKeyPress(char k){
      switch (k) {
         case 'c' :
            gaugeCalibration();
            break;
         case TAB :
            hideAllUIItems();
            if (!radioButton.isVisible())
               changeDisplay(0.0);
            cp5.controller(CALIBRATE).setVisible(!cp5.controller(CALIBRATE)
                                                     .isVisible());
            radioButton.setVisible(!radioButton.isVisible());
            break;
            
      }
   }

   public void gaugeCalibration(){
      mainClass.serialManager.sendToArduino(Integer.toString(mainClass.serialManager
                                                             .ALL_CALIBRATION));
   }

   // public void performMousePress(){

   // }

   @Override
   public void registerToSerialNotifier(SerialNotifier notifier){
      notifier.registerForSerialListener(this);
   }
   @Override
   public void removeToSerialNotifier(SerialNotifier notifier){
      notifier.removeSerialListener(this);
   }
   
   @Override
   public void updateAnalogVals(int [] values){}
   @Override
   public void updateCaliVals(int [] values){}

   @Override
   public void updateTargetAnalogValsNoAmp(int [] values){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_BRIDGE+i).setValue((float)values[i]);
      }
   }

   @Override
   public void updateTargetAnalogValsWithAmp(int [] values){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_AMP+i).setValue((float)values[i]);
      }
   }

}

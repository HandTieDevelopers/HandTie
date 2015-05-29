import controlP5.*;

public boolean uiHidden = false;

public class UIInteractionMgr implements ControlListener, SerialListener{
   HandTieArduinoSystemOnProcessingRobotControl mainClass;

   ControlP5 cp5;
   boolean launchComplete = false;

   // RadioButton properties
   RadioButton radioButton;
   public final static String RADIO_DISPLAY = "display";
   public final static float RADIO_HIDE_ITEMS = -1.0f;
   public final static float RADIO_SHOW_BAR_ITEM = 0.0f;
   public final static float RADIO_SHOW_BRIDGE_TARGET_MIN_AMP_ITEM = 1.0f;
   public final static float RADIO_SHOW_AMP_TARGET_CONST_BRIDGE_ITEM = 2.0f;
   public final static float RADIO_SHOW_BRIDGE_TARGET_CONST_AMP_ITEM = 3.0f;
   public final static float RADIO_SHOW_BRIDGE_POT_POS_ITEM = 4.0f;
   public final static float RADIO_SHOW_AMP_POT_POS_ITEM = 5.0f;

   // sliders
   public final static String SLIDER_BRIDGE_TARGET_MIN_AMP_ALL = "brdg\nmin\namp\nall";
   public final static String SLIDERS_BRIDGE_TARGET_MIN_AMP = "brdg\nmin\namp\n";

   public final static String SLIDER_AMP_TARGET_CONST_BRIDGE_ALL =  "amp\nconst\nbrdg\nall";
   public final static String SLIDERS_AMP_TARGET_CONST_BRIDGE = "amp\nconst\nbrdg\n";

   public final static String SLIDER_BRIDGE_TARGET_CONST_AMP_ALL = "brdg\nconst\namp\nall";
   public final static String SLIDERS_BRIDGE_TARGET_CONST_AMP = "brdg\nconst\namp\n";

   public final static String SLIDER_BRIDGE_POT_ALL = "b_Pot_all";
   public final static String SLIDER_AMP_POT_ALL = "a_Pot_all";
   public final static String SLIDERS_BRIDGE_POT = "b_Pot\n";
   public final static String SLIDERS_AMP_POT = "a_Pot\n";

   // buttons
   public final static String CALIBRATE = "calibrate";
   public final static String CALIBRATE_CONST_AMP = "calibrate (const amp)";
   public final static String CALIBRATE_ACCEL = "calibrate (accel)";

   // toggles
   public final static String ENABLE_SIGNAL_TO_ROBOT = "send to robot\n(on/off)";


   public UIInteractionMgr (HandTieArduinoSystemOnProcessingRobotControl mainClass) {
      this.mainClass = mainClass;

      cp5 = new ControlP5(mainClass);
      cp5.setColorValue(0);
      cp5.addListener(this);
      cp5.addListener(mainClass.sgManager);
      cp5.addListener(mainClass.serialManager);
      cp5.addListener(mainClass.accelMgr);
      cp5.addListener(mainClass.robotControl);
      createUIForSerial();
   }

   private void createUIForSerial(){
      float [] barOrigin = sgManager.getOneBarBaseCenterOfGauges(0);
      radioButton = cp5.addRadioButton(RADIO_DISPLAY)
                       .setPosition(width*0.1, height*0.86)
                       .setItemWidth(20)
                       .setItemHeight(20)
                       .addItem("bar", RADIO_SHOW_BAR_ITEM)
                       .addItem("bridge pot pos", RADIO_SHOW_BRIDGE_POT_POS_ITEM)
                       .addItem("amp pot pos", RADIO_SHOW_AMP_POT_POS_ITEM)
                       .addItem("bridge target (min amp)", RADIO_SHOW_BRIDGE_TARGET_MIN_AMP_ITEM)
                       .addItem("amp target (const bridge)", RADIO_SHOW_AMP_TARGET_CONST_BRIDGE_ITEM)
                       .addItem("bridge target (const amp)", RADIO_SHOW_BRIDGE_TARGET_CONST_AMP_ITEM)
                       .setColorLabel(color(0))
                       .activate(0)
                       .setItemsPerRow(3)
                       .setSpacingColumn((int)(width*0.15))
                    ;

      int i;
      for (i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         barOrigin = sgManager.getOneBarBaseCenterOfGauges(i);
         cp5.addSlider(SLIDERS_BRIDGE_TARGET_MIN_AMP+i)
            .setBroadcast(false)
            .setPosition(barOrigin[0]-4, barOrigin[1]-65)
            .setSize(10,80)
            .setRange(0,30)
            // .setValue(20)
            .setColorLabel(color(0))
            .setTriggerEvent(Slider.RELEASE)
            .setNumberOfTickMarks(31)
            .snapToTickMarks(true)
            .setDecimalPrecision(0)
            .showTickMarks(false)
            .setVisible(false)
            .setBroadcast(true)
         ;

         cp5.addSlider(SLIDERS_AMP_TARGET_CONST_BRIDGE+i)
            .setBroadcast(false)
            .setPosition(barOrigin[0]-4, barOrigin[1]-65)
            .setSize(10,80)
            .setRange(0,1000)
            // .setValue(sgManager.getOneCaliValForGauges(i))
            .setColorLabel(color(0))
            .setTriggerEvent(Slider.RELEASE)
            .setNumberOfTickMarks(21)
            .snapToTickMarks(true)
            .setDecimalPrecision(0)
            .showTickMarks(false)
            .setVisible(false)
            .setBroadcast(true)
         ;

         cp5.addSlider(SLIDERS_BRIDGE_TARGET_CONST_AMP+i)
            .setBroadcast(false)
            .setPosition(barOrigin[0]-4, barOrigin[1]-65)
            .setSize(10,80)
            .setRange(0,1000)
            // .setValue(255)
            .setColorLabel(color(0))
            .setTriggerEvent(Slider.RELEASE)
            .setNumberOfTickMarks(21)
            .snapToTickMarks(true)
            .setDecimalPrecision(0)
            .showTickMarks(false)
            .setVisible(false)
            .setBroadcast(true)
         ;

         cp5.addSlider(SLIDERS_BRIDGE_POT+i)
            .setBroadcast(false)
            .setPosition(barOrigin[0]-4, barOrigin[1]-65)
            .setSize(10,80)
            .setRange(0,255)
            // .setValue(255)
            .setColorLabel(color(0))
            .setTriggerEvent(Slider.RELEASE)
            .setNumberOfTickMarks(256)
            .snapToTickMarks(true)
            .setDecimalPrecision(0)
            .showTickMarks(false)
            .setVisible(false)
            .setBroadcast(true)
         ;

         cp5.addSlider(SLIDERS_AMP_POT+i)
            .setBroadcast(false)
            .setPosition(barOrigin[0]-4, barOrigin[1]-65)
            .setSize(10,80)
            .setRange(0,50)
            // .setValue(255)
            .setColorLabel(color(0))
            .setTriggerEvent(Slider.RELEASE)
            .setNumberOfTickMarks(51)
            .snapToTickMarks(true)
            .setDecimalPrecision(0)
            .showTickMarks(false)
            .setVisible(false)
            .setBroadcast(true)
         ;
      }

      barOrigin = sgManager.getOneBarBaseCenterOfGauges(i-1);
      cp5.addSlider(SLIDER_BRIDGE_TARGET_MIN_AMP_ALL)
         .setBroadcast(false)
         .setPosition(barOrigin[0]+35, barOrigin[1]-65)
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
         .setBroadcast(true)
      ;
      cp5.addSlider(SLIDER_AMP_TARGET_CONST_BRIDGE_ALL)
         .setBroadcast(false)
         .setPosition(barOrigin[0]+35, barOrigin[1]-65)
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
         .setBroadcast(true)
      ;
      cp5.addSlider(SLIDER_BRIDGE_TARGET_CONST_AMP_ALL)
         .setBroadcast(false)
         .setPosition(barOrigin[0]+35, barOrigin[1]-65)
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
         .setBroadcast(true)
      ;
      cp5.addSlider(SLIDER_BRIDGE_POT_ALL)
         .setBroadcast(false)
         .setPosition(barOrigin[0]+35, barOrigin[1]-65)
         .setSize(10,80)
         .setRange(0,255)
         // .setValue(20)
         .setColorLabel(color(0))
         .setTriggerEvent(Slider.RELEASE)
         .setNumberOfTickMarks(256)
         .snapToTickMarks(true)
         .setDecimalPrecision(0)
         .showTickMarks(false)
         .setVisible(false)
         .setBroadcast(true)
      ;
      cp5.addSlider(SLIDER_AMP_POT_ALL)
         .setBroadcast(false)
         .setPosition(barOrigin[0]+35, barOrigin[1]-65)
         .setSize(10,80)
         .setRange(0,50)
         // .setValue(20)
         .setColorLabel(color(0))
         .setTriggerEvent(Slider.RELEASE)
         .setNumberOfTickMarks(51)
         .snapToTickMarks(true)
         .setDecimalPrecision(0)
         .showTickMarks(false)
         .setVisible(false)
         .setBroadcast(true)
      ;
      cp5.addButton(CALIBRATE)
         .setBroadcast(false)
         .setValue(0)
         .setPosition(width*0.12, height*0.94)
         .setSize(100,20)
         .setBroadcast(true)
      ;
      cp5.addButton(CALIBRATE_CONST_AMP)
         .setBroadcast(false)
         .setValue(0)
         .setPosition(width*0.12 + 120, height*0.94)
         .setSize(100,20)
         .setBroadcast(true)
      ;
      cp5.addButton(CALIBRATE_ACCEL)
         .setBroadcast(false)
         .setValue(0)
         .setPosition(width*0.12 + 240, height*0.94)
         .setSize(100,20)
         .setBroadcast(true)
      ;
      cp5.addToggle(ENABLE_SIGNAL_TO_ROBOT)
         .setColorLabel(color(0))
         .setBroadcast(false)
         .setValue(0)
         .setPosition(width*0.85, height*0.5)
         .setSize(50,30)
         .setBroadcast(true)
      ;
      launchComplete = true;
   }

   @Override
   public void controlEvent(ControlEvent theEvent){
      if (!launchComplete)  return;
      println("performControlEvent: " + theEvent.getName());
      println("event value: " + theEvent.getValue());

      if (theEvent.getName().equals(SLIDER_BRIDGE_TARGET_MIN_AMP_ALL)) {
         manualChangeToAllGaugesBridgeTargetMinAmp(theEvent);
      } else if (theEvent.getName().equals(SLIDER_AMP_TARGET_CONST_BRIDGE_ALL)) {
         manualChangeToAllGaugesAmpTargetConstBridge(theEvent);
      } else if (theEvent.getName().equals(SLIDER_BRIDGE_TARGET_CONST_AMP_ALL)){
         manualChangeToAllGaugesBridgeTargetAtConstAmp(theEvent);
      } else if (theEvent.getName().equals(SLIDER_BRIDGE_POT_ALL)){
         manualChangeToAllGaugesBridgePot(theEvent);
      } else if (theEvent.getName().equals(SLIDER_AMP_POT_ALL)) {
         manualChangeToAllGaugesAmpPot(theEvent);
      } else if (theEvent.getName().equals(RADIO_DISPLAY)){
         changeDisplay(theEvent.getValue());
      }
   }

   private void manualChangeToAllGaugesBridgeTargetMinAmp(ControlEvent theEvent){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_BRIDGE_TARGET_MIN_AMP+i).setValue(theEvent.getValue());
      }
   }

   private void manualChangeToAllGaugesAmpTargetConstBridge(ControlEvent theEvent){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_AMP_TARGET_CONST_BRIDGE+i).setValue(theEvent.getValue());
      }
   }

   private void manualChangeToAllGaugesBridgeTargetAtConstAmp(ControlEvent theEvent){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_BRIDGE_TARGET_CONST_AMP+i).setValue(theEvent.getValue());
      }
   }

   private void manualChangeToAllGaugesBridgePot(ControlEvent theEvent){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_BRIDGE_POT+i).setValue(theEvent.getValue());
      }
   }

   private void manualChangeToAllGaugesAmpPot(ControlEvent theEvent){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_AMP_POT+i).setValue(theEvent.getValue());
      }
   }

   private void changeDisplay(float eventValue){
      hideAllUISliders();
      if (eventValue == RADIO_SHOW_BRIDGE_TARGET_MIN_AMP_ITEM){
         showUISliders(SLIDERS_BRIDGE_TARGET_MIN_AMP);
         cp5.controller(SLIDER_BRIDGE_TARGET_MIN_AMP_ALL).setVisible(true);
      } else if (eventValue == RADIO_SHOW_AMP_TARGET_CONST_BRIDGE_ITEM){
         showUISliders(SLIDERS_AMP_TARGET_CONST_BRIDGE);
         cp5.controller(SLIDER_AMP_TARGET_CONST_BRIDGE_ALL).setVisible(true);
      } else if (eventValue == RADIO_SHOW_BRIDGE_POT_POS_ITEM){
         showUISliders(SLIDERS_BRIDGE_POT);
         cp5.controller(SLIDER_BRIDGE_POT_ALL).setVisible(true);
      } else if (eventValue == RADIO_SHOW_AMP_POT_POS_ITEM){
         showUISliders(SLIDERS_AMP_POT);
         cp5.controller(SLIDER_AMP_POT_ALL).setVisible(true);
      } else if (eventValue == RADIO_SHOW_BRIDGE_TARGET_CONST_AMP_ITEM){
         showUISliders(SLIDERS_BRIDGE_TARGET_CONST_AMP);
         cp5.controller(SLIDER_BRIDGE_TARGET_CONST_AMP_ALL).setVisible(true);
      }
   }

   private void showUISliders(String sliderName){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(sliderName+i).setVisible(true);
      }
   }

   private void hideAllUISliders(){
      for (int i=0; i<SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_BRIDGE_TARGET_MIN_AMP+i).setVisible(false);
         cp5.controller(SLIDERS_AMP_TARGET_CONST_BRIDGE+i).setVisible(false);
         cp5.controller(SLIDERS_BRIDGE_POT+i).setVisible(false);
         cp5.controller(SLIDERS_AMP_POT+i).setVisible(false);
         cp5.controller(SLIDERS_BRIDGE_TARGET_CONST_AMP+i).setVisible(false);
      }
      cp5.controller(SLIDER_BRIDGE_TARGET_MIN_AMP_ALL).setVisible(false);
      cp5.controller(SLIDER_AMP_TARGET_CONST_BRIDGE_ALL).setVisible(false);
      cp5.controller(SLIDER_BRIDGE_POT_ALL).setVisible(false);
      cp5.controller(SLIDER_AMP_POT_ALL).setVisible(false);
      cp5.controller(SLIDER_BRIDGE_TARGET_CONST_AMP_ALL).setVisible(false);
   }

   public void performKeyPress(char k){
      switch (k) {
         case TAB :
            hideAllUISliders();
            cp5.controller(CALIBRATE)
               .setVisible(!cp5.controller(CALIBRATE).isVisible());
            cp5.controller(CALIBRATE_CONST_AMP)
               .setVisible(!cp5.controller(CALIBRATE_CONST_AMP).isVisible());
            radioButton.setVisible(!radioButton.isVisible());
            radioButton.setValue(RADIO_SHOW_BAR_ITEM);
            uiHidden = !uiHidden;
            break;
            
      }
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
   public void updateAnalogVals(float [] values){}
   @Override
   public void updateCaliVals(float [] values){}

   @Override
   public void updateTargetAnalogValsMinAmp(float [] values){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_BRIDGE_TARGET_MIN_AMP+i).setValue((float)values[i]);
      }
   }

   @Override
   public void updateTargetAnalogValsWithAmp(float [] values){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_AMP_TARGET_CONST_BRIDGE+i).setValue((float)values[i]);
         cp5.controller(SLIDERS_BRIDGE_TARGET_CONST_AMP+i).setValue((float)values[i]);
      }
   }

   @Override
   public void updateBridgePotPosVals(float [] values){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_BRIDGE_POT+i).setValue((float)values[i]);
      }
   }

   @Override
   public void updateAmpPotPosVals(float [] values){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_AMP_POT+i).setValue((float)values[i]);
      }
   }

   @Override
   public void updateCalibratingValsMinAmp(float [] values){}
   @Override
   public void updateCalibratingValsWithAmp(float [] values){}
   @Override
   public void updateReceiveRecordSignal(){}
}

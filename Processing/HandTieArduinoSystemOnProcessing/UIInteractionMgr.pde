import controlP5.*;

public boolean uiHidden = false;

public class UIInteractionMgr implements ControlListener, SerialListener{
   HandTieArduinoSystemOnProcessing mainClass;

   ControlP5 cp5;

   // RadioButton properties
   RadioButton radioButton;
   public final static String RADIO_DISPLAY = "display";
   public final static float RADIO_HIDE_ITEMS = -1.0f;
   public final static float RADIO_SHOW_BAR_ITEM = 0.0f;
   public final static float RADIO_SHOW_BRIDGE_ITEM = 1.0f;
   public final static float RADIO_SHOW_AMP_ITEM = 2.0f;
   public final static float RADIO_SHOW_BRIDGE_POT_POS_ITEM = 3.0f;
   public final static float RADIO_SHOW_AMP_POT_POS_ITEM = 4.0f;

   // sliders
   public final static String SLIDER_BRIDGE_ALL = "brdg_all";
   public final static String SLIDER_AMP_ALL =  "amp_all";
   public final static String SLIDERS_BRIDGE_TARGET = "brdg";
   public final static String SLIDERS_AMP_TARGET = "amp";
   public final static String SLIDERS_BRIDGE_POT = "b_Pot";
   public final static String SLIDERS_AMP_POT = "a_Pot";

   // buttons
   public final static String CALIBRATE = "calibrate";
   public final static String REQUEST_TARGET_VAL_NO_AMP="get targets (no amp)";
   public final static String REQUEST_TARGET_VAL_AMP = "get targets (amp)";

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
                       .setPosition(width*0.13, height*0.88)
                       .setItemWidth(20)
                       .setItemHeight(20)
                       .addItem("bar", RADIO_SHOW_BAR_ITEM)
                       .addItem("bridge target", RADIO_SHOW_BRIDGE_ITEM)
                       .addItem("amp target", RADIO_SHOW_AMP_ITEM)
                       .addItem("bridge pot pos", RADIO_SHOW_BRIDGE_POT_POS_ITEM)
                       .addItem("amp pot pos", RADIO_SHOW_AMP_POT_POS_ITEM)
                       .setColorLabel(color(0))
                       .activate(0)
                       .setItemsPerRow(5)
                       .setSpacingColumn((int)(width*0.08))
                    ;

      int i;
      for (i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         barOrigin = sgManager.getOneBarBaseCenterOfGauges(i);
         cp5.addSlider(SLIDERS_AMP_TARGET+i)
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

         cp5.addSlider(SLIDERS_BRIDGE_TARGET+i)
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

         cp5.addSlider(SLIDERS_BRIDGE_POT+i)
            .setPosition(barOrigin[0]-4, barOrigin[1]-40)
            .setSize(10,80)
            .setRange(0,255)
            .setValue(255)
            .setColorLabel(color(0))
            .setTriggerEvent(Slider.RELEASE)
            .setNumberOfTickMarks(256)
            .snapToTickMarks(true)
            .setDecimalPrecision(0)
            .showTickMarks(false)
            .setVisible(false)
         ;

         cp5.addSlider(SLIDERS_AMP_POT+i)
            .setPosition(barOrigin[0]-4, barOrigin[1]-40)
            .setSize(10,80)
            .setRange(0,255)
            .setValue(255)
            .setColorLabel(color(0))
            .setTriggerEvent(Slider.RELEASE)
            .setNumberOfTickMarks(256)
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
         .setPosition(width*0.2, height*0.93)
         .setSize(95,20)
      ;
      cp5.addButton(REQUEST_TARGET_VAL_NO_AMP)
         .setValue(0)
         .setPosition(width*0.2 + 100, height*0.93)
         .setSize(95,20)
      ;
      cp5.addButton(REQUEST_TARGET_VAL_AMP)
         .setValue(0)
         .setPosition(width*0.2 + 200, height*0.93)
         .setSize(95,20)
      ;
   }

   @Override
   public void controlEvent(ControlEvent theEvent){
      if (millis() < 1500) return;
      println("performControlEvent: " + theEvent.getName());
      println("event value: " + theEvent.getValue());

      if (theEvent.getName().equals(SLIDER_BRIDGE_ALL)) {
         manualChangeToAllGaugesNoAmp(theEvent);
      } else if (theEvent.getName().equals(SLIDER_AMP_ALL)) {
         manualChangeToAllGaugesWithAmp(theEvent);
      } else if (theEvent.getName().equals(RADIO_DISPLAY)){
         changeDisplay(theEvent.getValue());
      }
   }

   private void manualChangeToAllGaugesNoAmp(ControlEvent theEvent){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_BRIDGE_TARGET+i).setValue(theEvent.getValue());
      }
   }

   private void manualChangeToAllGaugesWithAmp(ControlEvent theEvent){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_AMP_TARGET+i).setValue(theEvent.getValue());
      }
   }

   private void changeDisplay(float eventValue){
      hideAllUISliders();
      if (eventValue == RADIO_SHOW_BRIDGE_ITEM){
         showUISliders(SLIDERS_BRIDGE_TARGET);
         cp5.controller(SLIDER_BRIDGE_ALL).setVisible(true);
      } else if (eventValue == RADIO_SHOW_AMP_ITEM){
         showUISliders(SLIDERS_AMP_TARGET);
         cp5.controller(SLIDER_AMP_ALL).setVisible(true);
      } else if (eventValue == RADIO_SHOW_BRIDGE_POT_POS_ITEM){
         showUISliders(SLIDERS_BRIDGE_POT);
      } else if (eventValue == RADIO_SHOW_AMP_POT_POS_ITEM){
         showUISliders(SLIDERS_AMP_POT);
      }
   }

   private void showUISliders(String sliderName){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(sliderName+i).setVisible(true);
      }
   }

   private void hideAllUISliders(){
      for (int i=0; i<SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_BRIDGE_TARGET+i).setVisible(false);
         cp5.controller(SLIDERS_AMP_TARGET+i).setVisible(false);
         cp5.controller(SLIDERS_BRIDGE_POT+i).setVisible(false);
         cp5.controller(SLIDERS_AMP_POT+i).setVisible(false);
      }
      cp5.controller(SLIDER_BRIDGE_ALL).setVisible(false);
      cp5.controller(SLIDER_AMP_ALL).setVisible(false);
   }

   public void performKeyPress(char k){
      switch (k) {
         case TAB :
            hideAllUISliders();
            cp5.controller(CALIBRATE)
               .setVisible(!cp5.controller(CALIBRATE).isVisible());
            cp5.controller(REQUEST_TARGET_VAL_AMP)
               .setVisible(!cp5.controller(REQUEST_TARGET_VAL_AMP).isVisible());
            cp5.controller(REQUEST_TARGET_VAL_NO_AMP)
               .setVisible(!cp5.controller(REQUEST_TARGET_VAL_NO_AMP).isVisible());
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
   public void updateAnalogVals(int [] values){}
   @Override
   public void updateCaliVals(int [] values){}

   @Override
   public void updateTargetAnalogValsNoAmp(int [] values){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_BRIDGE_TARGET+i).setValue((float)values[i]);
      }
   }

   @Override
   public void updateTargetAnalogValsWithAmp(int [] values){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_AMP_TARGET+i).setValue((float)values[i]);
      }
   }

   @Override
   public void updateBridgePotPosVals(int [] values){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_BRIDGE_POT+i).setValue((float)values[i]);
      }
   }

   @Override
   public void updateAmpPotPosVals(int [] values){
      for (int i = 0; i < SGManager.NUM_OF_GAUGES; ++i) {
         cp5.controller(SLIDERS_AMP_POT+i).setValue((float)values[i]);
      }
   }

   @Override
   public void updateCalibratingValsNoAmp(int [] values){}
   @Override
   public void updateCalibratingValsWithAmp(int [] values){}
   @Override
   public void updateReceiveRecordSignal(){}
}

public class SGManager implements ControlListener, SerialListener{
   
   public final static int NUM_OF_GAUGES = 15;
   public boolean hideBar = false;
   public boolean hideNormalText = false;
   public boolean hideCalibratingText = true;

   private StrainGauge [] gauges = new StrainGauge[NUM_OF_GAUGES];

   private SerialNotifier serialNotifier;

   public SGManager(){
      for (int i = 0; i < gauges.length; ++i) {
         gauges[i] = new StrainGauge(i);
         // println("width = " + width);
         gauges[i].setBarDisplayProperties(width*(i+1)*0.04,
                                           height*0.67, 20);
         gauges[i].setTextDisplayPropertiesForGaugeIdx(width*(i+1)*0.04-3,
                                                       // height*((i%2==1)?0.81:0.79),
                                                       height*0.79,
                                                       12);
         gauges[i].setTextDisplayPropertiesForElong(width*(i+1)*0.04-5,
                                                    // height*((i%2==1)?0.84:0.82),
                                                    height*0.82,
                                                    12);
         gauges[i].setTextDisplayPropertiesForAnalogVal(width*(i+1)*0.04-5,
                                                        // height*((i%2==1)?0.87:0.85),
                                                        height*0.85,
                                                        12);
      }
   }

   public float getOneCaliValForGauges(int index){
      return gauges[index].getCalibrationValue();
   }

   public float [] getAnalogValsOfGauges(){
      float[] analogVals = new float[gauges.length];
      for (int i = 0; i < gauges.length; ++i) {
         analogVals[i] = gauges[i].getNewValue();
      }
      return analogVals;
   }

   public float getOneAnalogValOfGauges(int index){
      return gauges[index].getNewValue();
   }

   public float [] getElongationValsOfGauges(){
      float [] elongationVals = new float[gauges.length];
      for (int i = 0; i < gauges.length; ++i) {
         elongationVals[i] = gauges[i].getElongationValue();
      }
      return elongationVals;
   }

   public float getOneElongationValsOfGauges(int index){
      return gauges[index].getElongationValue();
   }

   public float [] getOneBarBaseCenterOfGauges(int index){
      return gauges[index].getBarBaseCenter();
   }

   public void draw(){
      for (int i = 0; i < gauges.length; i++) {
         if (!hideBar)  gauges[i].drawBar();
         if (!hideNormalText) gauges[i].drawText();
         if (!hideCalibratingText) {
            fill(50, 100, 255, 255);
            textSize(15);
            text("Calibrating...", width*0.04, height*0.7-100);
            gauges[i].drawCalibratingText();
         }
      }
   }

   public void performKeyPress(char k){
      switch (k) {
         case TAB:
            if (uiHidden) {
               changeDisplay(UIInteractionMgr.RADIO_HIDE_ITEMS);
            } else {
               changeDisplay(UIInteractionMgr.RADIO_SHOW_BAR_ITEM);
            }
            break;
      }
   }

   @Override
   public void registerToSerialNotifier(SerialNotifier notifier){
      notifier.registerForSerialListener(this);
      serialNotifier = notifier;
   }

   @Override
   public void removeToSerialNotifier(SerialNotifier notifier){
      notifier.removeSerialListener(this);
      serialNotifier = null;
   }
   
   @Override
   public void updateAnalogVals(float [] values){
      for (int i = 0; i < gauges.length; ++i) {
         gauges[i].setNewValue(values[i]);
      }
   }

   @Override
   public void updateCaliVals(float [] values){
      hideCalibratingText = true;
      for (int i = 0; i < gauges.length; ++i) {
         gauges[i].setCalibrationValue(values[i]);
      }
   }

   @Override
   public void updateTargetAnalogValsMinAmp(float [] values){}
   @Override
   public void updateTargetAnalogValsWithAmp(float [] values){}
   @Override
   public void updateBridgePotPosVals(float [] values){}
   @Override
   public void updateAmpPotPosVals(float [] values){}
   @Override
   public void updateCalibratingValsMinAmp(float [] values){
      hideCalibratingText = hideBar;
      for (int i = 0; i < NUM_OF_GAUGES; ++i) {
         gauges[i].setCalibratingValue(values[i]);
      }
   }
   @Override
   public void updateCalibratingValsWithAmp(float [] values){
      hideCalibratingText = hideBar;
      for (int i = 0; i < NUM_OF_GAUGES; ++i) {
         gauges[i].setCalibratingValue(values[i]);
      }
   }

   @Override
   public void updateReceiveRecordSignal(){}

   @Override
   public void controlEvent(ControlEvent theEvent){
      if (millis()<1000) return;
      
      if (theEvent.getName().equals(UIInteractionMgr.RADIO_DISPLAY)) {
         changeDisplay(theEvent.getValue());
      } else if (theEvent.getName().contains(UIInteractionMgr.ENABLE_STRAIN_GAUGE)){
         enableOrDisableStrainGauge(theEvent,UIInteractionMgr.ENABLE_STRAIN_GAUGE);
      }
   }

   private void changeDisplay(float eventValue){
      if (eventValue == UIInteractionMgr.RADIO_SHOW_BAR_ITEM) {
         hideNormalText = false;
         hideBar = false;
      } else if (eventValue == UIInteractionMgr.RADIO_HIDE_ITEMS) {
         hideNormalText = true;
         hideBar = true;
      } else {
         hideNormalText = false;
         hideBar = true;
      }
   }

   private void enableOrDisableStrainGauge(ControlEvent theEvent, String splitStr){
      String [] nameSplit = theEvent.getName().split(splitStr);

      int index = Integer.parseInt(nameSplit[1]);
      gauges[index].enable = (theEvent.getValue() == 1.0f) ? true : false;
   }
}

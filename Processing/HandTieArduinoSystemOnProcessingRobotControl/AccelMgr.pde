public class AccelMgr implements ControlListener, SerialListener{
   public static final int NUM_OF_AXIS = 3;

   private boolean hideBar = false;
   private boolean hideNormalText = false;
   private boolean hideCalibratingText = true;
   private boolean enable = true;

   private AccelAxis [] axis = new AccelAxis[NUM_OF_AXIS];
   
   private SerialNotifier serialNotifier;
   
   public AccelMgr(){
      for (int i = 0; i < axis.length; ++i) {
         axis[i] = new AccelAxis((Character.toString((char)(i+120))));
         axis[i].setBarDisplayProperties(width*(i+1+SGManager.NUM_OF_GAUGES+1)*0.04,
                                         height*0.67, 20);
         axis[i].setTextDisplayPropertiesForAxisName(width*(i+1+SGManager.NUM_OF_GAUGES+1)*0.04-3,
                                                     // height*((i%2==1)?0.81:0.79),
                                                     height*0.79,
                                                     12);
         axis[i].setTextDisplayPropertiesForDifferenceVal(width*(i+1+SGManager.NUM_OF_GAUGES+1)*0.04-5,
                                                          // height*((i%2==1)?0.84:0.82),
                                                          height*0.82,
                                                          8);
         axis[i].setTextDisplayPropertiesForNewVal(width*(i+1+SGManager.NUM_OF_GAUGES+1)*0.04-5,
                                                   // height*((i%2==1)?0.87:0.85),
                                                   height*0.85,
                                                   8);
      }
   }

   public float getOneAxisCaliVal(int idx){
      return axis[idx].getCalibrationValue();
   }

   public float getOneAxisCaliVal(char idx){
      return getOneAxisCaliVal((int)idx-120);
   }

   public float getOneAxisNewVal(int idx){
      return enable ? axis[idx].getNewValue() : 0.0f;
   }

   public float getOneAxisNewVal(char idx){
      return getOneAxisNewVal((int)idx-120);
   }

   public float getOneAxisDifference(int idx){
      return enable ? axis[idx].getDifferenceVal() : 0.0f;
   }

   public float getOneAxisDifference(char idx){
      return getOneAxisDifference((int)idx-120);
   }

   public void calibrateUsingNewValues(){
      for (int i = 0; i < axis.length; ++i) {
         axis[i].calibrateUsingNewValue();
      }
   }

   public void draw(){
      for (int i = 0; i < axis.length; ++i) {
         if (!hideBar && enable) axis[i].drawBar();
         if (!hideNormalText) axis[i].drawText(); 
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
   public void updateDiscoveredSerialPorts(String [] portNames){}

   @Override
   public void updateAnalogVals(float [] values){
      for (int i = 0; i < axis.length; ++i) {
         axis[i].setNewValue(values[i+SGManager.NUM_OF_GAUGES]);
      }
   }

   @Override
   public void updateCaliVals(float [] values){
      hideCalibratingText = true;
      for (int i = 0; i < axis.length; ++i) {
         axis[i].setCalibrationValue(values[i+SGManager.NUM_OF_GAUGES]);
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
   public void updateCalibratingValsMinAmp(float [] values){}
   @Override
   public void updateCalibratingValsWithAmp(float [] values){}

   @Override
   public void updateReceiveRecordSignal(){}

   @Override
   public void controlEvent(ControlEvent theEvent){
      if (millis()<1000) return;
      
      if (theEvent.getName().equals(UIInteractionMgr.RADIO_DISPLAY)) {
         changeDisplay(theEvent.getValue());
      } else if (theEvent.getName().equals(UIInteractionMgr.CALIBRATE_ACCEL)){
         calibrateUsingNewValues();
      } else if (theEvent.getName().equals(UIInteractionMgr.ENABLE_ACCEL)){
         enable = (theEvent.getValue() == 1.0f) ? true : false;
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
}

public interface SerialListener{
   public void registerToSerialNotifier(SerialNotifier notifier);
   public void removeToSerialNotifier(SerialNotifier notifier);
   
   public void updateAnalogVals(int [] values);
   public void updateCaliVals(int [] values);
   public void updateTargetAnalogValsMinAmp(int [] values);
   public void updateTargetAnalogValsWithAmp(int [] values);
   public void updateBridgePotPosVals(int [] values);
   public void updateAmpPotPosVals(int [] values);
   public void updateCalibratingValsMinAmp(int [] values);
   public void updateCalibratingValsWithAmp(int [] values);
   public void updateReceiveRecordSignal();
}
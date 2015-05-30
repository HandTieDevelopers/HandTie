public interface SerialListener{
   public void registerToSerialNotifier(SerialNotifier notifier);
   public void removeToSerialNotifier(SerialNotifier notifier);
   
   public void updateAnalogVals(float [] values);
   public void updateCaliVals(float [] values);
   public void updateTargetAnalogValsMinAmp(float [] values);
   public void updateTargetAnalogValsWithAmp(float [] values);
   public void updateBridgePotPosVals(float [] values);
   public void updateAmpPotPosVals(float [] values);
   public void updateCalibratingValsMinAmp(float [] values);
   public void updateCalibratingValsWithAmp(float [] values);
   public void updateReceiveRecordSignal();
}
public interface SerialListener{
   public void registerToSerialNotifier(SerialNotifier notifier);
   public void removeToSerialNotifier(SerialNotifier notifier);
   
   public void updateAnalogVals(int [] values);
   public void updateCaliVals(int [] values);
   public void updateTargetAnalogValsNoAmp(int [] values);
   public void updateTargetAnalogValsWithAmp(int [] values);
   public void updateCalibratingValsNoAmp(int [] values);
   public void updateCalibratingValsWithAmp(int [] values);
}
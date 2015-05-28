public interface SerialNotifier{
   public void registerForSerialListener(SerialListener listener);
   public void removeSerialListener(SerialListener listener);
   
   public void notifyAllWithAnalogVals(float [] values);
   public void notifyAllWithCaliVals(float [] values);
   public void notifyAllWithTargetAnalogValsMinAmp(float [] values);
   public void notifyAllWithTargetAnalogValsWithAmp(float [] values);
   public void notifyAllWithBridgePotPosVals(float [] values);
   public void notifyAllWithAmpPotPosVals(float [] values);
   public void notifyAllWithCalibratingValsMinAmp(float [] values);
   public void notifyAllWithCalibratingValsWithAmp(float [] values);
   public void notifyAllWithReceiveRecordSignal();
}
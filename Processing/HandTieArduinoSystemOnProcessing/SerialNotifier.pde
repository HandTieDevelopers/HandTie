public interface SerialNotifier{
   public void registerForSerialListener(SerialListener listener);
   public void removeSerialListener(SerialListener listener);
   
   public void notifyAllWithAnalogVals(int [] values);
   public void notifyAllWithCaliVals(int [] values);
   public void notifyAllWithTargetAnalogValsMinAmp(int [] values);
   public void notifyAllWithTargetAnalogValsWithAmp(int [] values);
   public void notifyAllWithBridgePotPosVals(int [] values);
   public void notifyAllWithAmpPotPosVals(int [] values);
   public void notifyAllWithCalibratingValsMinAmp(int [] values);
   public void notifyAllWithCalibratingValsWithAmp(int [] values);
   public void notifyAllWithReceiveRecordSignal();
}
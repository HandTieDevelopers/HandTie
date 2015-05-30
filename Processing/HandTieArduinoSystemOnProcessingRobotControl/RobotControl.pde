public class RobotControl implements GRTListener, ControlListener{
   final static int SERIAL_PORT_BAUD_RATE = 38400;
   final static int SERIAL_PORT_NUM = 6;

   final static float likelihoodThreshold = 0.7f;

   boolean sendEnable = false;

   Serial robotPort;
   PApplet parent; 
    
   public RobotControl(PApplet mainClass){
      parent = mainClass;
      println(Serial.list());
      String portName = Serial.list()[SERIAL_PORT_NUM];
      try{
        robotPort = new Serial(mainClass, portName, SERIAL_PORT_BAUD_RATE);
      }catch(Exception e){
        println(e.getMessage());
        System.exit(0);
      }
      println("  -> Using port " + SERIAL_PORT_NUM + ": " + portName);
      
      robotPort.bufferUntil(10);    //newline
   }
  
   public void sendToRobot(String str){
     try{ 
       robotPort.write(str);
     }
     catch(Exception e) {
       println(e.getMessage());
     }
   }

   public void performKeyPress(char k){
     if(k == 'z') {
       String portName = Serial.list()[SERIAL_PORT_NUM];
       //while(true) {
         try{
           robotPort = new Serial(parent, portName, SERIAL_PORT_BAUD_RATE);
         }catch(Exception e){
           println(e.getMessage()); 
         }
       //}
     }
     else { 
       sendToRobot(String.valueOf(k));
     }
   }

   @Override
   public void registerToGRTNotifier(GRTNotifier notifier){
      notifier.registerForGRTListener(this);
   }
   @Override
   public void removeToGRTNotifier(GRTNotifier notifier){
      notifier.removeGRTListener(this);
   }
   @Override
   public void updateGRTResults(int label, float likelihood){
      if (likelihood > likelihoodThreshold && sendEnable) {
         sendToRobot(String.valueOf((char)(label+96)));
      }
   }

   @Override
   public void controlEvent(ControlEvent theEvent){
      if (millis() < 1000) return;

      if (theEvent.getName().equals(UIInteractionMgr.ENABLE_SIGNAL_TO_ROBOT)) {
         sendEnable = (theEvent.getValue() == 1.0f)? true : false;
      }
   }
}

public class RobotControl implements GRTListener, ControlListener{
   final static int SERIAL_PORT_BAUD_RATE = 38400;
   final static int SERIAL_PORT_NUM = 6;

   final static float likelihoodThreshold = 0.7f;

   boolean sendEnable = false;

   Serial robotPort;
   PApplet mainClass; 
    
   public RobotControl(PApplet mainClass){
      this.mainClass = mainClass;
   }
  
   private void connectToSerial(){
      // Setup serial port I/O
      println("AVAILABLE SERIAL PORTS:");
      println(Serial.list());
      String portName = Serial.list()[SERIAL_PORT_NUM];
      connectToSerial(portName);
   }

   private void connectToSerial(int portNumber){
      String portName = Serial.list()[portNumber];
      connectToSerial(portName);
   }

   private void connectToSerial(String portName){
      println();
      println("LOOK AT THE LIST ABOVE AND SET THE RIGHT SERIAL PORT NUMBER IN THE CODE!");
      println("  -> Using port : " + portName);
      disconnectSerial();

      try {
         robotPort = new Serial(mainClass, portName, SERIAL_PORT_BAUD_RATE);
         robotPort.bufferUntil(10);    //newline
      } catch (Exception e) {
         println("connectToSerial : " + e.getMessage());
      }
   }

   private void disconnectSerial(){
      try {
         robotPort.clear();
         robotPort.stop();
      } catch (Exception e) {
         println("disconnectSerial : " + e.getMessage());
      }
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
      sendToRobot(String.valueOf(k));
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
      } else if (theEvent.getName().equals(UIInteractionMgr.DROPDOWN_ROBOT_SERIAL_LIST)){
         connectToSerial((int)(theEvent.getValue()));
      }
   }
}

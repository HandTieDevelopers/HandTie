public class RobotControl implements GRTListener{
   final static int SERIAL_PORT_BAUD_RATE = 38400;
   final static int SERIAL_PORT_NUM = 7;

   final static float likelihoodThreshold = 0.7f;

   Serial robotPort;

   public RobotControl(PApplet mainClass){
      println(Serial.list());
      String portName = Serial.list()[SERIAL_PORT_NUM];
      robotPort = new Serial(mainClass, portName, SERIAL_PORT_BAUD_RATE);
      println("  -> Using port " + SERIAL_PORT_NUM + ": " + portName);
      
      robotPort.bufferUntil(10);    //newline
   }

   public void sendToRobot(String str){
      robotPort.write(str);
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
      if (likelihood > likelihoodThreshold) {
         sendToRobot(String.valueOf((char)(label+96)));
      }
   }
}

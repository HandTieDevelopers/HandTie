public class RobotControl{
   final static int SERIAL_PORT_BAUD_RATE = 38400;
   final static int SERIAL_PORT_NUM = 7;

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
}

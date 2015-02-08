import processing.serial.*;
import java.util.ArrayList;

public class SerialManager implements SerialNotifier{

   final static int SERIAL_PORT_BAUD_RATE = 115200;

   final static int SERIAL_PORT_NUM = 5;

   public final static int ALL_CALIBRATION = 0;
   public final static int MANUAL_CHANGE_TO_ONE_GAUGE_NO_AMP = 1;
   public final static int MANUAL_CHANGE_TO_ONE_GAUGE_WITH_AMP = 2;
   public final static int MANUAL_CHANGE_TO_ALL_GAUGES_NO_AMP = 3;
   public final static int MANUAL_CHANGE_TO_ALL_GAUGES_WITH_AMP= 4;

   HandTieArduinoSystemOnProcessing mainClass;

   Serial arduinoPort;

   ArrayList<SerialListener> serialListeners = new ArrayList<SerialListener>();

   public SerialManager(HandTieArduinoSystemOnProcessing mainClass){
      this.mainClass = mainClass;
      // Setup serial port I/O
      println("AVAILABLE SERIAL PORTS:");
      println(Serial.list());
      String portName = Serial.list()[SERIAL_PORT_NUM];
      println();
      println("LOOK AT THE LIST ABOVE AND SET THE RIGHT SERIAL PORT NUMBER IN THE CODE!");
      println("  -> Using port " + SERIAL_PORT_NUM + ": " + portName);
      arduinoPort = new Serial(mainClass, portName, SERIAL_PORT_BAUD_RATE);
      arduinoPort.bufferUntil(10);    //newline
   }

   private int [] parseSpaceSeparatedData(Serial port) throws Exception{
      String buf = port.readString();
      String [] bufSplitArr = buf.split(" ");
      int [] parsedDataArr = new int[bufSplitArr.length-1];

      for (int i = 0; i < bufSplitArr.length-1; ++i)
         parsedDataArr[i] = Integer.parseInt(bufSplitArr[i]);

      return parsedDataArr;
   }

   public void parseDataFromSerial(Serial port) throws Exception{
      if (port.equals(arduinoPort)) {
         parseDataFromArduino(port);
      }
   }

   private void parseDataFromArduino(Serial port) throws Exception{
      int [] analogVals = parseSpaceSeparatedData(port);
      notifyAllWithAnalogVals(analogVals);
   }

   public void sendToArduino(String str){
      arduinoPort.write(str);
   }

   public void registerForSerialListener(SerialListener listener){
      serialListeners.add(listener);
   }

   public void removeSerialListener(SerialListener listener){
      serialListeners.remove(listener);
   }

   public void notifyAllWithAnalogVals(int [] values){
      for (SerialListener listener : serialListeners) {
         listener.updateAnalogVals(values);
      }
   }

   public void notifyAllWithCaliVals(int [] values){
      for (SerialListener listener : serialListeners) {
         listener.updateCaliVals(values);
      }
   }

   public void notifyAllWithTargetAnalogValsNoAmp(int [] values){
      for (SerialListener listener : serialListeners) {
         listener.updateTargetAnalogValsNoAmp(values);
      }
   }

   public void notifyAllWithTargetAnalogValsWithAmp(int [] values){
      for (SerialListener listener : serialListeners) {
         listener.updateTargetAnalogValsWithAmp(values);
      }
   }
}

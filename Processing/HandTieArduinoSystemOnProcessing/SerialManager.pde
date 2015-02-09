import processing.serial.*;
import java.util.ArrayList;
import java.util.Arrays;

public class SerialManager implements ControlListener, SerialNotifier{

   final static int SERIAL_PORT_BAUD_RATE = 115200;

   final static int SERIAL_PORT_NUM = 5;

   //send to arduino protocol
   public final static int ALL_CALIBRATION = 0;
   public final static int MANUAL_CHANGE_TO_ONE_GAUGE_NO_AMP = 1;
   public final static int MANUAL_CHANGE_TO_ONE_GAUGE_WITH_AMP = 2;
   public final static int MANUAL_CHANGE_TO_ALL_GAUGES_NO_AMP = 3;
   public final static int MANUAL_CHANGE_TO_ALL_GAUGES_WITH_AMP = 4;
   public final static int REQUEST_FOR_TARGET_VALS_NO_AMP = 5;
   public final static int REQUEST_FOR_TARGET_VALS_WITH_AMP = 6;

   //receive from arduino protocol
   public final static int RECEIVE_NORMAL_VALS = 0;
   public final static int RECEIVE_CALI_VALS = 1;
   public final static int RECEIVE_TARGET_NO_AMP_VALS = 2;
   public final static int RECEIVE_TARGET_AMP_VALS = 3;

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
      switch (analogVals[0]) {
         case RECEIVE_NORMAL_VALS:
            notifyAllWithAnalogVals(Arrays.copyOfRange(analogVals, 1,
                                                       analogVals.length));
            break;
         case RECEIVE_CALI_VALS:
            notifyAllWithCaliVals(Arrays.copyOfRange(analogVals, 1,
                                                     analogVals.length));
            break;
         case RECEIVE_TARGET_NO_AMP_VALS:
            notifyAllWithTargetAnalogValsNoAmp(Arrays.copyOfRange(analogVals, 1,
                                                                  analogVals.length));
            break;
         case RECEIVE_TARGET_AMP_VALS:
            notifyAllWithTargetAnalogValsWithAmp(Arrays.copyOfRange(analogVals, 1,
                                                                    analogVals.length));
            break;
      }
   }

   public void sendToArduino(String str){
      arduinoPort.write(str);
   }

   public void performKeyPress(char k){
      switch (k) {
         case 'c' :
            sendToArduino(Integer.toString(ALL_CALIBRATION));
            break;
      }
   }

   @Override
   public void registerForSerialListener(SerialListener listener){
      serialListeners.add(listener);
   }

   @Override
   public void removeSerialListener(SerialListener listener){
      serialListeners.remove(listener);
   }

   @Override
   public void notifyAllWithAnalogVals(int [] values){
      for (SerialListener listener : serialListeners) {
         listener.updateAnalogVals(values);
      }
   }

   @Override
   public void notifyAllWithCaliVals(int [] values){
      for (SerialListener listener : serialListeners) {
         listener.updateCaliVals(values);
      }
   }

   @Override
   public void notifyAllWithTargetAnalogValsNoAmp(int [] values){
      for (SerialListener listener : serialListeners) {
         listener.updateTargetAnalogValsNoAmp(values);
      }
   }

   @Override
   public void notifyAllWithTargetAnalogValsWithAmp(int [] values){
      for (SerialListener listener : serialListeners) {
         listener.updateTargetAnalogValsWithAmp(values);
      }
   }

   @Override
   public void controlEvent(ControlEvent theEvent){
      if (millis() < 1000) return;

      if (theEvent.getName().equals(UIInteractionMgr.SLIDER_BRIDGE_ALL)) {
         manualChangeAllGauges(MANUAL_CHANGE_TO_ALL_GAUGES_NO_AMP, theEvent);
      } else if (theEvent.getName().equals(UIInteractionMgr.SLIDER_AMP_ALL)){
         manualChangeAllGauges(MANUAL_CHANGE_TO_ALL_GAUGES_WITH_AMP, theEvent);
      } else if (theEvent.getName().equals(UIInteractionMgr.CALIBRATE)){
         sendToArduino(Integer.toString(ALL_CALIBRATION));
      } else if (theEvent.getName().equals(UIInteractionMgr.REQUEST_TARGET_VAL_NO_AMP)){
         sendToArduino(Integer.toString(REQUEST_FOR_TARGET_VALS_NO_AMP));
      } else if (theEvent.getName().equals(UIInteractionMgr.REQUEST_TARGET_VAL_AMP)){
         sendToArduino(Integer.toString(REQUEST_FOR_TARGET_VALS_WITH_AMP));
      } else if (theEvent.getName().contains(UIInteractionMgr.SLIDERS_BRIDGE)){
         manualChangeOneGauge(MANUAL_CHANGE_TO_ONE_GAUGE_NO_AMP, theEvent);
      } else if (theEvent.getName().contains(UIInteractionMgr.SLIDERS_AMP)){
         manualChangeOneGauge(MANUAL_CHANGE_TO_ONE_GAUGE_WITH_AMP, theEvent);
      }
   }

   private void manualChangeAllGauges(int protocol, ControlEvent theEvent){
      String sendMessage = new String(protocol + " "
                                      + (int)(theEvent.getValue()));
      sendToArduino(sendMessage);
   }

   private void manualChangeOneGauge(int protocol, ControlEvent theEvent){
      String [] nameSplit = null;
      switch (protocol) {
         case MANUAL_CHANGE_TO_ONE_GAUGE_NO_AMP :
            nameSplit = theEvent.getName()
                                .split(UIInteractionMgr.SLIDERS_BRIDGE);
            break;
         case MANUAL_CHANGE_TO_ONE_GAUGE_WITH_AMP :
            nameSplit = theEvent.getName()
                                .split(UIInteractionMgr.SLIDERS_AMP);
            break;
      }

      int index = Integer.parseInt(nameSplit[1]);

      String sendMessage = new String(protocol + " " + index + " "
                                      + (int)(theEvent.getValue()));
      sendToArduino(sendMessage);
   }
}

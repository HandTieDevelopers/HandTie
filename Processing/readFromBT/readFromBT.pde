import processing.serial.Serial;

final static int lf = 10; //newline ASCII
final static int NUM_OF_GAUGE = 5;
final static int ACCEL_DIM = 3;
final static int TOTAL_SENSOR_VALUES = NUM_OF_GAUGE + ACCEL_DIM;
int[] analogVals = new int[NUM_OF_GAUGE + ACCEL_DIM];
//int[] analogTempVals = new int[NUM_OF_GAUGE + ACCEL_DIM];
int[] strainCaliVals = new int[NUM_OF_GAUGE];

final static String[] btSerialPortNames = new String[]{"/dev/tty.ARD_SPP-","/dev/tty.LinkItBTServer-"};
Serial btSerialPort = null;
int btDefaultBaudRate = 57600; //seems right after testing

void setup() {
  
  while(true) {
    for(String name : btSerialPortNames) {
      try {
        btSerialPort = new Serial(this,name,btDefaultBaudRate);
        break;
      }
      catch(Exception e) {
        btSerialPort = null;
        println(e.getMessage());
      }
    }
    if(btSerialPort != null) {
      break;
    }
  }
  
  if(btSerialPort == null) {
    exit();
  }
  btSerialPort.bufferUntil(lf); //buffering until reading a lf char and call serial event
  
}

void readSensorRawData(String str) throws Exception{
  String[] rawDataStrArr = str.split(" ");
  int numSplitedStrs = rawDataStrArr.length;
  if(numSplitedStrs == TOTAL_SENSOR_VALUES + 2) {
    for (int i = 1; i < numSplitedStrs-1; ++i) {
      analogVals[i-1] = Integer.parseInt(rawDataStrArr[i]);
    }
  }
  return;
}

void copyCalibrationData() throws Exception{
  for (int i = 0; i < NUM_OF_GAUGE; ++i) {
    strainCaliVals[i] = analogVals[i];
  }
}

void serialEvent(Serial port) {
  try {
    String buf = port.readString();
    char identifer = buf.charAt(0);
    if(identifer != 'n' && identifer != 'c') { //maybe data is read uncompletely
      return;
    }
    readSensorRawData(buf);
    if(identifer == 'c') {
      copyCalibrationData();
    }
  }
  catch (Exception e) {
    println(e.getMessage());
  }
}

void draw() {
  
  for(int i = 0;i < NUM_OF_GAUGE + ACCEL_DIM;i++) {
    print(analogVals[i] + " ");  
  }
  println("");
  
}

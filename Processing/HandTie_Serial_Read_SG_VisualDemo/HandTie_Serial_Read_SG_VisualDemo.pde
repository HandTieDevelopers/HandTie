import processing.serial.*;

import java.awt.event.KeyEvent;

final static int NUM_OF_GAUGE = 5;
final static int ACCEL_DIM = 3;

boolean createFileFlag;
boolean createLabelFlag;
boolean enterFileNameFlag;
boolean enterLabelNameFlag;
boolean CanDataFlag;
boolean CanLabelFlag;
boolean RecordDataFlag;

String filename = null;
String NowLabel = null;

color stretch = color(4, 79, 111);
color compress = color(84, 145, 158);
color ColorRecord = color(240, 200, 200);
color ColorIdle = color(200, 200, 200);

int Width = 1024;
int Height = 768;
float mul = 1;
int[] analogVals = new int[NUM_OF_GAUGE + ACCEL_DIM];
int[] strainCaliVals = new int[NUM_OF_GAUGE];
int[] accelMax = new int[ACCEL_DIM];
int[] accelMin = new int[ACCEL_DIM];
float[] accel = new float[ACCEL_DIM];
double[] elongRatios = new double[NUM_OF_GAUGE];

int[] x = new int[0];
int[] y = new int[0];

Table csvTable;

// IF THE SKETCH CRASHES OR HANGS ON STARTUP, MAKE SURE YOU ARE USING THE RIGHT SERIAL PORT:
// 1. Have a look at the Processing console output of this sketch.
// 2. Look for the serial port list and find the port you need (it's the same as in Arduino).
// 3. Set your port number here:
final static int SERIAL_PORT_NUM = 0;
// 4. Try again.


final static int SERIAL_PORT_BAUD_RATE = 57600;

int lf = 10;
Serial serial;

void setup() 
{
  createFileFlag = false;
  createLabelFlag = false;
  RecordDataFlag = false;
 
  CanDataFlag = false;
  CanLabelFlag = false;
  size(Width, Height);
  
  csvTable = new Table();
  
  csvTable.addColumn("label");
  csvTable.addColumn("Finger0");
  csvTable.addColumn("Finger1");
  csvTable.addColumn("Finger2");
  csvTable.addColumn("Finger3");
  csvTable.addColumn("Finger4");
  csvTable.addColumn("accx");
  csvTable.addColumn("accy");
  csvTable.addColumn("accz");

  // Setup serial port I/O
  println("AVAILABLE SERIAL PORTS:");
  println(Serial.list());
  String portName = Serial.list()[SERIAL_PORT_NUM];
  println();
  println("HAVE A LOOK AT THE LIST ABOVE AND SET THE RIGHT SERIAL PORT NUMBER IN THE CODE!");
  println("  -> Using port " + SERIAL_PORT_NUM + ": " + portName);
  serial = new Serial(this, portName, SERIAL_PORT_BAUD_RATE);
  serial.bufferUntil(lf);
}

void serialEvent(Serial port) {
  try {
    String buf = port.readString();
    analogVals = readSensorRawData(buf);
    if(buf.charAt(0) == 'c') {
      copyCalibrationData();
    }
  }
  catch (Exception e) {
    e.getMessage();
  }
}

void draw() 
{
  
  if(RecordDataFlag){
    background(ColorRecord);
  }
  else{
    background(ColorIdle);
  }
  line(0, Height*(0.4), Width, Height*(0.4));

  textSize(20);
  for (int i = 0; i < NUM_OF_GAUGE; i++) {
    double strainData = analogVals[i];
    elongRatios[i] = strainData / strainCaliVals[i];
    
    if(elongRatios[i]>1){
      fill(stretch);
      rect(Width*(i+1)*0.1, (float)(Height*(0.4)-Height*mul*(elongRatios[i]-1)), 50, (float)(Height*mul*(elongRatios[i]-1)));
    }
    else{
      fill(compress);
      rect(Width*(i+1)*0.1, (float)Height*(0.4), 50, (float)(Height*mul*(1-elongRatios[i])));
    }
    
    fill(0, 102, 10);
    text((float)elongRatios[i], Width*(i+1)*0.1, Height*(0.73)); 
    fill(150, 150, 150);
    text((int)strainData, Width*(i+1)*0.1, Height*(0.8)); 
    fill(255, 0, 0);
    text("Label:"+NowLabel, Width*0.01, Height*(0.9)); 
  }

//  for (int i = NUM_OF_GAUGE; i < NUM_OF_GAUGE+ACCEL_DIM; i++) {
//    if(analogVals[i]>0){
//      fill(stretch);
//      rect(Width*(i+1)*0.1, (float)(Height*(0.4)-Height*0.001*analogVals[i]), 50, (float)(Height*0.001*analogVals[i]));
//    }
//    else{
//      fill(compress);
//      rect(Width*(i+1)*0.1, (float)Height*(0.4), 50, (float)(Height*0.001*abs(analogVals[i])));
//    }
    
//    fill(0, 102, 10);
//    text((int)analogVals[i], Width*(i+1)*0.1, Height*(0.73)); 
//    fill(150, 150, 150);
//    text(analogVals[i], Width*(i+1)*0.1, Height*(0.8)); 
//    fill(255, 0, 0);
//    text("Label:"+NowLabel, Width*0.01, Height*(0.9)); 
//  }

  if(RecordDataFlag){
     TableRow newRow = csvTable.addRow();
     newRow.setString("label", NowLabel);
     for (int i = 0; i < NUM_OF_GAUGE; i++) {
       newRow.setFloat("Finger"+i, (float)elongRatios[i]);
     }
     newRow.setFloat("accx", 0);
     newRow.setFloat("accy", 0);
     newRow.setFloat("accz", 0);
  }

  
}

void keyPressed() { 
  if(keyCode == KeyEvent.VK_D && CanDataFlag == true){ //record data
    RecordDataFlag = !RecordDataFlag;
    
  }
  else if(keyCode == KeyEvent.VK_L && createLabelFlag == false && CanLabelFlag == true ){  // create label name
    createLabelFlag = true;
     CanDataFlag=false;
      println("create a new label, please enter script name:"); 
      enterLabelNameFlag = true;
      NowLabel = new String();
    
    return;
  }
  else if(keyCode == KeyEvent.VK_N && createFileFlag == false) { //create file name
    createFileFlag = true;
     CanDataFlag = false;
      println("create a new script, please enter script name:"); 
      enterFileNameFlag = true;
      filename = new String();
    
    return;
  }
  else if(keyCode == KeyEvent.VK_BACK_SPACE){   // cancel filename, label input
    if(createFileFlag){
      createFileFlag = false;
      println("cancel creating a new label");
    }
    else if(createLabelFlag){
      createLabelFlag = false;
      println("cancel creating a new script");
    }
  }
  else if(keyCode == KeyEvent.VK_F1){
    saveTable(csvTable, "data/"+filename);
    println(filename + " Svaed.");
  }
  // key in
  
  if(enterFileNameFlag){  
    if (key >= 'A' && key <= 'Z' || key >= 'a' && key <= 'z' ) {
      filename = filename + key;     
    } 
    else if(keyCode == KeyEvent.VK_ENTER){
      enterFileNameFlag = false;
      
      createFileFlag = false;
      filename = filename + ".csv";
      CanLabelFlag = true;
      println("Filename:"+filename);
    }
  }
  else if(enterLabelNameFlag){
    if (key >= 'A' && key <= 'Z' || key >= 'a' && key <= 'z' ) {
      NowLabel = NowLabel + key;
      println(NowLabel);
    } 
    else if(keyCode == KeyEvent.VK_ENTER){
      enterLabelNameFlag = false;
      createLabelFlag = false;
      println("Label:" + NowLabel);
      CanDataFlag = true;
    }
  }
}

int [] readSensorRawData(String str) throws Exception{
  String [] rawDataStrArr = str.split(" ");
  int [] rawDataArr = new int[rawDataStrArr.length-2];

  for (int i = 1; i < rawDataStrArr.length-1; ++i)
    rawDataArr[i-1] = Integer.parseInt(rawDataStrArr[i]);

  return rawDataArr;
}

void copyCalibrationData() throws Exception{
  for (int i = 0; i < NUM_OF_GAUGE; ++i) {
    strainCaliVals[i] = analogVals[i];
  }
}

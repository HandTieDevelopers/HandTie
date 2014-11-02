import processing.serial.*;
import java.awt.event.KeyEvent;

//Import the P5 OSC library
import oscP5.*;
import netP5.*;

final static int NUM_OF_GAUGE = 5;
final static int ACCEL_DIM = 3;

//-----------------------------------GRT
//Set the pipeline mode (CLASSIFICATION_MODE or REGRESSION_MODE), the number of inputs and the number of outputs
final int pipelineMode = GRT.CLASSIFICATION_MODE;
final int numInputs = 8;
final int numOutputs = 1;

//Create a new GRT instance, this will initalize everything for us and send the setup message to the GRT GUI
GRT grt = new GRT( pipelineMode, numInputs, numOutputs, "127.0.0.1", 5000, 5001, true );

//Create some global variables to hold our data
float[] data = new float[ numInputs ];
float[] targetVector = new float[ numOutputs ];
PFont font;

//-----------------------------------
color stretch = color(4, 79, 111);
color compress = color(255, 145, 158);
color ColorIdle = color(200, 200, 200);

int Width = 800;
int Height = 600;
float mul = 1;
int[] analogVals = new int[NUM_OF_GAUGE + ACCEL_DIM];
int[] strainCaliVals = new int[NUM_OF_GAUGE];
int[] accelMax = new int[ACCEL_DIM];
int[] accelMin = new int[ACCEL_DIM];
float[] accel = new float[ACCEL_DIM];
double[] elongRatios = new double[NUM_OF_GAUGE];

int[] x = new int[0];
int[] y = new int[0];

final static int SERIAL_PORT_NUM = 5;

final static int SERIAL_PORT_BAUD_RATE = 57600;

int lf = 10;
Serial serial;

void setup() {
  size(Width, Height);
  frameRate(30);
  
  //Load the font
  font = loadFont("SansSerif-48.vlw");
  
  // Setup serial port I/O
  println("AVAILABLE SERIAL PORTS:");
  String[] serialPortNames = Serial.list();
  for(int i = 0;i < serialPortNames.length;i++) {
    println("port num:" + i + ",name:" +serialPortNames);
  }
  String portName = Serial.list()[SERIAL_PORT_NUM];
  println("HAVE A LOOK AT THE LIST ABOVE AND SET THE RIGHT SERIAL PORT NUMBER IN THE CODE!");
  println("  -> Using port " + SERIAL_PORT_NUM + ": " + portName);
  serial = new Serial(this, portName, SERIAL_PORT_BAUD_RATE);
  serial.bufferUntil(lf); //buffering until reading a lf char and call serial event
}

void serialEvent(Serial port) {
  try {
    String buf = port.readString();
    char identifer = buf.charAt(0);
    if(identifer != 'n' || identifer != 'c') { //maybe data is read uncompletely
      return;
    }
    analogVals = readSensorRawData(buf);
    if(identifer == 'c') {
      copyCalibrationData();
    }
  }
  catch (Exception e) {
    e.getMessage();
  }
}

int[] readSensorRawData(String str) throws Exception{
  String[] rawDataStrArr = str.split(" ");
  int numSplitedStrs = rawDataStrArr.length;
  int[] rawDataArr = new int[numSplitedStrs-2]; //dispose '/n' and identifer

  for (int i = 1; i < numSplitedStrs-1; ++i) {
    rawDataArr[i-1] = Integer.parseInt(rawDataStrArr[i]);
  }

  return rawDataArr;
}

void copyCalibrationData() throws Exception{
  for (int i = 0; i < NUM_OF_GAUGE; ++i) {
    strainCaliVals[i] = analogVals[i];
  }
}

void draw() {
  background(ColorIdle);
  line(0, Height*(0.4), Width, Height*(0.4));
  textSize(20);
  
  if( !grt.getInitialized() ){
    background(255,0,0);  
    println("WARNING: GRT Not Initalized. You need to call the setup function!");
    return;
  }
  
  
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
    
    data[i] = (float)elongRatios[i];
  }
  
  //Grab the mouse data and send it to the GRT backend via OSC
  data[NUM_OF_GAUGE] = analogVals[NUM_OF_GAUGE];
  data[NUM_OF_GAUGE+1] = analogVals[NUM_OF_GAUGE+1];
  data[NUM_OF_GAUGE+2] = analogVals[NUM_OF_GAUGE+2];
  
  grt.sendData( data );
  
  for (int i = NUM_OF_GAUGE; i < NUM_OF_GAUGE+ACCEL_DIM; i++) {
    if(analogVals[i]>0){
      fill(stretch);
      rect(Width*(i+1)*0.1, (float)(Height*(0.4)-Height*0.001*analogVals[i]), 50, (float)(Height*0.001*analogVals[i]));
    }
    else{
      fill(compress);
      rect(Width*(i+1)*0.1, (float)Height*(0.4), 50, (float)(Height*0.001*abs(analogVals[i])));
    }
    
//    fill(0, 102, 10);
//    text((int)analogVals[i], Width*(i+1)*0.1, Height*(0.73)); 
//    fill(150, 150, 150);
//    text(analogVals[i], Width*(i+1)*0.1, Height*(0.8)); 
//    fill(255, 0, 0);
//    text("Label:"+NowLabel, Width*0.01, Height*(0.9)); 
  }
    //Draw the info text
  fill(0,0,0);
  grt.drawInfoText((int)(Width*(0.6)),(int)(Height*0.5));
  
}

void keyPressed(){
  
  switch( key ){
    case 'i':
      grt.init( pipelineMode, numInputs, numOutputs, "127.0.0.1", 5000, 5001, true );
      break;
    case '[':
      grt.decrementTrainingClassLabel();
      break;
    case ']':
      grt.incrementTrainingClassLabel();
      break;
    case 'r':
      if( grt.getRecordingStatus() ){
        grt.stopRecording();
      }else grt.startRecording();
      break;
    case 't':
      grt.startTraining();
      break;
    case 's':
      grt.saveTrainingDatasetToFile( "TrainingData.txt" );
      break;
    case 'l':
      grt.loadTrainingDatasetFromFile( "TrainingData.txt" );
      break;
    case 'c':
      grt.clearTrainingDataset();
      break;
    case '{': //Decrease the target vector value by 0.1 (only for REGRESSION_MODE)
      targetVector[0] -= 0.1;
      grt.sendTargetVector( targetVector );
      break;
    case '}': //Increase the target vector value by 0.1 (only for REGRESSION_MODE)
      targetVector[0] += 0.1;
      grt.sendTargetVector( targetVector );
      break;
    case '1': //Set the classifier as ANBC, enable scaling, enable null rejection, and set the null rejection coeff to 5.0
      grt.setClassifier( grt.ANBC, true, true, 5.0 );
      break;
    case '2'://Set the classifier as ADABOOST, enable scaling, disable null rejection, and set the null rejection coeff to 5.0
      grt.setClassifier( grt.ADABOOST, true, false, 5.0 );
      break;
    default:
      break;
  }
  
}


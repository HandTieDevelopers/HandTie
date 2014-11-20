import processing.serial.*;
import java.awt.event.KeyEvent;
import java.io.*;
import java.net.*;

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
color ColorIdle = color(64,64,74);

int Width = 700;
int Height = 800;
float mul = 1;
int[] analogVals = new int[NUM_OF_GAUGE + ACCEL_DIM];
int[] strainCaliVals = new int[NUM_OF_GAUGE];
int[] accelMax = new int[ACCEL_DIM];
int[] accelMin = new int[ACCEL_DIM];
float[] accel = new float[ACCEL_DIM];
double[] elongRatios = new double[NUM_OF_GAUGE];

int lf = 10;

boolean show_grtFlg = true;
final int WaveBufferSize = 128;
float[][] WaveBuffer = new float[NUM_OF_GAUGE + ACCEL_DIM][WaveBufferSize];
int WaveBufferIndex = 0;
int WaveBufferIndexCounter = 0;
int WaveBufferIndexTmp = 0;

final static int BUFF_SIZE = 40;
final static int serverPort = 8080;
final static char[] identifer = new char[]{'c','s','a','\n'};
int[] lookUpTable = new int[256];

//thread specialize for socket I/O
Thread dataReceiver = new Thread(new Runnable() {
  public void run() {

    DatagramSocket serverSocket = null;
    byte[] receiveData = new byte[BUFF_SIZE];
    DatagramPacket receivePacket = new DatagramPacket(receiveData, BUFF_SIZE);           
    
    while(true) { //server init
        try {
            serverSocket = new DatagramSocket(serverPort);
            println("server start to listen on port " + serverPort);
            break;
        }
        catch(Exception e) {
            println(e.getMessage());
        }
    }
    
    while (true) {
      try {
          while(true) {
              serverSocket.receive(receivePacket);              
            String[] parsedData = (new String( receivePacket.getData() )).split(" ");
              int numSegments = parsedData.length;
              numSegments--; //always drop last one. because last segment either is a newline char or an incomplete numeric data 
              for(int i = 0;i < numSegments;) {
                char potentialIdentifer = parsedData[i].charAt(0);
                if(lookUpTable[(int)(potentialIdentifer)] == 1) { //find identifer
                  int j = i + 1;
                  for(;j < numSegments;j++) {
                    potentialIdentifer = parsedData[j].charAt(0);
                    if(lookUpTable[(int)(potentialIdentifer)] == 1) { //find next identifer
                      break;
                    }
                    int kthAnalogVal = j - i - 1;
                    analogVals[kthAnalogVal] = Integer.parseInt(parsedData[j]);
                    if(potentialIdentifer == 'c') {
                      strainCaliVals[kthAnalogVal] = analogVals[kthAnalogVal];
                    }
                  }
                  i = j;
                }
                else {
                  i++;
                }
              }
              
              
          }
        }
        catch(Exception e) {
          println(e.getMessage());
        }
    }
  }
});


void setup() {
  //network communication
  int numIdentifers = identifer.length;
  for(int i = 0;i < numIdentifers;i++) {
    lookUpTable[(int)identifer[i]] = 1;
  }
  dataReceiver.start();

  size(Width, Height);
  frameRate(30);
  
  //Load the font
  font = loadFont("SansSerif-48.vlw");
  show_grtFlg = false; 
}

void draw() {
  background(ColorIdle);
  //line(0, Height*(0.4), Width, Height*(0.4));
  textSize(20);
  
  if( !grt.getInitialized() ){
    background(255,0,0);  
    println("WARNING: GRT Not Initalized. You need to call the setup function!");
    return;
  }
  stroke(255);
  noFill();
  for (int i = 0; i < NUM_OF_GAUGE+ACCEL_DIM; i++) {
      rect(50, 70*(i+2)-30, 4.1*WaveBufferSize, 60, 8 ); 
  }
  for (int i = 0; i < NUM_OF_GAUGE; i++) {
     double strainData = analogVals[i];
     elongRatios[i] = strainData / strainCaliVals[i];
     fill(0, 102, 10);
      text((float)elongRatios[i], 50+WaveBufferSize*4, 70*(i+2)); 
      fill(150, 150, 150);
      text((int)strainData, 120+WaveBufferSize*4, 70*(i+2)); 
      fill(255, 0, 0);
      
      data[i] = (float)elongRatios[i];
      WaveBuffer[i][WaveBufferIndex] = (float)elongRatios[i];
  }
  
  WaveBuffer[NUM_OF_GAUGE][WaveBufferIndex] = analogVals[NUM_OF_GAUGE];
  WaveBuffer[NUM_OF_GAUGE+1][WaveBufferIndex] = analogVals[NUM_OF_GAUGE+1];
  WaveBuffer[NUM_OF_GAUGE+2][WaveBufferIndex] = analogVals[NUM_OF_GAUGE+2];

  
  WaveBufferIndex++;
  if(WaveBufferIndex >= WaveBufferSize-1){
    WaveBufferIndex = 0;
  }
  //Draw_rect----------------------------------------
  //
  // for (int i = 0; i < NUM_OF_GAUGE+ACCEL_DIM; i++) {
  //   if(i < NUM_OF_GAUGE){
  //     if(elongRatios[i]>1){
  //       fill(stretch);
  //       rect(Width*(i+1)*0.1, (float)(Height*(0.4)-Height*mul*(elongRatios[i]-1)), 50, (float)(Height*mul*(elongRatios[i]-1)));
  //     }
  //     else{
  //       fill(compress);
  //       rect(Width*(i+1)*0.1, (float)Height*(0.4), 50, (float)(Height*mul*(1-elongRatios[i])));
  //     }
  //   }
  //   else{
  //       if(analogVals[i]>0){
  //         fill(stretch);
  //         rect(Width*(i+1)*0.1, (float)(Height*(0.4)-Height*0.001*analogVals[i]), 50, (float)(Height*0.001*analogVals[i]));
  //       }
  //       else{
  //         fill(compress);
  //         rect(Width*(i+1)*0.1, (float)Height*(0.4), 50, (float)(Height*0.001*abs(analogVals[i])));
  //       }
  //   }
    
  // }
  //Draw_rect----------------------------------------end
  
  // draw the waveforms
  stroke(133,182,212);
  WaveBufferIndexCounter = 1;
  WaveBufferIndexTmp = WaveBufferIndex;
  while(WaveBufferIndexCounter <= WaveBufferSize){
    if(WaveBufferIndexTmp == WaveBufferSize-2 ){
        for (int i = 0; i < NUM_OF_GAUGE+ACCEL_DIM; i++){
          WaveBuffer[i][WaveBufferSize-1] = WaveBuffer[i][0];
        }
     }
    for (int i = 0; i < NUM_OF_GAUGE+ACCEL_DIM; i++) {
      
      if(i < NUM_OF_GAUGE){
        line(50+WaveBufferIndexCounter*4, 70*(i+2) - WaveBuffer[i][WaveBufferIndexTmp]*30, 50+(WaveBufferIndexCounter+1)*4, 70*(i+2) - WaveBuffer[i][WaveBufferIndexTmp+1]*30);
      }
      else{
        line(50+WaveBufferIndexCounter*4, 70*(i+2) - WaveBuffer[i][WaveBufferIndexTmp]*0.1, 50+(WaveBufferIndexCounter+1)*4, 70*(i+2) - WaveBuffer[i][WaveBufferIndexTmp+1]*0.1);
      
      }
    }
    WaveBufferIndexTmp ++;
    if(WaveBufferIndexTmp >= WaveBufferSize-1){
      WaveBufferIndexTmp=0;
    }
    WaveBufferIndexCounter ++;   
  }
  
  //Grab the mouse data and send it to the GRT backend via OSC
  data[NUM_OF_GAUGE] = analogVals[NUM_OF_GAUGE];
  data[NUM_OF_GAUGE+1] = analogVals[NUM_OF_GAUGE+1];
  data[NUM_OF_GAUGE+2] = analogVals[NUM_OF_GAUGE+2];
  
  grt.sendData( data );
  
  if(show_grtFlg){
    //Draw the info text
  fill(0,0,0);
  grt.drawInfoText((int)(Width*(0.6)),(int)(Height*0.5));
  }
}

void keyPressed(){
  
  switch( key ){
    case 'g':
      show_grtFlg = !show_grtFlg;
      break;
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

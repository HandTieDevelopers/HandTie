import java.awt.event.KeyEvent;

//Import the P5 OSC library
import oscP5.*;
import netP5.*;

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

int NUM_OF_GAUGE;
int ACCEL_DIM;
int[] analogVals;
int[] strainCaliVals;
double[] elongRatios;

boolean show_grtFlg = true;
final int WaveBufferSize = 128;
int WaveBufferIndex = 0;
int WaveBufferIndexCounter = 0;
int WaveBufferIndexTmp = 0;
float[][] WaveBuffer;

void setup() {
  //init udp server
  UdpServerForLinkItApp udpServer = new UdpServerForLinkItApp();
  NUM_OF_GAUGE = UdpServerForLinkItApp.NUM_OF_GAUGE;
  ACCEL_DIM= UdpServerForLinkItApp.ACCEL_DIM;
  
  analogVals = udpServer.analogVals;
  strainCaliVals = udpServer.strainCaliVals;
  elongRatios = udpServer.elongRatios;

  //UI set up
  WaveBuffer = new float[NUM_OF_GAUGE + ACCEL_DIM][WaveBufferSize];
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

import java.io.*;
import java.awt.event.KeyEvent;
import java.util.*;
import java.lang.ProcessBuilder.*;
import processing.net.*;

//Import the P5 OSC library
import oscP5.*;
import netP5.*;

final static int nodeServerPort = 8090;
final static String nodeServerAddress = "127.0.0.1";

//-- GRT --
//Set the pipeline mode (CLASSIFICATION_MODE or REGRESSION_MODE), the number of inputs and the number of outputs
final int pipelineMode = GRT.CLASSIFICATION_MODE;
final int numInputs = 5;
final int numOutputs = 1;

//Create a new GRT instance, this will initalize everything for us and send the setup message to the GRT GUI
GRT grt = new GRT( pipelineMode, numInputs, numOutputs, "127.0.0.1", 5000, 5001, true );

//Create some global variables to hold our data
float[] data = new float[ numInputs ];
PFont font;

color stretch = color(4, 79, 111);
color compress = color(255, 145, 158);
color ColorIdle = color(200, 200, 200);
int Width = 800;
int Height = 800;
float mul = 1;

//-- GRT --

int NUM_OF_GAUGE;
int ACCEL_DIM;
int[] analogVals;
int[] strainCaliVals;
float[] elongRatios;

boolean isReal = false;
int IRMode = 0;



IREventListener listener = new IREventListener() {
	void onEvent(String IRMsg) {
		println("msg:" + IRMsg); //show this info on the Visualization panel
		try {
			if(IRMsg.equals("O")) { //IR mode
				isReal = false;
				return;
			}
			else if(IRMsg.equals("N")) { //ML mode
				isReal = true;
				return;
			}
			else {
				if(!isReal) {
					tcpClient.sendMsg(mode + "," + IRMsg);
				}
			}

			if(IRMsg.equals("U")) {
				predictedResult = "Up";
			}
			else if(IRMsg.equals("D")) {
				predictedResult = "Down";
				if(mode.equals("g") && IRMode == 1) {
					predictedResult = "camera";
				}
			}
			else if(IRMsg.equals("L")) {
				predictedResult = "Left";
			}
			else if(IRMsg.equals("R")) {
				predictedResult = "Right";
			}
			else if(IRMsg.equals("C")) {
				if(IRMode == 1) {
					predictedResult = "Power";
				}
				else {
					predictedResult = "OK";
				}
			}
			else if(IRMsg.equals("M")) {
				IRMode = 0;
				predictedResult = "No Gesture";
			}
			else if(IRMsg.equals("P")) {
				IRMode = 1;
				predictedResult = "No Gesture";
			}
		}
		catch(Exception e) {
			println(e.getMessage());
		}
	}
};

Thread terminateHook = new Thread(new Runnable() {
	public void run() {
		println("start to terminate this process");
		if(irDaemon != null) {
			irDaemon.terminateProcessForExecCmd();
		}
	}
});

Thread mlThread = new Thread(new Runnable() {
	public void run() {
		if( !grt.getInitialized() ){
			background(255,0,0);  
			println("WARNING: GRT Not Initalized. You need to call the setup function!");
			return;
		}

		while(true) {
			for(int i = 0;i < NUM_OF_GAUGE;i++) {
				data[i] = ((float)analogVals[i])/strainCaliVals[i];
			}

			//Grab the mouse data and send it to the GRT backend via OSC
			// data[NUM_OF_GAUGE] = analogVals[NUM_OF_GAUGE];
			// data[NUM_OF_GAUGE+1] = analogVals[NUM_OF_GAUGE+1];
			// data[NUM_OF_GAUGE+2] = analogVals[NUM_OF_GAUGE+2];

			grt.sendData( data );

			if(showGRTFlag) {
				//Draw the info text
				fill(0,0,0);
				grt.drawInfoText((int)(Width*(0.6)),(int)(Height*0.5) + heightOffSet);
			}

			performGestureAction();
		}

	}
});

//-- Philip Hue --
PhilipHue philipHue = new PhilipHue();

//customized class 
UdpServerForLinkItApp udpServer;
IRDaemonWrapper irDaemon;
TcpClientWithMsgQueue tcpClient;

final int WaveBufferSize = 128;
int WaveBufferIndex = 0;
int WaveBufferIndexCounter = 0;
int WaveBufferIndexTmp = 0;
float[][] WaveBuffer;

void setup() {
	//init udp server(Comm with LinkIt)
	udpServer = new UdpServerForLinkItApp();
	NUM_OF_GAUGE = UdpServerForLinkItApp.NUM_OF_GAUGE;
	ACCEL_DIM= UdpServerForLinkItApp.ACCEL_DIM;
	analogVals = udpServer.analogVals;
	strainCaliVals = udpServer.strainCaliVals;
	elongRatios = new float[NUM_OF_GAUGE];

	//init tcp client(Comm with node server on localhost)
	//tcpClient = new TcpClientWithMsgQueue(nodeServerAddress,nodeServerPort);
	tcpClient = null;

	Runtime.getRuntime().addShutdownHook(terminateHook);

	//init ir daemon
	while(true) {
		try {
			irDaemon = new IRDaemonWrapper(listener);
			break;
		}
		catch(Exception e) {
			println(e.getMessage());
		}
	}

	//UI set up(For Second UI)
	WaveBuffer = new float[NUM_OF_GAUGE + ACCEL_DIM][WaveBufferSize];

	//GRT
	size(Width, Height);
	frameRate(30);

	//Load the font
	font = loadFont("SansSerif-48.vlw");

	mlThread.start();
}

final int heightOffSet = 110;
//String msgToShowRealOrNot = "r";
String predictedResult = "";

final int numCurrentExistedUIVersion = 2;
int UINumToShow = 0;

void draw() {

	background(ColorIdle);

	textSize(35);
	text(predictedResult,440,70); //recognition result

	if(isReal) {
		triangle(7, 8, 8, 7, 3, 4);
	}
	else {
		triangle(3, 4, 7, 8, 7, 8);
	}

	if(UINumToShow == 0) {
		line(0, Height*(0.4)+heightOffSet, Width, Height*(0.4)+heightOffSet);
		textSize(20);

		//text(predictedLabelX,20,20);
		//text(predictedLabelY,20,60);

		for (int i = 0; i < NUM_OF_GAUGE; i++) {
			elongRatios[i] = ((float)analogVals[i]) / strainCaliVals[i];

			if(elongRatios[i]>1){
				fill(stretch);
				rect(Width*(i+1)*0.1, (float)(Height*(0.4)-Height*mul*(elongRatios[i]-1)) + heightOffSet, 50, (float)(Height*mul*(elongRatios[i]-1)));
			}
			else{
				fill(compress);
				rect(Width*(i+1)*0.1, (float)Height*(0.4) + heightOffSet, 50, (float)(Height*mul*(1-elongRatios[i])));
			}

			fill(0, 102, 10);
			text((float)elongRatios[i], Width*(i+1)*0.1, Height*(0.73) + heightOffSet); 
			fill(150, 150, 150);
			text((int)analogVals[i], Width*(i+1)*0.1, Height*(0.8) + heightOffSet); 
			fill(255, 0, 0);
		}

		for (int i = NUM_OF_GAUGE; i < NUM_OF_GAUGE + ACCEL_DIM; i++) {
			if(analogVals[i]>0){
				fill(stretch);
				rect(Width*(i+1)*0.1, (float)(Height*(0.4)-Height*0.001*analogVals[i]) + heightOffSet, 50, (float)(Height*0.001*analogVals[i]));
			}
			else{
				fill(compress);
				rect(Width*(i+1)*0.1, (float)Height*(0.4) + heightOffSet, 50, (float)(Height*0.001*abs(analogVals[i])));
			}
		}
	}
	else if(UINumToShow == 1) {
		
		stroke(255);
		noFill();
		for (int i = 0; i < NUM_OF_GAUGE+ACCEL_DIM; i++) {
			rect(50, 70*(i+2)-30, 4.1*WaveBufferSize, 60, 8 ); 
		}
		for (int i = 0; i < NUM_OF_GAUGE; i++) {
			elongRatios[i] = ((float)analogVals[i]) / strainCaliVals[i];
			fill(0, 102, 10);
			text((float)elongRatios[i], 50+WaveBufferSize*4, 70*(i+2)); 
			fill(150, 150, 150);
			text(analogVals[i], 120+WaveBufferSize*4, 70*(i+2)); 
			fill(255, 0, 0);

			WaveBuffer[i][WaveBufferIndex] = elongRatios[i];
		}

		WaveBuffer[NUM_OF_GAUGE][WaveBufferIndex] = analogVals[NUM_OF_GAUGE];
		WaveBuffer[NUM_OF_GAUGE+1][WaveBufferIndex] = analogVals[NUM_OF_GAUGE+1];
		WaveBuffer[NUM_OF_GAUGE+2][WaveBufferIndex] = analogVals[NUM_OF_GAUGE+2];

		WaveBufferIndex++;
		if(WaveBufferIndex >= WaveBufferSize-1){
			WaveBufferIndex = 0;
		}

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

	}
}

String mode = "l";

boolean showGRTFlag = false;

void keyPressed() {
	if(key == 'z') {
		mode = "g";
	}
	else if(key == 'x'){
		mode = "w";
	}
	else if(key == 'c') {
		mode = "k";
	}
	else if(key == 'g') {
		showGRTFlag = !showGRTFlag;
	}
   } else if(key == 'r') {
      showRGB = !showRGB;
   }
	else if(key == 'v') { //for hue
		mode = "l";
	}
	else if(key == 'i') {
		UINumToShow++;
		if(UINumToShow == numCurrentExistedUIVersion) {
			UINumToShow = 0;
		}
	}
	/*	
		else if(key == 'w') {
		if(predictedLabelY > posStep) {
		predictedLabelY -= posStep;	
		}
		}
		else if(key == 's') {
		if(predictedLabelY < Height) {
		predictedLabelY += posStep;
		}
		}
		else if(key == 'a') {
		if(predictedLabelX > posStep) {
		predictedLabelX -= posStep;
		}	
		}
		else if(key == 'd') {
		if(predictedLabelX < Width) {
		predictedLabelX += posStep;
		}	
		}
		else {
		println("unknown hot keys");
		}
	 */

	println("current mode:" + mode);

}

boolean showRGB = true;
int predictedLabelX = 30;
int predictedLabelY = 50;
final int posStep = 5;

void performGestureAction(){

   double likelihood = grt.getMaximumLikelihood();
   Gesture gesture = Gesture.gestureRecognition(grt.getPredictedClassLabel(),likelihood);
   if(mode == "l") {
	   if(gesture == Gesture.RED) {
	     philipHue.accelToHue(PhilipHue.HueColor.RED,analogVals[NUM_OF_GAUGE + 1]);
	   } else if(gesture == Gesture.GREEN){
	     philipHue.accelToHue(PhilipHue.HueColor.GREEN,analogVals[NUM_OF_GAUGE + 1]);
	   } else if(gesture == Gesture.BLUE){
	     philipHue.accelToHue(PhilipHue.HueColor.BLUE,analogVals[NUM_OF_GAUGE + 1]);
	   } else if(gesture == Gesture.ALL){
	     philipHue.accelToHue(PhilipHue.HueColor.ALL, analogVals[NUM_OF_GAUGE + 1]);
	   } else {
	     philipHue.reset();
	   }
	}

   if (showRGB) {
      textSize(30);
      text("Red :       \t" + philipHue.getR(), Width*0.5, Height*0.05);
      text("Green :    \t" + philipHue.getG(), Width*0.5, Height*0.10);
      text("Blue :      \t" + philipHue.getB(), Width*0.5, Height*0.15);
      text("Gesture : \t " + gesture.toString(), Width*0.5, Height*0.20);
      text("Likelihood : \t" + String.format("%02d",(int)(likelihood*100)) + "%", Width*0.5, Height*0.25);
   }
}

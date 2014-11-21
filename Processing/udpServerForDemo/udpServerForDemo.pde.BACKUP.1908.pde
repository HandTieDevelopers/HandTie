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
final int numInputs = 8;
final int numOutputs = 1;

//Create a new GRT instance, this will initalize everything for us and send the setup message to the GRT GUI
GRT grt = new GRT( pipelineMode, numInputs, numOutputs, "127.0.0.1", 5000, 5001, true );

//Create some global variables to hold our data
float[] data = new float[ numInputs ];
float[] targetVector = new float[ numOutputs ];
PFont font;

color stretch = color(4, 79, 111);
color compress = color(255, 145, 158);
color ColorIdle = color(200, 200, 200);
int Width = 800;
int Height = 600;
float mul = 1;

//-- GRT --

int NUM_OF_GAUGE;
int ACCEL_DIM;
int[] analogVals;
int[] strainCaliVals;
double[] elongRatios;
Gesture gesture = Gesture.NO_GESTURE;

IREventListener listener = new IREventListener() {
	void onEvent(String IRMsg) {
		//println("ir msg:" + IRMsg); //show this info on the Visualization panel
		try {
			tcpClient.sendMsg(mode + "," + IRMsg);
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

//customized class 
UdpServerForLinkItApp udpServer;
IRDaemonWrapper irDaemon;
TcpClientWithMsgQueue tcpClient;

void setup() {
    //init udp server(Comm with LinkIt)
    udpServer = new UdpServerForLinkItApp();
    NUM_OF_GAUGE = UdpServerForLinkItApp.NUM_OF_GAUGE;
    ACCEL_DIM= UdpServerForLinkItApp.ACCEL_DIM;
    analogVals = udpServer.analogVals;
    strainCaliVals = udpServer.strainCaliVals;
    elongRatios = udpServer.elongRatios;

    //init tcp client(Comm with node server on localhost)
    tcpClient = new TcpClientWithMsgQueue(nodeServerAddress,nodeServerPort);

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

    //GRT
	size(Width, Height);
  	frameRate(30);
  	//Load the font
	font = loadFont("SansSerif-48.vlw");
}

// grt.getPredictedClassLabel(); //can get predicted result

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

	for (int i = NUM_OF_GAUGE; i < NUM_OF_GAUGE + ACCEL_DIM; i++) {
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

<<<<<<< HEAD
String gestureRecognition(){
	int classLabel = grt.getPredictedClassLabel();
	double likelihood = grt.getMaximumLikelihood();

	Gesture nextGesture = gesture.getGestureByLabel(classLabel);

	if (likelihood < 0.7) {
		gesture = gesture.NO_GESTURE;
		return gesture.toString();
	}

	if (nextGesture.getLastState() != null){
		if (nextGesture.getLastState().equals(gesture)) {
			gesture = nextGesture;
		} else{
			gesture = gesture.NO_GESTURE;
		}
	} else{
		gesture = nextGesture;
	}
	return gesture.toString();
}
=======
String mode = "keynote";

void keyPressed() {
	if(key == 'z') {
		mode = "glass";
	}
	else if(key == 'x'){
		mode = "wear";
	}
	else if(key == 'c') {
		mode = "keynote";
	}
	else {
		println("unknown hot keys");
	}

	println("current mode:" + mode);

}
>>>>>>> 8fecf87a73dccf61593d9a6f465374c3c0c1c7dd

import java.io.*;
import java.net.*;
import java.net.ServerSocket;
import java.net.Socket;
import processing.serial.*;
import java.awt.event.KeyEvent;

//Import the P5 OSC library
import oscP5.*;
import netP5.*;

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

final static int lf = 10; //newline ASCII
final static int NUM_OF_GAUGE = 5;
final static int ACCEL_DIM = 3;
final static int TOTAL_SENSOR_VALUES = NUM_OF_GAUGE + ACCEL_DIM;
int[] analogVals = new int[NUM_OF_GAUGE + ACCEL_DIM];
int[] strainCaliVals = new int[NUM_OF_GAUGE];
double[] elongRatios = new double[NUM_OF_GAUGE];

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

	//GRT
	size(Width, Height);
  	frameRate(30);
  	//Load the font
	font = loadFont("SansSerif-48.vlw");
}

void draw() {
        
	// for(int i = 0;i < NUM_OF_GAUGE + ACCEL_DIM;i++) {
	// 	print(analogVals[i] + " ");  
	// }
	// println("");
    
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

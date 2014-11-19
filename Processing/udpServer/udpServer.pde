import java.io.*;
import java.net.*;
import java.net.ServerSocket;
import java.net.Socket;

final static int BUFF_SIZE = 40;
final static int serverPort = 8080;

final static int lf = 10; //newline ASCII
final static int NUM_OF_GAUGE = 5;
final static int ACCEL_DIM = 3;
final static int TOTAL_SENSOR_VALUES = NUM_OF_GAUGE + ACCEL_DIM;
int[] analogVals = new int[NUM_OF_GAUGE + ACCEL_DIM];
int[] strainCaliVals = new int[NUM_OF_GAUGE];
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
			        		for(int j = i + 1;j < numSegments;j++) {
			        			potentialIdentifer = parsedData[j].charAt(0);
			        			if(lookUpTable[(int)(potentialIdentifer)] == 1) { //find next identifer
			        				i = j;
			        				break;
			        			}
			        			int kthAnalogVal = j - i - 1;
			        			analogVals[kthAnalogVal] = Integer.parseInt(parsedData[j]);
			        			if(potentialIdentifer == 'c') {
			        				strainCaliVals[kthAnalogVal] = analogVals[kthAnalogVal];
			        			}

			        		}
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
	int numIdentifers = identifer.length;
	for(int i = 0;i < numIdentifers;i++) {
		lookUpTable[(int)identifer[i]] = 1;
	}
	dataReceiver.start();
}

void draw() {
        
	for(int i = 0;i < NUM_OF_GAUGE + ACCEL_DIM;i++) {
		print(analogVals[i] + " ");  
	}
	println("");
        
}

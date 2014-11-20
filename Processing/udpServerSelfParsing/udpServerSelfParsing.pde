import java.io.*;
import java.net.*;
import java.net.ServerSocket;
import java.net.Socket;

final static int BUFF_SIZE = 1024;
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
		    		String unparsedData = new String( receivePacket.getData() );
		    		char[] dataInCharArray = unparsedData.toCharArray();
			        int numChars = dataInCharArray.length;
			        
			        //dirty data parsing
		        	for(int charStartIndex = 0;charStartIndex < numChars;) {
		        		boolean findNextIdentifer = false;
		        		if(lookUpTable[(int)dataInCharArray[charStartIndex]] == 1) { //find identifer
		        			char currentIdentifer = dataInCharArray[charStartIndex];
		        			int kthAnalogVals = 0;
		        			if(currentIdentifer == 'a') {
		        				kthAnalogVals = NUM_OF_GAUGE;
		        			}
		        			int numStartIndex = charStartIndex + 1;
		        			while(!findNextIdentifer && numStartIndex < numChars) {
		        				if(dataInCharArray[numStartIndex] == ' ') {
		        					int numEndIndex = numStartIndex + 2;
		        					while(!findNextIdentifer && numEndIndex < numChars) {
		        						if(dataInCharArray[numEndIndex] == ' ') {
		        							analogVals[kthAnalogVals] = Integer.parseInt(unparsedData.substring(numStartIndex + 1,numEndIndex));
		        							//println("" + analogVals[kthAnalogVals]);
		        							if(currentIdentifer == 'c' && kthAnalogVals < NUM_OF_GAUGE) { //calibration
		        								strainCaliVals[kthAnalogVals] = analogVals[kthAnalogVals];
		        							}
		        							kthAnalogVals++;
		        							break;
		        						}
		        						else if(lookUpTable[(int)dataInCharArray[numEndIndex]] == 1) {
											findNextIdentifer = true;
											charStartIndex = numEndIndex;	
				        				}
		        						else {
		        							numEndIndex++;
		        						}
		        					}
		        					numStartIndex = numEndIndex;

		        				}
		        				else if(lookUpTable[(int)dataInCharArray[numStartIndex]] == 1) {
									findNextIdentifer = true;
									charStartIndex = numStartIndex;	
		        				}
		        				else {
		        					numStartIndex++;
		        				}
		        			}

		        			charStartIndex = numStartIndex;

		        		}
		        		else {
		        			charStartIndex++;
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
		//print(analogVals[i] + " ");  
	}
	//println("");
        
}
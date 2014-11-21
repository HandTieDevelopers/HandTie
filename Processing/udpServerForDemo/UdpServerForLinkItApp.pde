import java.net.*;

class UdpServerForLinkItApp {

    private final static int BUFF_SIZE = 40;
	private final static int serverPort = 8080;
	private final char[] identifer = new char[]{'c','s','a','\n'};
	private final int[] lookUpTable = new int[256];
	
    public final static int ACCEL_DIM = 3;
    public final static int NUM_OF_GAUGE = 5;
	public final static int TOTAL_SENSOR_VALUES = NUM_OF_GAUGE + ACCEL_DIM;

	public int[] analogVals = new int[TOTAL_SENSOR_VALUES];
	public int[] strainCaliVals = new int[NUM_OF_GAUGE];
	public double[]	elongRatios = new double[NUM_OF_GAUGE];

	public UdpServerForLinkItApp() {
		//network communication
		int numIdentifers = identifer.length;
		for(int i = 0;i < numIdentifers;i++) {
			lookUpTable[(int)identifer[i]] = 1;
		}
		dataReceiver.start();
	}

	//thread specialize for socket I/O
	private Thread dataReceiver = new Thread(new Runnable() {
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
				        			if(lookUpTable[(int)(parsedData[j].charAt(0))] == 1) { //find next identifer
				        				break;
				        			}
				        			int kthAnalogVal = j - i - 1;
				        			if(potentialIdentifer == 'a') {
				        				kthAnalogVal += NUM_OF_GAUGE;
				        			}
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
	                try {
	                  serverSocket.close();
	                  serverSocket = new DatagramSocket(serverPort);
	                }
	                catch(Exception e2) {
	                  println(e2.getMessage());
	                }
			    }
			}
		}
	});

};

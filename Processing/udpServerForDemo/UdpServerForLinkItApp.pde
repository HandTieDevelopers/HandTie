import java.net.*;

class UdpServerForLinkItApp {

    private final static int BUFF_SIZE = 40;
	private final static int serverPort = 8080;
	private final char[] identifer = new char[]{'c','s','a','\n'};
	private final int[] lookUpTable = new int[256];
	
    public final static int ACCEL_DIM = 3;
    public final static int NUM_OF_IMU_VALS = ACCEL_DIM;
    public final static int NUM_OF_GAUGE = 5;
	public final static int TOTAL_SENSOR_VALUES = NUM_OF_GAUGE + NUM_OF_IMU_VALS;

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
				        String unparsedStr = new String( receivePacket.getData() );           
			    		String[] parsedData = (unparsedStr).split(" ");
				        int numSegments = parsedData.length;
				        char potentialIdentifer = parsedData[0].charAt(0);
				        if((potentialIdentifer == 'c' || potentialIdentifer == 's') && numSegments >= NUM_OF_GAUGE + 2) {
				        	for(int i = 1;i < NUM_OF_GAUGE + 1;i++) {
				        		analogVals[i - 1] = Integer.parseInt(parsedData[i]);
				        		if(potentialIdentifer == 'c') {
				        			strainCaliVals[i - 1] = analogVals[i - 1];
				        		}
				        	}
				        }
				        else if(potentialIdentifer == 'a' && numSegments >= NUM_OF_IMU_VALS + 2) {
				        	for(int i = 1;i < NUM_OF_IMU_VALS + 1;i++) {
				        		analogVals[i - 1 + NUM_OF_GAUGE] = Integer.parseInt(parsedData[i]);
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

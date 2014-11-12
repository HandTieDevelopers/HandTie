import java.io.IOException;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Date;

final static int lf = 10; //newline ASCII
final static int NUM_OF_GAUGE = 5;
final static int ACCEL_DIM = 3;
final static int TOTAL_SENSOR_VALUES = NUM_OF_GAUGE + ACCEL_DIM;
int[] analogVals = new int[NUM_OF_GAUGE + ACCEL_DIM];
//int[] analogTempVals = new int[NUM_OF_GAUGE + ACCEL_DIM];
int[] strainCaliVals = new int[NUM_OF_GAUGE];

ServerSocket server;
final static int portToListen = 8080;
final static int bufferSize = 4096;

void readSensorRawData(String str) throws Exception{
  String[] rawDataStrArr = str.split(" ");
  int numSplitedStrs = rawDataStrArr.length; //9, due to readLine would get rid of '/n'
  if(numSplitedStrs == TOTAL_SENSOR_VALUES + 1) {
    for (int i = 1; i < numSplitedStrs; ++i) {
      analogVals[i-1] = Integer.parseInt(rawDataStrArr[i]);
    }
  }
  return;
}

void copyCalibrationData() throws Exception{
  for (int i = 0; i < NUM_OF_GAUGE; ++i) {
    strainCaliVals[i] = analogVals[i];
  }
}

//thread specialize for socket I/O
Thread dataReceiver = new Thread(new Runnable() {
	public void run() {
		while(true) { //server init
		    try {
		      	server = new ServerSocket(portToListen);
		      	println("server start to listen on port " + portToListen);
		        break;
		    }
		    catch(Exception e) {
		      	println(e.getMessage());
		    }
		}

		BufferedReader reader = null;
		Socket socket = null;
		
		while (true) {
			try {
				socket = server.accept();
				reader = new BufferedReader(new InputStreamReader(socket.getInputStream()), 
		                                    bufferSize);
			    while(true) {
			        String line = reader.readLine();
			        char identifer = line.charAt(0);
			        if(identifer != 'n' && identifer != 'c') {
			        	continue;
			        }
			        readSensorRawData(line);
			        if(identifer == 'c') {
			        	copyCalibrationData();
			        }
			    }
		    }
		    catch(Exception e) {
		    	println(e.getMessage());
		    } 
		    finally {
		        try {
		        	if(socket != null) {
		        		socket.close();
		        		socket = null;
		        	}
		    	}
		    	catch(Exception e) {
		    		println(e.getMessage());
		    	}
		    }
		}
	}
});

void setup() {
	dataReceiver.start();
}


void draw() {
        
	for(int i = 0;i < NUM_OF_GAUGE + ACCEL_DIM;i++) {
		print(analogVals[i] + " ");  
	}
	println("");
        
}

import java.net.*;
import java.util.*;
import java.io.*;

class TcpClientWithMsgQueue {
  private String mServerIP = null;
  private int mServerPort = 0;
  private LinkedList<String> mMsgQueue = null;
  
  private Thread workerThread;

  public void sendMsg(String msgToTransfer) throws Exception{ 
  	mMsgQueue.add(msgToTransfer);
  	workerThread.interrupt();
  }

  public TcpClientWithMsgQueue(String serverIP,int serverPort) {
    mServerIP = serverIP;
    mServerPort = serverPort;
    mMsgQueue = new LinkedList<String>();
    
    workerThread = new Thread(new Runnable() {
    	private Socket client = null;
    	private OutputStreamWriter dataTransmitter = null;

    	private void connectToTcpServer() {
    		while(true) {
			    try {
			        client = new Socket(mServerIP, mServerPort);
			        dataTransmitter = new OutputStreamWriter(client.getOutputStream());
                    return;
			    }
			    catch(Exception e) {
			        println(e.getMessage());
			    }
			}
			
    	}

    	public void run() {
    		connectToTcpServer();

			while(true) { //enter an event loop
				try {
					if(mMsgQueue.size() != 0) { //not empty
						if(!client.isConnected()) {
							connectToTcpServer();
						}
						String msg = mMsgQueue.remove();
						dataTransmitter.write(msg,0,msg.length());
                                                dataTransmitter.flush();
					}
					else {
						Thread.sleep(10000); //sleep 10 secs
					}
				}
				catch(InterruptedException ie) {
					//do nothing
				}
				catch(Exception e) {
					//println(e.getMessage());
					try {
						client.close();
					}
					catch(Exception e2) {
					}
					connectToTcpServer();
				}
			}
    	}
    });

    workerThread.start();
  }

};

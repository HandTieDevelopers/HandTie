import java.util.*;
import java.io.*;
import java.lang.ProcessBuilder.*;
import java.lang.*;

interface IREventListener {
  void onEvent(String IRMsg);
};

class IRDaemonWrapper {
  private Process pForShellCmd = null;
  private String currentSketchPath = null;
  private final static String irDaemonName = "irRemoteExculsiveAutoMPHold"; 
  private final static String relativePath = "../../C/binary/";
  private IREventListener mListener = null;
  private Thread dataReceiver = null;
  private boolean terminateFlag = false;
  public void terminateProcessForExecCmd() {
    terminateFlag = true;
    try {
      if(dataReceiver != null) {
        dataReceiver.interrupt();
      }
      if(pForShellCmd != null) {
        pForShellCmd.destroy();
      }
    }
    catch(Exception e) {
      println(e.getMessage());
    }
  }

  public IRDaemonWrapper(IREventListener listener) throws Exception {
    mListener = listener;
    currentSketchPath = sketchPath("");
    ProcessBuilder pb = new ProcessBuilder(currentSketchPath + relativePath + irDaemonName);
    pForShellCmd = pb.start();
    dataReceiver = new Thread(new Runnable() {
      
      private BufferedReader errBuffReader = null;
      
      private void initReader() {
        while(!terminateFlag) {
          try {
            errBuffReader = new BufferedReader(new InputStreamReader(pForShellCmd.getErrorStream()));
            break;
          }
          catch(Exception e) {
            println(e.getMessage());
          }
        }
      }
      
      public void run() {
        initReader();
        while(!terminateFlag) {
          try {
            String msg = errBuffReader.readLine();
            if(msg == null) {
              initReader();
            }
            else {
              mListener.onEvent(msg);
            }
          }
          catch(Exception e) {
            println(e.getMessage());
          }
        } 
      }
    });
    
    dataReceiver.start(); 
  }

};

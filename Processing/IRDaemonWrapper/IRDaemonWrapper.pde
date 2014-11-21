import java.util.*;
import java.io.*;
import java.lang.ProcessBuilder.*;

interface IREventListener {
  void onEvent(String IRMsg);
};

class IRDaemonWrapper {
  private Process pForShellCmd = null;
  private String currentSketchPath = null;
  private final static String irDaemonName = "irRemoteExculsiveAuto"; 
  private final static String relativePath = "../../C/binary/";
  private IREventListener mListener = null;
  private Thread dataReceiver = null;

  public IRDaemonWrapper(IREventListener listener) throws Exception {
    mListener = listener;
    currentSketchPath = sketchPath("");
    ProcessBuilder pb = new ProcessBuilder(currentSketchPath + relativePath + irDaemonName,"-r");
    pForShellCmd = pb.start();
    dataReceiver = new Thread(new Runnable() {
      private BufferedReader errBuffReader = null;
      
      public void run() {
        errBuffReader = new BufferedReader(new InputStreamReader(pForShellCmd.getErrorStream()));
        while(true) {
          try {
            String msg = errBuffReader.readLine();
            mListener.onEvent(msg);
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

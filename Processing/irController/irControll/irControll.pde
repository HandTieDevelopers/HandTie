import java.util.*;
import java.io.*;
import java.lang.ProcessBuilder.*;
import processing.net.*;
Client client;
String data;

final static int serverPort = 8080;
final static String serverAddress = "127.0.0.1";

Process pForShellCmd;
BufferedReader errBuffReader = null;
//BufferedReader outBuffReader = null;

String currentSketchPath;
final static String irDaemonName = "irRemote"; 

void sendMsg(String targetDevice, String msg) throws Exception{
  while(true) {
      try {
        client.write(targetDevice + ',' + msg);
        break;
      }
      catch(Exception e) {
        client = new Client(this, serverAddress, serverPort);
      }
  }
}

void setup() {
	try {       
        //println("sketch path:" + sketchPath(""));     
        currentSketchPath = sketchPath("");
        ProcessBuilder pb = new ProcessBuilder(currentSketchPath + irDaemonName,"-r");
        //pb.directory(new File(currentSketchPath));
        //pb.redirectErrorStream(true);
        pForShellCmd = pb.start();
        /*
        Runtime rt = Runtime.getRuntime ();
        pForShellCmd = rt.exec ("pwd");
        */
        
        String line = null;
        String targetDevice = "glass";
        try {
            client = new Client(this, serverAddress, serverPort);
        }
        catch(Exception e) {
            println(e.getMessage());
        }

        errBuffReader = new BufferedReader(new InputStreamReader(pForShellCmd.getErrorStream()));
        //println ("<error>");
        while ( (line = errBuffReader.readLine ()) != null) {
            try {
                sendMsg(targetDevice, line);
            }
            catch(Exception e) {
                println(e.getMessage());
            }
        }
        errBuffReader.close();
        client.stop();

        //println ("</error>");
        
        /*
        outBuffReader = new BufferedReader(new InputStreamReader(pForShellCmd.getInputStream()));
        println ("<output>");
        while ( (line = outBuffReader.readLine ()) != null) {
            println(line);
        }
        outBuffReader.close();
        println ("</output>");
        */
        int exitVal = pForShellCmd.waitFor (); //wait for process to terminate
        println ("Process exitValue: " + exitVal);
    } catch (Exception e) {
        println(e.getMessage());
    }
}

void draw() {

}

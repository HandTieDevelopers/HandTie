import java.util.*;
import java.io.*;
import java.lang.ProcessBuilder.*;

Process pForShellCmd;
BufferedReader errBuffReader = null;
BufferedReader outBuffReader = null;

String currentSketchPath;
final static String irDaemonName = "irRemote"; 

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
        
        errBuffReader = new BufferedReader(new InputStreamReader(pForShellCmd.getErrorStream()));
        //println ("<error>");
        while ( (line = errBuffReader.readLine ()) != null) {
            println(line);
        }
        errBuffReader.close();
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

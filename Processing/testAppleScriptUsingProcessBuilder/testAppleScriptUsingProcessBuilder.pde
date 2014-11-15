import java.io.IOException;
String []KeynoteCmds = new String[]{
  "startSlideShow.scpt",
  "stopSlideShow.scpt",
  "nextSlide.scpt",
  "previousSlide.scpt"

};
void setup() {
  
  ProcessBuilder pb = new ProcessBuilder("");
  pb.directory(new File(sketchPath("../appleScript")));
  //pb.inheritIO();
  
  //String[] controlWithCmd = { "osascript", "-e", "tell application \"Keynote\" to start the front document" };
  String[] controlWithFile = { "osascript", KeynoteCmds[0] };
  try
  {
    pb.command(controlWithFile);
    Process pForExecCmd = pb.start();
    //pForExecCmd.waitFor();
  }
  catch (IOException e)
  {
    println(e.getMessage());
  }
  
}

void draw() {

}

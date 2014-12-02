import java.awt.Color;


public class PhilipHue{
   public enum HueColor{RED, GREEN, BLUE, ALL};
   
   // private int lightNum;

   private float HUE;
   private float SAT;
   private float BRI;

   private int r = 255;
   private int g = 255;
   private int b = 255;

   private int firstY = 0;

   public PhilipHue(){
      convertToHue();
      sendToHue();
   }

   // public PhilipHue(int lightNum){
   //    this.lightNum = lightNum;
   //    convertToHue();
   //    sendToHue();
   // }

   public void accelToHue(HueColor colorToChange, int y){
      if (firstY == 0){
         firstY = y;
         if (colorToChange == HueColor.RED)
            r = 120;
         else if (colorToChange == HueColor.GREEN)
            g = 120;
         else if (colorToChange == HueColor.BLUE)
            b = 120;
      }
      else {
        convertAccelToRGB(colorToChange, y);
        convertToHue();
        sendToHue();
      }
   }

   private void convertAccelToRGB(HueColor colorToChange, int y){
      int relativeY = y - firstY;

      if (colorToChange == HueColor.RED) {
         r = Math.min(r+relativeY/30,255);
         r = Math.max(r,0);
      } else if(colorToChange == HueColor.GREEN) {
         g = Math.min(g+relativeY/30,255);
         g = Math.max(g,0);
      } else if(colorToChange == HueColor.BLUE) {
         b = Math.min(b+relativeY/30,255);
         b = Math.max(b,0);
      } else if(colorToChange == HueColor.ALL) {
         convertAccelToRGB(HueColor.RED, y);
         convertAccelToRGB(HueColor.GREEN, y);
         convertAccelToRGB(HueColor.BLUE, y);
      }
   }

   private void convertToHue(){
      float[] hsv = new float[3];
      Color.RGBtoHSB(Math.round(r),Math.round(g),Math.round(b),hsv);
      //You can multiply SAT or BRI by a digit to make it less saturated or bright
      HUE= hsv[0] * 65535;
      SAT= hsv[1] * 255;
      BRI= hsv[2] * 255;
   }

   private void sendToHue(){
      try{
        // create a new array of 4 strings
         String[] cmdArray = new String[4];

         // first argument is the program we want to open, in this case I put it within the App I created later
         cmdArray[0] = "/Users/TimothyWang/Tim File Sync/work/HandTie/HandTieCode/Processing/udpServerForDemo/AmbiHue.sh";
         // cmdArray[0] = "./AmbiHue.sh";

         // the following arguments are HSV values
         cmdArray[1] = String.valueOf(Math.round(HUE));
         cmdArray[2] = String.valueOf(Math.round(SAT));    
         cmdArray[3] = String.valueOf(Math.round(BRI));

         // print a message, this is just for testing purpose
         System.out.println(r);
         System.out.println(g);
         System.out.println(b);

         Runtime.getRuntime().exec(cmdArray);
      }catch(Exception e){
         System.out.println(e.getMessage());
      }
      finally{}
   }

   public void reset(){
      firstY = 0;
   }
   
   public int getR(){
     return r;
   }
   public int getG(){
     return g;
   }
   public int getB(){
     return b;
   }
//   public static void main(String args[]){
//     PhilipHue philipHue = new PhilipHue();
//   }
   
   

}

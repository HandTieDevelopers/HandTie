public class InteractionMgr {
   HandTieArduinoSystemOnProcessing mainClass;

   public InteractionMgr (HandTieArduinoSystemOnProcessing mainClass) {
      this.mainClass = mainClass;
   }

   public void performKeyPress(char k){
      switch (k) {
         case 'c' :
            gaugeCalibration();
            break;
      }
   }

   public void gaugeCalibration(){
      mainClass.sgManager.requestForCaliVals = true;
      mainClass.serialManager.sendToArduino("0");
   }

   // public void performMousePress(){

   // }

}
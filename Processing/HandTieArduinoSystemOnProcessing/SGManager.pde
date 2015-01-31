public class SGManager{
   
   public final static int NUM_OF_GAUGE = 16;
   public boolean requestForCaliVals = false;

   private StrainGauge [] gauges = new StrainGauge[NUM_OF_GAUGE];

   public SGManager(){
      for (int i = 0; i < gauges.length; ++i) {
         gauges[i] = new StrainGauge();
      }
   }

   public void setValuesForGauges(int [] newValues){
      if (requestForCaliVals) {
         setCalibrationValuesForGauges(newValues);
         requestForCaliVals = false;
      } else {
         setNewValuesForGauges(newValues);
      }
   }

   public void setNewValuesForGauges(int [] newValues){
      for (int i = 0; i < gauges.length; ++i) {
         gauges[i].setNewValue(newValues[i]);
      }
   }

   public void setCalibrationValuesForGauges(int [] newValues){
      for (int i = 0; i < gauges.length; ++i) {
         gauges[i].setCalibrationValue(newValues[i]);
      }
   }

   public void draw(){
      color stretch = color(4, 79, 111);
      color compress = color(255, 145, 158);
      int heightOffSet = 110;
      float mul = 1;

      for (int i = 0; i < gauges.length; i++) {
         float elongRatio = gauges[i].getElongationValue();

         if(elongRatio>1){
            fill(stretch);
            rect(width*(i+1)*0.1,
                 (float)(height*(0.4)-height*mul*(elongRatio-1)) + heightOffSet,
                 50,
                 (float)(height*mul*(elongRatio-1)));
         }else{
            fill(compress);
            rect(width*(i+1)*0.1,
                 (float)height*(0.4) + heightOffSet,
                 50,
                 (float)(height*mul*(1-elongRatio)));
         }

         fill(0, 102, 10);
         text((float)elongRatio, width*(i+1)*0.1, height*(0.73) + heightOffSet); 
         fill(150, 150, 150);
         text((int)gauges[i].getNewValue(), width*(i+1)*0.1, height*(0.8) + heightOffSet); 
         fill(255, 0, 0);
      }
   }
}
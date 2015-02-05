public class SGManager{
   
   public final static int NUM_OF_GAUGE = 16;
   public boolean requestForCaliVals = true;

   private StrainGauge [] gauges = new StrainGauge[NUM_OF_GAUGE];

   public SGManager(){
      for (int i = 0; i < gauges.length; ++i) {
         gauges[i] = new StrainGauge();
      }
   }

   public void setValuesForGauges(int [] newValues){
      if (requestForCaliVals) {
         setCaliValsForGauges(newValues);
         requestForCaliVals = false;
      } else {
         setNewAnalogValsForGauges(newValues);
      }
   }

   public void setNewAnalogValsForGauges(int [] newValues){
      for (int i = 0; i < gauges.length; ++i) {
         gauges[i].setNewValue(newValues[i]);
      }
   }

   public void setCaliValsForGauges(int [] newValues){
      for (int i = 0; i < gauges.length; ++i) {
         gauges[i].setCalibrationValue(newValues[i]);
      }
   }

   public int [] getAnalogValsOfGauges(){
      int [] analogVals = new int[gauges.length];
      for (int i = 0; i < gauges.length; ++i) {
         analogVals[i] = gauges[i].getNewValue();
      }
      return analogVals;
   }
   public float [] getElongationValsOfGauges(){
      float [] elongationVals = new float[gauges.length];
      for (int i = 0; i < gauges.length; ++i) {
         elongationVals[i] = gauges[i].getElongationValue();
      }
      return elongationVals;
   }
   public float getOneElongationValsOfGauges(int index){
      return gauges[index].getElongationValue();
   }
   public void draw(){
      color stretch = color(4, 79, 111);
      color compress = color(255, 145, 158);
      int heightOffSet = 180;
      float mul = 0.6;

      for (int i = 0; i < gauges.length; i++) {
         float elongRatio = gauges[i].getElongationValue();

         if(elongRatio>1){
            fill(stretch);
            rect(width*(i+1)*0.04,
                 (float)(height*(0.42)-height*mul*(elongRatio-1)) + heightOffSet,
                 20,
                 (float)(height*mul*(elongRatio-1)));
         }else{
            fill(compress);
            rect(width*(i+1)*0.04,
                 (float)height*(0.42) + heightOffSet,
                 20,
                 (float)(height*mul*(1-elongRatio)));
         }
         textSize(14);
         fill(0, 102, 10);
         text(String.format("%.2f",elongRatio), width*(i+1)*0.04, height*((i%2==1)?0.6:0.58)+ heightOffSet); 
         fill(150, 150, 150);
         text((int)gauges[i].getNewValue(), width*(i+1)*0.04, height*((i%2==1)?0.65:0.63) + heightOffSet); 
         fill(255, 0, 0);
      }
   }
}

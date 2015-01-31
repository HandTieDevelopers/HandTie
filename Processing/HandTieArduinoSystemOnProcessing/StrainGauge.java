public class StrainGauge{
   
   private int calibrationValue;
   private int newValue;

   public int getNewValue(){
      return newValue;
   }
   public void setNewValue(int newValue){
      this.newValue = newValue;
   }

   public void setCalibrationValue(int calibrationValue){
      this.calibrationValue = calibrationValue;
   }

   public float getElongationValue(){
      return (float)newValue/calibrationValue;
   }
}
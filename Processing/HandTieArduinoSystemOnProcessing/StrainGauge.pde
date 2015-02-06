public class StrainGauge{
   
   //Value data member
   private int calibrationValue;
   private int newValue;

   //Bar Display data member
   private float barXOrigin;
   private float barYOrigin;
   private float barWidth;
   // private float barHeight;
   private float barElongRatio = 1;

   //Text Display data member
   private float elongTextXOrigin;
   private float elongTextYOrigin;
   private float elongTextSize;
   private float analogValTextXOrigin;
   private float analogValTextYOrigin;
   private float analogValTextSize;

   //Value methods
   public int getNewValue(){
      return newValue;
   }
   public void setNewValue(int newValue){
      this.newValue = newValue;
   }

   public void setCalibrationValue(int calibrationValue){
      this.calibrationValue = calibrationValue;
   }

   public int getCalibrationValue(){
      return calibrationValue;
   }

   public float getElongationValue(){
      return (float)newValue/calibrationValue;
   }

   //Bar Display data member
   public void setBarDisplayProperties(float barXOrigin, float barYOrigin,
                                       float barWidth){
      this.barXOrigin = barXOrigin;
      this.barYOrigin = barYOrigin;
      this.barWidth = barWidth;
   }

   public float [] getBarBaseCenter(){
      float [] barOrigin = new float[2];
      barOrigin[0] = barXOrigin + barWidth/2;
      barOrigin[1] = barYOrigin;
      return barOrigin;
   }

   public void drawBar(){
      float elongRatio = getElongationValue();

      color stretch = color(4, 79, 111);
      color compress = color(255, 145, 158);

      fill((elongRatio > 1) ? stretch : compress);
      rect(barXOrigin, barYOrigin, barWidth, (1-elongRatio)*barElongRatio);
   }

   //Text Display
   public void setTextDisplayPropertiesForElong(float elongTextXOrigin,
                                                float elongTextYOrigin,
                                                float elongTextSize){
      this.elongTextXOrigin = elongTextXOrigin;
      this.elongTextYOrigin = elongTextYOrigin;
      this.elongTextSize = elongTextSize;
   }

   public void setTextDisplayPropertiesForAnalogVal(float analogValTextXOrigin,
                                                    float analogValTextYOrigin,
                                                    float analogValTextSize){
      this.analogValTextXOrigin = analogValTextXOrigin;
      this.analogValTextYOrigin = analogValTextYOrigin;
      this.analogValTextSize = analogValTextSize;
   }

   public void drawText(){
      fill(0, 102, 10);
      textSize(elongTextSize);
      text(String.format("%.2f",getElongationValue()), elongTextYOrigin,
           elongTextYOrigin);

      fill(150,150,150);
      textSize(analogValTextSize);
      text((int)newValue, analogValTextXOrigin, analogValTextYOrigin);
   }
}
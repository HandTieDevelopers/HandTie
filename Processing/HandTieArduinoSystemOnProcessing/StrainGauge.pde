public class StrainGauge{
   
   //Value data member
   private int gaugeIdx;
   private int calibrationValue;
   private int newValue;
   private int calibratingValue;

   //Bar Display data member
   private float barXOrigin;
   private float barYOrigin;
   private float barWidth;
   // private float barHeight;

   private float barElongRatio = 200;

   //Text Display data member
   private float elongTextXOrigin;
   private float elongTextYOrigin;
   private float elongTextSize;
   private float analogValTextXOrigin;
   private float analogValTextYOrigin;
   private float analogValTextSize;
   private float gaugeIdxTextXOrigin;
   private float gaugeIdxTextYOrigin;
   private float gaugeIdxTextSize;

   public StrainGauge(int gaugeIdx){
      this.gaugeIdx = gaugeIdx;
   }

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

   public void setCalibratingValue(int calibratingValue){
      this.calibratingValue = calibratingValue;
   }

   public int getCalibratingValue(){
      return calibratingValue;
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

   public void setTextDisplayPropertiesForGaugeIdx(float gaugeIdxTextXOrigin,
                                                   float gaugeIdxTextYOrigin,
                                                   float gaugeIdxTextSize){
      this.gaugeIdxTextXOrigin = gaugeIdxTextXOrigin;
      this.gaugeIdxTextYOrigin = gaugeIdxTextYOrigin;
      this.gaugeIdxTextSize = gaugeIdxTextSize;
   }

   public void drawText(){
      fill(0, 102, 255);
      textSize(gaugeIdxTextSize);
      text("SG"+(int)gaugeIdx, gaugeIdxTextXOrigin, gaugeIdxTextYOrigin);

      fill(0, 102, 10);
      textSize(elongTextSize);
      text(String.format("%.2f",getElongationValue()), elongTextXOrigin,
           elongTextYOrigin);

      fill(150,150,150);
      textSize(analogValTextSize);
      text((int)newValue, analogValTextXOrigin, analogValTextYOrigin);
   }

   public void drawCalibratingText(){
      fill(0,0,30,255);
      textSize(10);
      text(calibratingValue, barXOrigin, barYOrigin+20);
   }
}

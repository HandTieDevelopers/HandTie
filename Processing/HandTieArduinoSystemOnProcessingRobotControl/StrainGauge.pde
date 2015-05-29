public class StrainGauge{
   
   //Value data member
   private int gaugeIdx;
   private float calibrationValue;
   private float newValue;
   private float calibratingValue;
   public boolean enable = true;

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
   public float getNewValue(){
      return enable ? newValue : 0.0f;
   }
   public void setNewValue(float newValue){
      this.newValue = newValue;
   }

   public void setCalibrationValue(float calibrationValue){
      this.calibrationValue = calibrationValue;
   }

   public float getCalibrationValue(){
      return calibrationValue;
   }

   public float getElongationValue(){
      return enable ? (float)newValue/calibrationValue : 0.0f;
   }

   public void setCalibratingValue(float calibratingValue){
      this.calibratingValue = calibratingValue;
   }

   public float getCalibratingValue(){
      return calibratingValue;
   }

   //Bar Display methods
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

   public color getHeatmapRGB(float value){
     float minimum=0.6;
     float maximum=1.4;
     float ratio = 2 * (value-minimum) / (maximum - minimum);
     
     color heatmapRGB = color((int)max(0, 255*(ratio - 1)),
                              255-(int)max(0, 255*(1 - ratio))-(int)max(0, 255*(ratio - 1)),
                              (int)max(0, 255*(1 - ratio)) );
     
     return heatmapRGB;
   }

   public void drawBar(){
      if (!enable) return;
      float elongRatio = getElongationValue();

      // color stretch = color(4, 79, 111);
      // color compress = color(255, 145, 158);

      fill(getHeatmapRGB(getElongationValue()));
      rect(barXOrigin, barYOrigin, barWidth, (1-elongRatio)*barElongRatio);
   }

   //Text Display methods
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
      textSize(enable ? elongTextSize : 7);
      text(enable ? String.format("%.2f",getElongationValue()) : "Disabled",
           elongTextXOrigin,
           elongTextYOrigin);

      fill(150,150,150);
      textSize(analogValTextSize);
      text((int)newValue, analogValTextXOrigin, analogValTextYOrigin);
   }

   public void drawCalibratingText(){
      fill(0,0,30,255);
      textSize(10);
      text((int)calibratingValue, barXOrigin, barYOrigin+20);
   }
}

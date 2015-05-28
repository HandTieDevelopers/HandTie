public class AccelAxis{
   // Value data member
   private float calibrationValue;
   private float newValue;

   // Bar Display data member
   private final static float barChangeRatio = 1.0f;
   private float barXOrigin;
   private float barYOrigin;
   private float barWidth;

   // Text Display data member;
   private String axisName;
   private float axisNameTextXOrigin;
   private float axisNameTextYOrigin;
   private float axisNameTextSize;
   private float differenceValTextXOrigin;
   private float differenceValTextYOrigin;
   private float differenceValTextSize;
   private float newValTextXOrigin;
   private float newValTextYOrigin;
   private float newValTextSize;

   public AccelAxis(String axisName){
      this.axisName = axisName;
   }

   //Value methods
   public float getNewValue(){
      return newValue;
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

   public float getDifferenceVal(){
      return newValue - calibrationValue;
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
      float difference = getDifferenceVal();

      // color stretch = color(4, 79, 111);
      // color compress = color(255, 145, 158);

      fill(getHeatmapRGB(difference));
      rect(barXOrigin, barYOrigin, barWidth, difference*barChangeRatio);
   }

   //Text Display methods
   public void setTextDisplayPropertiesForAxisName(float axisNameTextXOrigin,
                                                   float axisNameTextYOrigin,
                                                   float axisNameTextSize){
      this.axisNameTextXOrigin = axisNameTextXOrigin;
      this.axisNameTextYOrigin = axisNameTextYOrigin;
      this.axisNameTextSize = axisNameTextSize;
   }

   public void setTextDisplayPropertiesForDifferenceVal(float differenceValTextXOrigin,
                                                        float differenceValTextYOrigin,
                                                        float differenceValTextSize){
      this.differenceValTextXOrigin = differenceValTextXOrigin;
      this.differenceValTextYOrigin = differenceValTextYOrigin;
      this.differenceValTextSize = differenceValTextSize;
   }

   public void setTextDisplayPropertiesForNewVal(float newValTextXOrigin,
                                                 float newValTextYOrigin,
                                                 float newValTextSize){
      this.newValTextXOrigin = newValTextXOrigin;
      this.newValTextYOrigin = newValTextYOrigin;
      this.newValTextSize = newValTextSize;
   }

   public void drawText(){
      fill(0, 102, 255);
      textSize(axisNameTextSize);
      text(axisName, axisNameTextXOrigin, axisNameTextYOrigin);

      fill(0, 102, 10);
      textSize(differenceValTextSize);
      text(String.format("%.2f",getDifferenceVal()), differenceValTextXOrigin,
           differenceValTextYOrigin);

      fill(150,150,150);
      textSize(newValTextSize);
      text(String.format("%.2f",newValue), newValTextXOrigin, newValTextYOrigin);
   }
}

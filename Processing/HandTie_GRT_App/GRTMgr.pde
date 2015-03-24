
public class GRTMgr implements SerialListener{
  
   HandTie_GRT_App mainClass;
   

   //-----------------------------------GRT
    //Set the pipeline mode (CLASSIFICATION_MODE or REGRESSION_MODE), the number of inputs and the number of outputs
    final int pipelineMode = GRT.CLASSIFICATION_MODE;
    final int numInputs = 19;
    final int numOutputs = 1;
    
   GRT grt = new GRT( pipelineMode, numInputs, numOutputs, "127.0.0.1", 5000, 5001, true );
   float[] data = new float[ numInputs ];
   float[] targetVector = new float[ numOutputs ];
   
   boolean showGETmsgFlg = true;
   
   public GRTMgr (HandTie_GRT_App mainClass) {
      this.mainClass = mainClass;
      
      
   }
   public void draw(){
//      fill(color(200));
//        rect(100, 100, width*0.4, height*0.4);
        fill(color(10));
        if( !grt.getInitialized() ){
          background(255,0,0);  
          println("WARNING: GRT Not Initalized. You need to call the setup function!");
          return;
        }
        if(showGETmsgFlg){
          //Draw the info text
          grt.drawInfoText(floor(width*0.72),20);
        }
        //Grab the mouse data and send it to the GRT backend via OSC
        for(int sgi=1; sgi<numInputs; sgi++){
          data[sgi-1] = mainClass.sgManager.getOneElongationValsOfGauges(sgi);
        }
        grt.sendData( data );
//        fill(color(200));
        textSize(50);
        text(grt.getPredictedClassLabel(),width*0.4,height*0.2);
   }
   public color getHeatmapRGB(float value){
     float minimum=0.6;
     float maximum=1.4;
     float ratio = 2 * (value-minimum) / (maximum - minimum);
     
     color heatmapRGB = color((int)max(0, 255*(ratio - 1)),255-(int)max(0, 255*(1 - ratio))-(int)max(0, 255*(ratio - 1)), (int)max(0, 255*(1 - ratio)) );
     
     return heatmapRGB;
   }
   public void performKeyPress(char k){
      
      switch (k) {
        case 'm':
            showGETmsgFlg=!showGETmsgFlg;
          break;
        case 'i':
          grt.init( pipelineMode, numInputs, numOutputs, "127.0.0.1", 5000, 5001, true );
          break;
        case '[':
          grt.decrementTrainingClassLabel();
          break;
        case ']':
          grt.incrementTrainingClassLabel();
          break;
        case 'r':
          if( grt.getRecordingStatus() ){
            grt.stopRecording();
          }else grt.startRecording();
          break;
        case 't':
          grt.startTraining();
          break;
        case 's':
          grt.saveTrainingDatasetToFile( "TrainingData.txt" );
          break;
        case 'l':
          grt.loadTrainingDatasetFromFile( "TrainingData.txt" );
          break;
        case 'c':
          grt.clearTrainingDataset();
          break;
       }
   }
   
  @Override
  public void registerToSerialNotifier(SerialNotifier notifier){
    notifier.registerForSerialListener(this);
  }
  @Override
  public void removeToSerialNotifier(SerialNotifier notifier){
    notifier.removeSerialListener(this);
  }
  
  @Override
  public void updateAnalogVals(int [] values){}
  @Override
  public void updateCaliVals(int [] values){}
  @Override
  public void updateTargetAnalogValsMinAmp(int [] values){}
  @Override
  public void updateTargetAnalogValsWithAmp(int [] values){}
  @Override
  public void updateBridgePotPosVals(int [] values){}
  @Override
  public void updateAmpPotPosVals(int [] values){}
  @Override
  public void updateCalibratingValsMinAmp(int [] values){}
  @Override
  public void updateCalibratingValsWithAmp(int [] values){}

  // StringBuffer strBuffer = new StringBuffer();

 // private String getImageFileName() {
 //   strBuffer.setLength(0);
 //   strBuffer.append(StudyID);
 //   strBuffer.append("_");
 //   strBuffer.append(NowGesture);
 //   strBuffer.append("_");
 //   strBuffer.append(NowRow);
 //   return strBuffer.toString();
 // }
   @Override
  public void updateReceiveRecordSignal(){
    
  }

}

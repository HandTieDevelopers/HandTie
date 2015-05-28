
public class GRTMgr implements SerialListener{

   //-----------------------------------GRT
    //Set the pipeline mode (CLASSIFICATION_MODE or REGRESSION_MODE), the number of inputs and the number of outputs
    final int pipelineMode = GRT.CLASSIFICATION_MODE;
    final int numInputs = SGManager.NUM_OF_GAUGES + AccelMgr.NUM_OF_AXIS;
    final int numOutputs = 1;
    
   GRT grt = new GRT( pipelineMode, numInputs, numOutputs, "127.0.0.1", 5000, 5001, true );
   float[] data = new float[ numInputs ];
   float[] targetVector = new float[ numOutputs ];
   
   boolean showGETmsgFlg = true;
   
   public GRTMgr () {}

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
        // for(int sgi=1; sgi<numInputs; sgi++){
        //   data[sgi-1] = mainClass.sgManager.getOneElongationValsOfGauges(sgi);
        // }
        grt.sendData( data );
//        fill(color(200));
        textSize(50);
        text(grt.getPredictedClassLabel(),width*0.4,height*0.2);
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
   public void updateAnalogVals(float [] values){
      for (int i = 0; i < values.length; ++i) {
         data[i] = values[i];
      }
   }

   @Override
   public void updateCaliVals(float [] values){}
   @Override
   public void updateTargetAnalogValsMinAmp(float [] values){}
   @Override
   public void updateTargetAnalogValsWithAmp(float [] values){}
   @Override
   public void updateBridgePotPosVals(float [] values){}
   @Override
   public void updateAmpPotPosVals(float [] values){}
   @Override
   public void updateCalibratingValsMinAmp(float [] values){}
   @Override
   public void updateCalibratingValsWithAmp(float [] values){}

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
  public void updateReceiveRecordSignal(){}

}

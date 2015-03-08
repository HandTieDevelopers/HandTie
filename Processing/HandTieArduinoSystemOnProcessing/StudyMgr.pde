public class StudyMgr implements SerialListener{
  
   HandTieArduinoSystemOnProcessing mainClass;
   // public final static int NUM_OF_FINGERS = 5;
   public final static int NUM_OF_GESTURE_SET = 20;
   public final static int NUM_OF_EACH_TRAINING_TIMES = 5;
   public final static int NUM_OF_EACH_TRAINING_DATA = 100;

   public final static int NUM_OF_SG = 19;
   public final static int NUM_OF_SG_FIRSTROW = 9;

   public final static int NUM_OF_HAND_ROWS = 8;
   // public final static int NUM_OF_HAND_COLS = 5;
   public final static int GestureGrid = 6;

   public final static int ShowGauge_x = 400;
   public final static int ShowGauge_y = 30;

   public final static int EachSG_x = 50;
   public final static int EachSG_y = 20;   
   
   public final static int ShowGauge_dist = 30;
   
   public final static String StudyID = "10";
   
   public String ShowText = "Study #2";

   public int NowMainStage = 1;
   public int NowStudyStage = 0;
   

   public int NowGesture = 0;      

   public int NowRow = 0;        
             
   public boolean TransFlg = false; 
   public boolean PeriodRecordFlg = false; 
   public int PeriodRecordCounter;
   public boolean loadTableFlg = false; 
   
   public boolean autoSpace = false;
   public boolean autoL = false;
   // public int RowCount;

   int tCountArray[] = new int[NUM_OF_GESTURE_SET]; 
   int tCfinishRound;

   Table table;
   
   // PImage img;
   // int imgIndex =30;
   // PImage[] imgArray = new PImage[31];
   // boolean loadedImgFlg = false;

   public final static int imgWidth = 450;
   public final static int imgHeight = -30;

   public StudyMgr (HandTieArduinoSystemOnProcessing mainClass) {
      this.mainClass = mainClass;
      mainClass.expImgManager.setIndividualImageDirPath(StudyID);

      for(int i=0; i< NUM_OF_GESTURE_SET; i++){
            
                tCountArray[i]=0;  
            
      }
      tCfinishRound=0;
//      for(int i=86; i<86+30;i++){
//          imgArray[i-86]=loadImage("Photo/IMG_0"+(i<100?("0"+i):i)+".JPG");
//      }
//      RowCount = 0;
      
   }
   public void start(){
     switch (NowMainStage){
        case 1 :      //start
            textSize(40);
            fill(0, 102, 153);
            text("Study Two", width*0.39, height*0.45); 
            
           break;
        case 2 :      //
            textSize(26);
            fill(0, 102, 153);
            text("Gesture:"+NowGesture+"\nRow:"+NowRow, width*0.02, height*0.1); 
            for(int i=0; i< NUM_OF_GESTURE_SET; i++){
               for(int j=0; j<NUM_OF_EACH_TRAINING_TIMES; j++){
                  if(NowGesture == i && tCountArray[i]-1==j){
                    fill(color(0,255,0));
                  }
                  else{
                    fill((tCountArray[i]>j)?color(0):color(255));
                  }
                  rect(10+j*GestureGrid,height*0.2+i*GestureGrid+2*i,GestureGrid,GestureGrid);
               }
            }
            for(int r=0; r< NUM_OF_HAND_ROWS/2; r++){
                if(r==NowRow/2){
                    fill(color(0,255,0));
                }
                else{
                    fill(color(255));
                }
                rect(width*0.2+15,height*0.06-15+30*r,120,5);
                rect(width*0.2,height*0.06+30*r,150,5);
           
            }
            for(int sgi=0; sgi<NUM_OF_SG; sgi++){
                fill(getHeatmapRGB(mainClass.sgManager.getOneElongationValsOfGauges(sgi)));
                if(sgi<NUM_OF_SG_FIRSTROW){
                    rect(ShowGauge_x+sgi*EachSG_x,ShowGauge_y,EachSG_x,EachSG_y);
                }
                else{
                    rect(ShowGauge_x+(sgi-NUM_OF_SG_FIRSTROW-0.5)*EachSG_x,ShowGauge_y+ShowGauge_dist,EachSG_x,EachSG_y);

                }

            }
            fill(0,0,0);
            if(NowStudyStage==0){
               textSize(40);
               text("Press <BUTTON> to start", width*0.1, height*0.4); 
             }
             else{
               fill(255, 102, 153);
               textSize(40);
               
               if(TransFlg==false && PeriodRecordFlg==false){  
                 text("Record? <BUTTON>", width*0.1, height*0.4); 
               }
               else if(TransFlg){
                 text("ready? <BUTTON>", width*0.1, height*0.4); 
               } 
                 
             }
            if(PeriodRecordFlg){
                text(PeriodRecordCounter, width*0.1, height*0.44);

                if(PeriodRecordCounter+1<NUM_OF_EACH_TRAINING_DATA){
                  PeriodRecordCounter++;
                  AddNewRow();
                }
                else{
                    PeriodRecordFlg=false;
                    TransFlg=true;
                    if(randNextGes()){
                      if(NowRow+2 < NUM_OF_HAND_ROWS){
                              NowRow+=2;
                              tCfinishRound=0;
                              for(int i=0; i< NUM_OF_GESTURE_SET; i++){
                      
                                        tCountArray[i]=0;  
                                    
                              }
                          }
                          else{
                              NowMainStage=3;
                          }

                    }
                }
            }
            if(autoSpace==true && PeriodRecordFlg==false){
               nextStep(); 
             }
           break;   
         case 3:
             textSize(40);
            fill(0, 0, 0);
            text("Done", width*0.39, height*0.45); 

          break;
        case 4:
             textSize(40);
            fill(0, 0, 0);
            text("One More Thing...", width*0.3, height*0.45); 

          break;
        case 5:
            // if(loadedImgFlg){
            //   showImage();
            // }
            // else{
            //   text("Loading Images...", width*0.7, height*0.5); 
            // }
            fill(color(0,255));
             textSize(16);
            text("Stage: 1   2   3   4   5", 10, height*0.32); 
             for(int st=1; st<=5; st++){
                if(NowStudyStage==st){
                    fill(color(0,255,0));
                }
                else{
                    fill(color(255));
                }
                ellipse(66 + (st-1)*26, height*0.35, 10, 10);
              }
              if(autoSpace==true){
               nextStepView(); 
             }
          break;
        case 6:
             textSize(40);
            fill(0, 0, 0);
            text("Thank You", width*0.32, height*0.45); 

          break;
     }
//     for(int k=0; k < 3; k++ ){
       
//     }

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
        case '1' :
            NowMainStage=1;
           break;
        case '2' :
            // if(!loadedImgFlg){
         
            //     for(int i=86; i<86+30;i++){
            //           imgArray[i-86]=loadImage("Photo/IMG_0"+(i<100?("0"+i):i)+".JPG");
            //       }
            //     imgArray[30]=loadImage("Photo/blank.jpg");
            //     loadedImgFlg=true;
            // }
            for(int i=0; i< NUM_OF_GESTURE_SET; i++){
                tCountArray[i]=0;  
            }
            NowGesture=0;
            tCfinishRound =0;

            autoSpace=false;
            NewTable(); 
            NowMainStage=2;
            NowStudyStage=0;
            
            TransFlg=false;
            PeriodRecordFlg = false;
            PeriodRecordCounter = 0;
            NowRow = 0; 

           break;
        case '3' :
            // if(!loadedImgFlg){
         
            //     for(int i=86; i<86+30;i++){
            //           imgArray[i-86]=loadImage("Photo/IMG_0"+(i<100?("0"+i):i)+".JPG");
            //       }
            //     imgArray[30]=loadImage("Photo/blank.jpg");
            //     loadedImgFlg=true;
            // }
            NowMainStage=3;
           break;
        case 's':
            saveTable(table, "StudyData/User"+StudyID+".csv");
           break ;
        case ESC:
            saveTable(table, "StudyData/User"+StudyID+".csv");
           break;
        case '~':
            // println("Loading Table...");
            // table = loadTable("StudyData/User"+StudyID+".csv","header");
            // int lastRow = table.getRowCount()-1;
            // // NowDegree = table.getInt(lastRow,"Degree");
            // NowCol1 = table.getInt(lastRow,"Cols1");        
            // NowRow1 = table.getInt(lastRow,"Rows1"); 
            // NowCol2 = table.getInt(lastRow,"Cols2");        
            // NowRow2 = table.getInt(lastRow,"Rows2"); 
            // NowCol3 = table.getInt(lastRow,"Cols3");        
            // NowRow3 = table.getInt(lastRow,"Rows3");
            // NowCol4 = table.getInt(lastRow,"Cols4");        
            // NowRow4 = table.getInt(lastRow,"Rows4");
            // NowFinger = table.getInt(lastRow,"Finger"); 
            // NowStudyStage = table.getInt(lastRow,"Stage"); 
            // NowLevel = table.getInt(lastRow,"Level");
            // NowBend = (table.getInt(lastRow,"Bend")==1)?true:false;
            // TransFlg=false;
            // loadTableFlg = true;
            // lastStep();
           break;
        case 'l':
              lastStep();
              DeleteRow();
           break;
        case RETURN:
            text("Delete", width*0.39, height*0.45);
            DeleteRow();
           break ;
        case ' ' :
          nextStep();
          // nextStep();
          // if(loadedImgFlg && NowMainStage==2){
          //   nextStep();
          // }
          // else if(NowMainStage==3){
          //     NowMainStage=4;
          // }
          // else if(NowMainStage==4){
          //     NowMainStage=5;
          //     NowStudyStage=0;
              
          //     NowFinger = 0;
          //     NowLevel=0;      //mid
          //     NowBend=false;     //s
          //     nextStepView();
          //     autoSpace=false;
          // }
          // else if(NowMainStage==5){
          //     nextStepView();
          // }
          break;
        case 'o' :
            if(!autoL){
              autoSpace=!autoSpace;
            }
          break;
        case 'p' :
            if(!autoSpace){
              autoL=!autoL;
            }
           
          break;
      }
   }
   public boolean randNextGes(){
        int randGes = floor(random(0, NUM_OF_GESTURE_SET));
        boolean fillYet =false;

        if(tCountArray[randGes]>tCfinishRound){

          int tmpi = (randGes+1 >= NUM_OF_GESTURE_SET)?0:randGes+1;

          while (tmpi!=randGes) {
            if(tCountArray[tmpi]<=tCfinishRound){
                  tCountArray[tmpi]++;
                  NowGesture = tmpi;
                  // println("randGes: "+randGes+", tmpi: "+ tmpi);
                  fillYet = true;           
            }
            if(fillYet){
              tmpi = randGes;
              // println("out while");
            }
            else{
              tmpi=(tmpi+1>=NUM_OF_GESTURE_SET)?0:tmpi+1;
              // println(">tmpi: "+tmpi);
            }
          }
          
          if(!fillYet){
              tCountArray[randGes]++;
              NowGesture = randGes;
              if(tCfinishRound+1<NUM_OF_EACH_TRAINING_TIMES){
                tCfinishRound++;
              }
              else{
                return true;
              }

          }
        }
        else{
          tCountArray[randGes]++;
          NowGesture = randGes;
        }
        return false;
   }
   public void AddNewRow(){
    if(loadTableFlg){
        loadTableFlg=false;
    }
    else{
      TableRow tmpNewRow = table.addRow();

      // tmpNewRow.setString("Degree",str(NowDegree));
      tmpNewRow.setString("Gesture", str(NowGesture));
     
      tmpNewRow.setString("Line1", str(NowRow));
      tmpNewRow.setString("SG1_0",str(mainClass.sgManager.getOneElongationValsOfGauges(0)));
      tmpNewRow.setString("SG1_1",str(mainClass.sgManager.getOneElongationValsOfGauges(1)));
      tmpNewRow.setString("SG1_2",str(mainClass.sgManager.getOneElongationValsOfGauges(2)));
      tmpNewRow.setString("SG1_3",str(mainClass.sgManager.getOneElongationValsOfGauges(3)));
      tmpNewRow.setString("SG1_4",str(mainClass.sgManager.getOneElongationValsOfGauges(4)));
      tmpNewRow.setString("SG1_5",str(mainClass.sgManager.getOneElongationValsOfGauges(5)));
      tmpNewRow.setString("SG1_6",str(mainClass.sgManager.getOneElongationValsOfGauges(6)));
      tmpNewRow.setString("SG1_7",str(mainClass.sgManager.getOneElongationValsOfGauges(7)));
      tmpNewRow.setString("SG1_8",str(mainClass.sgManager.getOneElongationValsOfGauges(8)));
      
      tmpNewRow.setString("Line2", str(NowRow+1));

      tmpNewRow.setString("SG2_0",str(mainClass.sgManager.getOneElongationValsOfGauges(9)));
      tmpNewRow.setString("SG2_1",str(mainClass.sgManager.getOneElongationValsOfGauges(10)));
      tmpNewRow.setString("SG2_2",str(mainClass.sgManager.getOneElongationValsOfGauges(11)));
      tmpNewRow.setString("SG2_3",str(mainClass.sgManager.getOneElongationValsOfGauges(12)));
      tmpNewRow.setString("SG2_4",str(mainClass.sgManager.getOneElongationValsOfGauges(13)));  
      tmpNewRow.setString("SG2_5",str(mainClass.sgManager.getOneElongationValsOfGauges(14)));  
      tmpNewRow.setString("SG2_6",str(mainClass.sgManager.getOneElongationValsOfGauges(15)));  
      tmpNewRow.setString("SG2_7",str(mainClass.sgManager.getOneElongationValsOfGauges(16)));  
      tmpNewRow.setString("SG2_8",str(mainClass.sgManager.getOneElongationValsOfGauges(17)));  
      tmpNewRow.setString("SG2_9",str(mainClass.sgManager.getOneElongationValsOfGauges(18)));  
      
     
    }
    // RowCount++;

   }
   public void DeleteRow(){
     // RowCount--;
     if(table.getRowCount()>0){
       table.removeRow(table.getRowCount()-1);
     }
   }
   public void NewTable(){
      table = new Table();
      
      // table.addColumn("Degree");
      table.addColumn("Gesture");
    
      table.addColumn("Line1");
      table.addColumn("SG1_0");
      table.addColumn("SG1_1");
      table.addColumn("SG1_2");
      table.addColumn("SG1_3");
      table.addColumn("SG1_4");
      table.addColumn("SG1_5");
      table.addColumn("SG1_6");
      table.addColumn("SG1_7");
      table.addColumn("SG1_8");

      table.addColumn("Line2");
      table.addColumn("SG2_0");
      table.addColumn("SG2_1");
      table.addColumn("SG2_2");
      table.addColumn("SG2_3");
      table.addColumn("SG2_4");
      table.addColumn("SG2_5");
      table.addColumn("SG2_6");
      table.addColumn("SG2_7");
      table.addColumn("SG2_8");
      table.addColumn("SG2_9");

   }
   public void lastStep(){

   }
   public void nextStep(){
        if(NowMainStage==2){
            if(NowStudyStage==0){
                NowStudyStage=1;
                TransFlg=true;
                PeriodRecordFlg = false;
                randNextGes();
            }
            else if(NowStudyStage==1){
                if(TransFlg){
                  TransFlg=false;                 
                }
                else{
                  
                  PeriodRecordFlg = true;
                  PeriodRecordCounter = 0;
                  
                }

            }

        }
   }
   // public void loadWhichImage(){
    
   //   if(TransFlg){

   //      imgIndex = 30;
   //   }
   //   else{
       
   //        if(NowStudyStage == 1){
   //          if(NowLevel==0){
   //            switch (NowFinger) {
   //               case 0:
   //                 imgIndex = 0;
   //                  break;
   //               case 1:
   //                 imgIndex = 6;
   //                  break;
   //               case 2:
   //                 imgIndex = 12;
   //                  break;
   //               case 3:
   //                 imgIndex = 18;
   //                  break;
   //               case 4:
   //                 imgIndex = 24;
   //                  break;
   //            }
              
   //          }
   //          else if(NowLevel==1){
   //            switch (NowFinger) {
   //               case 0:
   //                 imgIndex = 1;
   //                  break;
   //               case 1:
   //                 imgIndex = 7;
   //                  break;
   //               case 2:
   //                 imgIndex = 13;
   //                  break;
   //               case 3:
   //                 imgIndex = 19;
   //                  break;
   //               case 4:
   //                 imgIndex = 29;
   //                  break;
   //            }
               
   //          }
   //          else{
   //            switch (NowFinger) {
   //               case 0:
   //                 imgIndex = 2;
   //                  break;
   //               case 1:
   //                 imgIndex = 8;
   //                  break;
   //               case 2:
   //                 imgIndex = 14;
   //                  break;
   //               case 3:
   //                 imgIndex = 20;
   //                  break;
   //               case 4:
   //                 imgIndex = 25;
   //                  break;
   //            }
               
   //          }
   //        }
   //        else if(NowStudyStage == 2){
   //          if(NowLevel==0){
   //            switch (NowFinger) {
   //               case 0:
   //                 imgIndex = 3;
   //                  break;
   //               case 1:
   //                 imgIndex = 9;
   //                  break;
   //               case 2:
   //                 imgIndex = 15;
   //                  break;
   //               case 3:
   //                 imgIndex = 21;
   //                  break;
   //               case 4:
   //                 imgIndex = 26;
   //                  break;
   //            }
              
   //          }
   //          else if(NowLevel==1){
   //            switch (NowFinger) {
   //               case 0:
   //                 imgIndex = 4;
   //                  break;
   //               case 1:
   //                 imgIndex = 10;
   //                  break;
   //               case 2:
   //                 imgIndex = 16;
   //                  break;
   //               case 3:
   //                 imgIndex = 22;
   //                  break;
   //               case 4:
   //                 imgIndex = 27;
   //                  break;
   //            }
               
   //          }
   //          else{
   //            switch (NowFinger) {
   //               case 0:
   //                 imgIndex = 5;
   //                  break;
   //               case 1:
   //                 imgIndex = 11;
   //                  break;
   //               case 2:
   //                 imgIndex = 17;
   //                  break;
   //               case 3:
   //                 imgIndex = 23;
   //                  break;
   //               case 4:
   //                 imgIndex = 28;
   //                  break;
   //            }
               
   //          }
   //        }
   //        else if(NowStudyStage == 3){
   //            if(NowBend==true){
   //              switch (NowFinger) {
   //               case 0:
   //                 imgIndex = 4;
   //                  break;
   //               case 1:
   //                 imgIndex = 10;
   //                  break;
   //               case 2:
   //                 imgIndex = 16;
   //                  break;
   //               case 3:
   //                 imgIndex = 22;
   //                  break;
   //               case 4:
   //                 imgIndex = 27;
   //                  break;
   //              }
                
   //            }
   //            else{
   //              switch (NowFinger) {
   //               case 0:
   //                 imgIndex = 1;
   //                  break;
   //               case 1:
   //                 imgIndex = 7;
   //                  break;
   //               case 2:
   //                 imgIndex = 13;
   //                  break;
   //               case 3:
   //                 imgIndex = 19;
   //                  break;
   //               case 4:
   //                 imgIndex = 29;
   //                  break;
   //              }
                
   //            }
   //        }
   //        else if(NowStudyStage == 4){
   //            if(NowBend==true){
   //              switch (NowFinger) {
   //               case 0:
   //                 imgIndex = 3;
   //                  break;
   //               case 1:
   //                 imgIndex = 9;
   //                  break;
   //               case 2:
   //                 imgIndex = 15;
   //                  break;
   //               case 3:
   //                 imgIndex = 21;
   //                  break;
   //               case 4:
   //                 imgIndex = 26;
   //                  break;
   //              }
                
   //            }
   //            else{
   //              switch (NowFinger) {
   //               case 0:
   //                 imgIndex = 0;
   //                  break;
   //               case 1:
   //                 imgIndex = 6;
   //                  break;
   //               case 2:
   //                 imgIndex = 12;
   //                  break;
   //               case 3:
   //                 imgIndex = 18;
   //                  break;
   //               case 4:
   //                 imgIndex = 24;
   //                  break;
   //              }
                
   //            }
   //        }
   //        else if(NowStudyStage == 5){
   //            if(NowBend==true){
   //              switch (NowFinger) {
   //               case 0:
   //                 imgIndex = 5;
   //                  break;
   //               case 1:
   //                 imgIndex = 11;
   //                  break;
   //               case 2:
   //                 imgIndex = 17;
   //                  break;
   //               case 3:
   //                 imgIndex = 23;
   //                  break;
   //               case 4:
   //                 imgIndex = 28;
   //                  break;
   //              }
                
   //            }
   //            else{
   //              switch (NowFinger) {
   //               case 0:
   //                 imgIndex = 2;
   //                  break;
   //               case 1:
   //                 imgIndex = 8;
   //                  break;
   //               case 2:
   //                 imgIndex = 14;
   //                  break;
   //               case 3:
   //                 imgIndex = 20;
   //                  break;
   //               case 4:
   //                 imgIndex = 25;
   //                  break;
   //              }
                
   //            }
   //        }
       

   //   }
    
   // }
   // public void showSGPos(){
   //   final int SG_dist = 30;
   //   final int SG_X = 350;
   //   final int SG_Y = 130;
     
   //   for(int i=0; i<NUM_OF_HAND_COLS ; i++){
   //     for(int j=0; j<NUM_OF_HAND_ROWS ; j++){
          
   //         if(NowRow1==j && NowCol1==i){
   //            fill(255,0,0);
   //            ellipse(SG_X+SG_dist*i, SG_Y+SG_dist*j, 20, 20);
   //         }
   //         else if(NowRow2==j && NowCol2==i){
   //            fill(255,255,0);
   //            ellipse(SG_X+SG_dist*i, SG_Y+SG_dist*j, 20, 20);
   //         }
   //         else if(NowRow3==j && NowCol3==i){
   //            fill(0,0,255);
   //            ellipse(SG_X+SG_dist*i, SG_Y+SG_dist*j, 20, 20);
   //         }
   //         else if(NowRow4==j && NowCol4==i){
   //            fill(0,255,255);
   //            ellipse(SG_X+SG_dist*i, SG_Y+SG_dist*j, 20, 20);
   //         }
   //         else{
   //            fill(0,0,0);
   //            ellipse(SG_X+SG_dist*i, SG_Y+SG_dist*j, 5, 5);
   //         }
          
   //     }
   //   }
   
   // }
   // public void showImage(){
   //    if(NowStudyStage>0){
   //      image(imgArray[imgIndex], imgWidth, imgHeight, width/2 , height );
   //    }
   // }
  public void nextStepView(){
           
   }

   // public void performMousePress(){

   // }
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

  StringBuffer strBuffer = new StringBuffer();

 private String getImageFileName() {
   strBuffer.setLength(0);
   strBuffer.append(StudyID);
   strBuffer.append("_");
   strBuffer.append(NowGesture);
   strBuffer.append("_");
   strBuffer.append(NowRow);
   return strBuffer.toString();
 }

  @Override
  public void updateReceiveRecordSignal(){
    performKeyPress(' ');
    mainClass.expImgManager.captureImage(getImageFileName());
  }

}

public class StudyMgr {
  
   HandTieArduinoSystemOnProcessing mainClass;
   public final static int NUM_OF_FINGERS = 5;
   public final static int NUM_OF_HAND_ROWS = 6;
   public final static int NUM_OF_HAND_COLS = 5;
   public final static int NUM_OF_Degree = 3;
   
   public final static int ShowGauge_x = 650;
   public final static int ShowGauge_y = 350;
   public final static int ShowGauge_dist = 40;
   
   public String ShowText = "Study #1";
   public int NowMainStage = 1;
   public int NowStudyStage = 0;
   
   public int NowDegree = 0;      //3
   public int NowCol = 0;         //5
   public int NowRow = 0;          //6  =90
   public int NowFinger = 0;      //5
   public int NowLevel = 0;      //0: mid 1:high 2:low
   public boolean NowBend = false; 
   
   public boolean TransFlg = false; 
   
   public StudyMgr (HandTieArduinoSystemOnProcessing mainClass) {
      this.mainClass = mainClass;
   }
   public void start(){
     switch (NowMainStage){
        case 1 :      //start
            textSize(40);
            fill(0, 102, 153);
            text("Study One", width*0.39, height*0.45); 
           break;
        case 2 :      //
            textSize(20);
            fill(0, 102, 153);
            text("Degree: "+ ((NowDegree==0)?"0":((NowDegree==1)?"45":"90"))+"\nRow: "+NowRow+", Col: "+NowCol+"\nFinger: "+NowFinger+"\nLevel: "+((NowLevel==0)?"Mid":((NowLevel==1)?"High":"Low"))+"\nBend: "+((NowBend==false)?"Straight":"Bend"), 10, 30);
//            rect(width*0.1,height*(0.1),200,200);
            text("Stage:"+NowStudyStage, 10, height*0.45); 
            if(NowStudyStage==0){
               textSize(40);
               text("Press <SPACE> to start", width*0.25, height*0.45); 
             }
             else{
               fill(255, 102, 153);
               textSize(40);
               
               if(TransFlg==false){  
                 text("Record? <SPACE>", width*0.25, height*0.45); 
               }
               else{
                 text("Stage "+ NowStudyStage+ " ready? <SPACE>", width*0.25, height*0.45); 
               } 
                 
             }
             
             for(int i=0; i < 4; i++ ){
                for(int j=0; j < 2; j++ ){
                   fill(200+i*10,100+j*20,250-i*20);
                   pushMatrix();
                   if(NowDegree==0){
                     translate(ShowGauge_x, ShowGauge_y);
                   }
                   else if(NowDegree==1){
                     translate(ShowGauge_x-30,ShowGauge_y+80);
                   }
                   else if(NowDegree==2){
                     translate(ShowGauge_x,ShowGauge_y+160);
                   }
                   
                   rotate(radians(-45*NowDegree));
                     rect( ShowGauge_dist*2*j, ShowGauge_dist*i,ShowGauge_dist*2,ShowGauge_dist);
                   popMatrix();
                }
             } 
           break;
         case 3:
             textSize(40);
            fill(0, 102, 153);
            text("Done", width*0.39, height*0.45); 
          break;
     }
//     for(int k=0; k < 3; k++ ){
       
//     }
   }
   
   public void performKeyPress(char k){
      switch (k) {
        case 'c' :
            //gaugeCalibration();
            break;
        case '1' :
            NowMainStage=1;
           break;
        case '2' :
            NowMainStage=2;
            NowStudyStage=0;
            NowDegree = 0;      //3
            NowCol = 0;         //5
            NowRow = 0; 
            NowLevel=0;      //mid
            NowBend=false;     //s
            TransFlg=false;

           break;
        case ' ' :
            if(NowMainStage==2){
                if(NowStudyStage==0){
                  NowStudyStage=1;
                  NowLevel=0;      //mid
                  NowBend=false;     //s
                  TransFlg=true;
                }
                else if(NowStudyStage==1){
                  if(NowLevel==0){
                     if(TransFlg==true){
                      TransFlg=false;
                    }
                    else{
                      NowLevel=1;  //high
                    }
                  }
                  else if(NowLevel==1){
                    NowLevel=2;  //low
                  }
                  else if(NowLevel==2){
                    NowLevel=0;  //mid
                    NowStudyStage=2;
                    NowBend=true;     //b
                    TransFlg = true;
                  }
                }
                else if(NowStudyStage==2){
                  if(NowLevel==0){
                    if(TransFlg==true){
                      TransFlg=false;
                    }
                    else{
                      NowLevel=1;  //high
                    }
                  }
                  else if(NowLevel==1){
                    NowLevel=2;  //low
                  }
                  else if(NowLevel==2){
                    NowLevel=1;  //high
                    NowStudyStage=3;  
                    NowBend=false;     //s
                    TransFlg = true;
                  }
                }
                else if(NowStudyStage==3){
                  if(NowBend==false){
                    if(TransFlg==true){
                      TransFlg=false;
                    }
                    else{
                      NowBend=true;  //bend
                    }
                  }
                  else if(NowBend==true){
                    NowBend=false;  //s
                    NowLevel=0;  //mid
                    NowStudyStage=4;
                    NowBend=false;     //s
                    TransFlg = true;
                  }
                  
                }
                else if(NowStudyStage==4){
                  if(NowBend==false){
                    if(TransFlg==true){
                      TransFlg=false;
                    }
                    else{
                      NowBend=true;  //bend
                    }
                  }
                  else if(NowBend==true){
                    NowBend=false;  //s
                    NowLevel=2;  //low
                    NowStudyStage=5;
                    NowBend=false;     //s
                    TransFlg = true;
                  }
                }
                else if(NowStudyStage==5){
                  if(NowBend==false){
                    if(TransFlg==true){
                      TransFlg=false;
                    }
                    else{
                      NowBend=true;  //bend
                    }
                  }
                  else if(NowBend==true){
                    NowBend=false;  //s
                    TransFlg = true;
                    NowStudyStage=0;
                    if(NowFinger<NUM_OF_FINGERS-1){
                      NowFinger++;
                    }
                    else{
                      NowFinger=0;
                      
                      if(NowRow<NUM_OF_HAND_ROWS-1){
                        NowRow++;
                      }
                      else{
                        NowRow=0;
                        if(NowCol<NUM_OF_HAND_COLS-1){
                          NowCol++;
                        }
                        else{
                          NowCol=0;
                          if(NowDegree<NUM_OF_Degree-1){
                            NowDegree++;
                          }
                          else{
                            NowMainStage=3;
                          }
                        }
                      }
                    }
                  }
                }
            }
          break;
      }
   }

//   public void gaugeCalibration(){
//      mainClass.sgManager.requestForCaliVals = true;
//      mainClass.serialManager.sendToArduino("0");
//   }

   // public void performMousePress(){

   // }

}

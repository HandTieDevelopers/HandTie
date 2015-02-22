public class StudyMgr implements SerialListener{
  
   HandTieArduinoSystemOnProcessing mainClass;
   public final static int NUM_OF_FINGERS = 5;
   public final static int NUM_OF_HAND_ROWS = 4;
   public final static int NUM_OF_HAND_COLS = 5;
   // public final static int NUM_OF_Degree = 2;
   
   public final static int ShowGauge_x = 630;
   public final static int ShowGauge_y = 350;

   public final static int ShowGauge_x2_dist = 140;
   public final static int ShowGauge_y2_dist = 110;   
   
   public final static int ShowGauge_dist = 25;
   
   public final static String StudyID = "2";
   
   public String ShowText = "Study #1";
   public int NowMainStage = 1;
   public int NowStudyStage = 0;
   
   // public int NowDegree = 0;      //3
 
   public int NowFinger = 0;      //5
   public int NowLevel = 0;      //0: mid 1:high 2:low
   public boolean NowBend = false; 

   public int NowCol1 = 0;         //5
   public int NowRow1 = 0;          //6  =90

   public int NowCol2 = NowCol1;         
   public int NowRow2 = NowRow1+2;

   public int NowCol4 = NUM_OF_HAND_COLS-1;         
   public int NowRow4 = NUM_OF_HAND_ROWS-1;   

   public int NowCol3 = NowCol4;         
   public int NowRow3 = NowRow4-2; 

             
   public boolean TransFlg = false; 

   public boolean loadTableFlg = false; 
   
   public boolean autoSpace = false;
   public boolean autoL = false;
   // public int RowCount;

   Table table;
   
   PImage img;
   int imgIndex =30;
   PImage[] imgArray = new PImage[31];
   boolean loadedImgFlg = false;

   public final static int imgWidth = 450;
   public final static int imgHeight = -30;

   public StudyMgr (HandTieArduinoSystemOnProcessing mainClass) {
      this.mainClass = mainClass;
      mainClass.expImgManager.setIndividualImageDirPath(StudyID);
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
            text("Study One", width*0.39, height*0.45); 
            
           break;
        case 2 :      //
            
            textSize(20);
            fill(0, 102, 153);      
            
            if(loadedImgFlg){
              showImage();
            }
            else{
              text("Loading Images...", width*0.7, height*0.5); 
            }
           
            text("Col1: "+NowCol1+", Row1: "+NowRow1+"\nCol2: "+NowCol2+", Row2: "+NowRow2+"\nFinger: "+NowFinger, 10, 30);
            text("\nLevel: "+((NowLevel==0)?"Mid":((NowLevel==1)?"High":"Low"))+"\nBend: "+((NowBend==false)?"Straight":"Bend"), width-170, 100);
            text("Col3: "+NowCol3+" Row3: "+NowRow3+"\nCol4: "+NowCol4+" Row4: "+NowRow4, width-170, 30);
//            rect(width*0.1,height*(0.1),200,200);
            //text("Stage:"+NowStudyStage, 10, height*0.45); 

            if(NowStudyStage==0){
               textSize(40);
               text("Press <SPACE> to start", width*0.25, height*0.1); 
             }
             else{
               fill(255, 102, 153);
               textSize(40);
               
               if(TransFlg==false){  
                 text("Record? <SPACE>", width*0.25, height*0.1); 
               }
               else{
                 text("Stage "+ NowStudyStage+ " ready? <SPACE>", width*0.25, height*0.1); 
               } 
                 
             }
             
             for(int i=0; i < 4; i++ ){
                for(int j=0; j < 2; j++ ){
                   if((i%2==0 && j%2==0) || (i%2==1 && j%2==1)){
                      fill(getHeatmapRGB(mainClass.sgManager.getOneElongationValsOfGauges(floor((i*2+j)/2))));
                   }
                   else{
                      fill(255);
                   }              
                     rect( ShowGauge_x+ShowGauge_dist*2*j, ShowGauge_y+ShowGauge_dist*i,ShowGauge_dist*2,ShowGauge_dist);
                   
                   if((i%2==0 && j%2==0) || (i%2==1 && j%2==1)){
                      fill(getHeatmapRGB(mainClass.sgManager.getOneElongationValsOfGauges(8+floor((i*2+j)/2))));
                   }
                   else{
                      fill(255);
                   }       
                     rect( ShowGauge_x+ShowGauge_x2_dist+ShowGauge_dist*2*j, ShowGauge_y+ShowGauge_dist*i,ShowGauge_dist*2,ShowGauge_dist);
                   
                   if((i%2==0 && j%2==0) || (i%2==1 && j%2==1)){
                      fill(getHeatmapRGB(mainClass.sgManager.getOneElongationValsOfGauges(4+floor((i*2+j)/2))));
                   }
                   else{
                      fill(255);
                   }       
                     rect( ShowGauge_x+ShowGauge_dist*2*j, ShowGauge_y+ShowGauge_y2_dist+ShowGauge_dist*i,ShowGauge_dist*2,ShowGauge_dist);
                   
                   if((i%2==0 && j%2==0) || (i%2==1 && j%2==1)){
                      fill(getHeatmapRGB(mainClass.sgManager.getOneElongationValsOfGauges(12+floor((i*2+j)/2))));
                   }
                   else{
                      fill(255);
                   }       
                     rect( ShowGauge_x+ShowGauge_x2_dist+ShowGauge_dist*2*j, ShowGauge_y+ShowGauge_y2_dist+ShowGauge_dist*i,ShowGauge_dist*2,ShowGauge_dist);
                   
                }
             }


             if(autoSpace==true){
               nextStep(); 
             }
             if(autoL==true){
                lastStep(); 
             }
             showSGPos();

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
            if(loadedImgFlg){
              showImage();
            }
            else{
              text("Loading Images...", width*0.7, height*0.5); 
            }
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
            if(!loadedImgFlg){
         
                for(int i=86; i<86+30;i++){
                      imgArray[i-86]=loadImage("Photo/IMG_0"+(i<100?("0"+i):i)+".JPG");
                  }
                imgArray[30]=loadImage("Photo/blank.jpg");
                loadedImgFlg=true;
            }
            autoSpace=false;
            NewTable(); 
            NowMainStage=2;
            NowStudyStage=0;
            // NowDegree = 0;      //3
            
            NowFinger = 0;
            NowLevel=0;      //mid
            NowBend=false;     //s
            TransFlg=false;

            NowCol1 = 0;         //5
            NowRow1 = 0; 

            NowCol2 = NowCol1;         
            NowRow2 = NowRow1+2;

            NowCol4 = NUM_OF_HAND_COLS-1;         
            NowRow4 = NUM_OF_HAND_ROWS-1;   

            NowCol3 = NowCol4;         
            NowRow3 = NowRow4-2; 

           break;
        case '3' :
            if(!loadedImgFlg){
         
                for(int i=86; i<86+30;i++){
                      imgArray[i-86]=loadImage("Photo/IMG_0"+(i<100?("0"+i):i)+".JPG");
                  }
                imgArray[30]=loadImage("Photo/blank.jpg");
                loadedImgFlg=true;
            }
            NowMainStage=3;
           break;
        case 's':
            saveTable(table, "StudyData/User"+StudyID+".csv");
           break ;
        case ESC:
            saveTable(table, "StudyData/User"+StudyID+".csv");
           break;
        case '~':
            println("Loading Table...");
            table = loadTable("StudyData/User"+StudyID+".csv","header");
            int lastRow = table.getRowCount()-1;
            // NowDegree = table.getInt(lastRow,"Degree");
            NowCol1 = table.getInt(lastRow,"Cols1");        
            NowRow1 = table.getInt(lastRow,"Rows1"); 
            NowCol2 = table.getInt(lastRow,"Cols2");        
            NowRow2 = table.getInt(lastRow,"Rows2"); 
            NowCol3 = table.getInt(lastRow,"Cols3");        
            NowRow3 = table.getInt(lastRow,"Rows3");
            NowCol4 = table.getInt(lastRow,"Cols4");        
            NowRow4 = table.getInt(lastRow,"Rows4");
            NowFinger = table.getInt(lastRow,"Finger"); 
            NowStudyStage = table.getInt(lastRow,"Stage"); 
            NowLevel = table.getInt(lastRow,"Level");
            NowBend = (table.getInt(lastRow,"Bend")==1)?true:false;
            TransFlg=false;
            loadTableFlg = true;
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
          if(loadedImgFlg && NowMainStage==2){
            nextStep();
          }
          else if(NowMainStage==3){
              NowMainStage=4;
          }
          else if(NowMainStage==4){
              NowMainStage=5;
              NowStudyStage=0;
              
              NowFinger = 0;
              NowLevel=0;      //mid
              NowBend=false;     //s
              nextStepView();
              autoSpace=false;
          }
          else if(NowMainStage==5){
              nextStepView();
          }
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
   public void AddNewRow(){
    if(loadTableFlg){
        loadTableFlg=false;
    }
    else{
      TableRow tmpNewRow = table.addRow();

      // tmpNewRow.setString("Degree",str(NowDegree));
      tmpNewRow.setString("Finger", str(NowFinger));
      tmpNewRow.setString("Stage", str(NowStudyStage));
      tmpNewRow.setString("Level", str(NowLevel));
      tmpNewRow.setString("Bend", str(NowBend));
      tmpNewRow.setString("Cols1", str(NowCol1));
      tmpNewRow.setString("Rows1", str(NowRow1));
      tmpNewRow.setString("SG1_0",str(mainClass.sgManager.getOneElongationValsOfGauges(0)));
      tmpNewRow.setString("SG1_1",str(mainClass.sgManager.getOneElongationValsOfGauges(1)));
      tmpNewRow.setString("SG1_2",str(mainClass.sgManager.getOneElongationValsOfGauges(2)));
      tmpNewRow.setString("SG1_3",str(mainClass.sgManager.getOneElongationValsOfGauges(3)));
      tmpNewRow.setString("Cols2", str(NowCol2));
      tmpNewRow.setString("Rows2", str(NowRow2));
      tmpNewRow.setString("SG2_0",str(mainClass.sgManager.getOneElongationValsOfGauges(4)));
      tmpNewRow.setString("SG2_1",str(mainClass.sgManager.getOneElongationValsOfGauges(5)));
      tmpNewRow.setString("SG2_2",str(mainClass.sgManager.getOneElongationValsOfGauges(6)));
      tmpNewRow.setString("SG2_3",str(mainClass.sgManager.getOneElongationValsOfGauges(7)));     
      tmpNewRow.setString("Cols3", str(NowCol3));
      tmpNewRow.setString("Rows3", str(NowRow3));
      tmpNewRow.setString("SG3_0",str(mainClass.sgManager.getOneElongationValsOfGauges(8)));
      tmpNewRow.setString("SG3_1",str(mainClass.sgManager.getOneElongationValsOfGauges(9)));
      tmpNewRow.setString("SG3_2",str(mainClass.sgManager.getOneElongationValsOfGauges(10)));
      tmpNewRow.setString("SG3_3",str(mainClass.sgManager.getOneElongationValsOfGauges(11)));
      tmpNewRow.setString("Cols4", str(NowCol4));
      tmpNewRow.setString("Rows4", str(NowRow4));
      tmpNewRow.setString("SG4_0",str(mainClass.sgManager.getOneElongationValsOfGauges(12)));
      tmpNewRow.setString("SG4_1",str(mainClass.sgManager.getOneElongationValsOfGauges(13)));
      tmpNewRow.setString("SG4_2",str(mainClass.sgManager.getOneElongationValsOfGauges(14)));
      tmpNewRow.setString("SG4_3",str(mainClass.sgManager.getOneElongationValsOfGauges(15))); 
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
      table.addColumn("Finger");
      table.addColumn("Stage");
      table.addColumn("Level");
      table.addColumn("Bend");

      table.addColumn("Cols1");
      table.addColumn("Rows1");
      table.addColumn("SG1_0");
      table.addColumn("SG1_1");
      table.addColumn("SG1_2");
      table.addColumn("SG1_3");

      table.addColumn("Cols2");
      table.addColumn("Rows2");
      table.addColumn("SG2_0");
      table.addColumn("SG2_1");
      table.addColumn("SG2_2");
      table.addColumn("SG2_3");

      table.addColumn("Cols3");
      table.addColumn("Rows3");
      table.addColumn("SG3_0");
      table.addColumn("SG3_1");
      table.addColumn("SG3_2");
      table.addColumn("SG3_3");

      table.addColumn("Cols4");
      table.addColumn("Rows4");
      table.addColumn("SG4_0");
      table.addColumn("SG4_1");
      table.addColumn("SG4_2");
      table.addColumn("SG4_3");

   }
   public void lastStep(){
            if(NowMainStage==2){
                

                if(NowStudyStage==5){
                    if(NowBend==true){
                        NowLevel=2;
                        NowBend=false;

                    }
                    else{
                        NowLevel=0;
                        NowBend=true;
                        TransFlg=true;
                        NowStudyStage=4;
                    }
                }
                else if(NowStudyStage==4){
                    if(NowBend==true){
                        NowLevel=0;
                        NowBend=false;
                    }
                    else{
                        NowLevel=1;
                        NowBend=true;
                        TransFlg=true;
                        NowStudyStage=3;
                    }
                }
                else if(NowStudyStage==3){
                    if(NowBend==true){
                        NowLevel=1;
                        NowBend=false;
                    }
                    else{
                        NowLevel=2;
                        NowBend=true;
                        TransFlg=true;
                        NowStudyStage=2;
                    }
                }
                else if(NowStudyStage==2){
                    if(NowLevel==2){
                        NowLevel=1;
                        NowBend=true;
                    }
                    else if(NowLevel==1){
                        NowLevel=0;
                        NowBend=true;
                    }
                    else{
                        NowLevel=2;
                        NowBend=false;
                        TransFlg=true;
                        NowStudyStage=1;
                    }
                }
                else if(NowStudyStage==1){
                    if(NowLevel==2){
                        NowLevel=1;
                        NowBend=false;
                    }
                    else if(NowLevel==1){
                        NowLevel=0;
                        NowBend=false;
                    }
                    else{
                        NowLevel=0;
                        NowBend=false;
                        TransFlg=true;
                        NowStudyStage=5;

                        if(NowFinger>0){
                          NowFinger--;
                        }
                        else{
                          NowFinger=NUM_OF_FINGERS-1;  

                          if(NowCol1>0){
                            NowCol1--;
                            NowCol2=NowCol1;

                            if(NowCol1==floor((NUM_OF_HAND_COLS)/2)-1){
                                NowCol3=NowCol1+2;
                                NowCol4=NowCol3;
                            }
                            else if(NowCol1 < floor((NUM_OF_HAND_COLS)/2)-1){
                                NowCol3++;
                                NowCol4=NowCol3;
                            }
                            else{
                                NowCol3--;
                                NowCol4=NowCol3;
                            }
                            
                          }
                          else{
                              
                              NowMainStage=1;
                              autoL=false;
                              
                          }

                          
                        }

                    }

                }


            }
            TransFlg = false;
            loadWhichImage();
   }
   public void nextStep(){
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
                      AddNewRow();         
                      NowLevel=1;  //high
                       
                    }
                  }
                  else if(NowLevel==1){
                    AddNewRow();
                    NowLevel=2;  //low
                     
                  }
                  else if(NowLevel==2){
                    AddNewRow();
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
                      AddNewRow();
                      NowLevel=1;  //high
                       
                    }
                  }
                  else if(NowLevel==1){
                    AddNewRow();
                    NowLevel=2;  //low
                     
                  }
                  else if(NowLevel==2){
                    AddNewRow();
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
                      AddNewRow();
                      NowBend=true;  //bend
                       
                    }
                  }
                  else if(NowBend==true){
                    AddNewRow();
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
                      AddNewRow();
                      NowBend=true;  //bend
                       
                    }
                  }
                  else if(NowBend==true){
                    AddNewRow();
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
                      AddNewRow();
                      NowBend=true;  //bend
                       
                    }
                  }
                  else if(NowBend==true){
                    AddNewRow();
                    NowBend=false;  //s
                    TransFlg = true;
                    NowStudyStage=0;
                    if(NowFinger<NUM_OF_FINGERS-1){
                      NowFinger++;
                    }
                    else{
                      NowFinger=0;
                      
                      if(NowCol1<NUM_OF_HAND_COLS-1){
                        NowCol1++;
                        NowCol2=NowCol1;

                        if(NowCol1==floor((NUM_OF_HAND_COLS)/2)){
                            NowCol3=0;
                            NowCol4=NowCol3;
                        }
                        else if(NowCol1>floor((NUM_OF_HAND_COLS)/2)){
                            NowCol3++;
                            NowCol4=NowCol3;
                        }
                        else{
                            NowCol3--;
                            NowCol4=NowCol3;
                        }
                        
                      }
                      else{
                        NowMainStage=3;
                        saveTable(table, "StudyData/User"+StudyID+".csv");
                      }
                      
                    }
                  }
                }
            }
            loadWhichImage();
   }
   public void loadWhichImage(){
    
     if(TransFlg){
        // switch (NowFinger) {
        //          case 0:
        //            img = loadImage("Photo/IMG_0086.JPG");
        //             break;
        //          case 1:
        //            img = loadImage("Photo/IMG_0092.JPG");
        //             break;
        //          case 2:
        //            img = loadImage("Photo/IMG_0098.JPG");
        //             break;
        //          case 3:
        //            img = loadImage("Photo/IMG_0104.JPG");
        //             break;
        //          case 4:
        //            img = loadImage("Photo/IMG_0110.JPG");
        //             break;
        // }
        imgIndex = 30;
     }
     else{
       
          if(NowStudyStage == 1){
            if(NowLevel==0){
              switch (NowFinger) {
                 case 0:
                   imgIndex = 0;
                    break;
                 case 1:
                   imgIndex = 6;
                    break;
                 case 2:
                   imgIndex = 12;
                    break;
                 case 3:
                   imgIndex = 18;
                    break;
                 case 4:
                   imgIndex = 24;
                    break;
              }
              
            }
            else if(NowLevel==1){
              switch (NowFinger) {
                 case 0:
                   imgIndex = 1;
                    break;
                 case 1:
                   imgIndex = 7;
                    break;
                 case 2:
                   imgIndex = 13;
                    break;
                 case 3:
                   imgIndex = 19;
                    break;
                 case 4:
                   imgIndex = 29;
                    break;
              }
               
            }
            else{
              switch (NowFinger) {
                 case 0:
                   imgIndex = 2;
                    break;
                 case 1:
                   imgIndex = 8;
                    break;
                 case 2:
                   imgIndex = 14;
                    break;
                 case 3:
                   imgIndex = 20;
                    break;
                 case 4:
                   imgIndex = 25;
                    break;
              }
               
            }
          }
          else if(NowStudyStage == 2){
            if(NowLevel==0){
              switch (NowFinger) {
                 case 0:
                   imgIndex = 3;
                    break;
                 case 1:
                   imgIndex = 9;
                    break;
                 case 2:
                   imgIndex = 15;
                    break;
                 case 3:
                   imgIndex = 21;
                    break;
                 case 4:
                   imgIndex = 26;
                    break;
              }
              
            }
            else if(NowLevel==1){
              switch (NowFinger) {
                 case 0:
                   imgIndex = 4;
                    break;
                 case 1:
                   imgIndex = 10;
                    break;
                 case 2:
                   imgIndex = 16;
                    break;
                 case 3:
                   imgIndex = 22;
                    break;
                 case 4:
                   imgIndex = 27;
                    break;
              }
               
            }
            else{
              switch (NowFinger) {
                 case 0:
                   imgIndex = 5;
                    break;
                 case 1:
                   imgIndex = 11;
                    break;
                 case 2:
                   imgIndex = 17;
                    break;
                 case 3:
                   imgIndex = 23;
                    break;
                 case 4:
                   imgIndex = 28;
                    break;
              }
               
            }
          }
          else if(NowStudyStage == 3){
              if(NowBend==true){
                switch (NowFinger) {
                 case 0:
                   imgIndex = 4;
                    break;
                 case 1:
                   imgIndex = 10;
                    break;
                 case 2:
                   imgIndex = 16;
                    break;
                 case 3:
                   imgIndex = 22;
                    break;
                 case 4:
                   imgIndex = 27;
                    break;
                }
                
              }
              else{
                switch (NowFinger) {
                 case 0:
                   imgIndex = 1;
                    break;
                 case 1:
                   imgIndex = 7;
                    break;
                 case 2:
                   imgIndex = 13;
                    break;
                 case 3:
                   imgIndex = 19;
                    break;
                 case 4:
                   imgIndex = 29;
                    break;
                }
                
              }
          }
          else if(NowStudyStage == 4){
              if(NowBend==true){
                switch (NowFinger) {
                 case 0:
                   imgIndex = 3;
                    break;
                 case 1:
                   imgIndex = 9;
                    break;
                 case 2:
                   imgIndex = 15;
                    break;
                 case 3:
                   imgIndex = 21;
                    break;
                 case 4:
                   imgIndex = 26;
                    break;
                }
                
              }
              else{
                switch (NowFinger) {
                 case 0:
                   imgIndex = 0;
                    break;
                 case 1:
                   imgIndex = 6;
                    break;
                 case 2:
                   imgIndex = 12;
                    break;
                 case 3:
                   imgIndex = 18;
                    break;
                 case 4:
                   imgIndex = 24;
                    break;
                }
                
              }
          }
          else if(NowStudyStage == 5){
              if(NowBend==true){
                switch (NowFinger) {
                 case 0:
                   imgIndex = 5;
                    break;
                 case 1:
                   imgIndex = 11;
                    break;
                 case 2:
                   imgIndex = 17;
                    break;
                 case 3:
                   imgIndex = 23;
                    break;
                 case 4:
                   imgIndex = 28;
                    break;
                }
                
              }
              else{
                switch (NowFinger) {
                 case 0:
                   imgIndex = 2;
                    break;
                 case 1:
                   imgIndex = 8;
                    break;
                 case 2:
                   imgIndex = 14;
                    break;
                 case 3:
                   imgIndex = 20;
                    break;
                 case 4:
                   imgIndex = 25;
                    break;
                }
                
              }
          }
       

     }
    
   }
   public void showSGPos(){
     final int SG_dist = 30;
     final int SG_X = 350;
     final int SG_Y = 130;
     
     for(int i=0; i<NUM_OF_HAND_COLS ; i++){
       for(int j=0; j<NUM_OF_HAND_ROWS ; j++){
          
           if(NowRow1==j && NowCol1==i){
              fill(255,0,0);
              ellipse(SG_X+SG_dist*i, SG_Y+SG_dist*j, 20, 20);
           }
           else if(NowRow2==j && NowCol2==i){
              fill(255,255,0);
              ellipse(SG_X+SG_dist*i, SG_Y+SG_dist*j, 20, 20);
           }
           else if(NowRow3==j && NowCol3==i){
              fill(0,0,255);
              ellipse(SG_X+SG_dist*i, SG_Y+SG_dist*j, 20, 20);
           }
           else if(NowRow4==j && NowCol4==i){
              fill(0,255,255);
              ellipse(SG_X+SG_dist*i, SG_Y+SG_dist*j, 20, 20);
           }
           else{
              fill(0,0,0);
              ellipse(SG_X+SG_dist*i, SG_Y+SG_dist*j, 5, 5);
           }
          
       }
     }
   
   }
   public void showImage(){
      if(NowStudyStage>0){
        image(imgArray[imgIndex], imgWidth, imgHeight, width/2 , height );
      }
   }
  public void nextStepView(){
            if(NowMainStage==5){
                if(NowStudyStage==0){
                  NowStudyStage=1;
                  NowLevel=0;      //mid
                  NowBend=false;     //s
                   
                }
                else if(NowStudyStage==1){
                  if(NowLevel==0){   
                      // AddNewRow();         
                      NowLevel=1;  //high            
                  }
                  else if(NowLevel==1){
                    // AddNewRow();
                    NowLevel=2;  //low          
                  }
                  else if(NowLevel==2){
                    // AddNewRow();
                    NowLevel=0;  //mid
                    NowStudyStage=2;
                    NowBend=true;     //b          
                  }
                }
                else if(NowStudyStage==2){
                  if(NowLevel==0){
                      // AddNewRow();
                      NowLevel=1;  //high
                  }
                  else if(NowLevel==1){
                    // AddNewRow();
                    NowLevel=2;  //low
                     
                  }
                  else if(NowLevel==2){
                    // AddNewRow();
                    NowLevel=1;  //high
                    NowStudyStage=3;  
                    NowBend=false;     //s
                    
                  }
                }
                else if(NowStudyStage==3){
                  if(NowBend==false){
                      // AddNewRow();
                      NowBend=true;  //bend
                       
                  }
                  else if(NowBend==true){
                    // AddNewRow();
                    NowBend=false;  //s
                    NowLevel=0;  //mid
                    NowStudyStage=4;
                    NowBend=false;     //s
                    
                  }
                  
                }
                else if(NowStudyStage==4){
                  if(NowBend==false){
                    // AddNewRow();
                      NowBend=true;  //bend
                 
                  }
                  else if(NowBend==true){
                    // AddNewRow();
                    NowBend=false;  //s
                    NowLevel=2;  //low
                    NowStudyStage=5;
                    NowBend=false;     //s
                   
                  }
                }
                else if(NowStudyStage==5){
                  if(NowBend==false){
                    
                      // AddNewRow();
                      NowBend=true;  //bend
                       
                    
                  }
                  else if(NowBend==true){
                    // AddNewRow();
                    NowBend=false;  //s
                    NowStudyStage=0;
                    if(NowFinger<NUM_OF_FINGERS-1){
                      NowFinger++;
                    }
                    else{
                       NowMainStage=6;               
                    }
                  }
                }
            }
            loadWhichImage();
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
    strBuffer.append(NowFinger);
    strBuffer.append("_");
    strBuffer.append(NowLevel);
    strBuffer.append("_");
    strBuffer.append(NowBend);
    strBuffer.append("_");
    strBuffer.append(NowCol1);
    strBuffer.append("_");
    strBuffer.append(NowRow1);
    strBuffer.append("_");
    strBuffer.append(0);
    return strBuffer.toString();
  }

  @Override
  public void updateReceiveRecordSignal(){
    performKeyPress(' ');
    mainClass.expImgManager.captureImage(getImageFileName());
  }

}

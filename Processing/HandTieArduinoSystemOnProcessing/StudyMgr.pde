public class StudyMgr {
  
   HandTieArduinoSystemOnProcessing mainClass;
   public final static int NUM_OF_FINGERS = 5;
   public final static int NUM_OF_HAND_ROWS = 4;
   public final static int NUM_OF_HAND_COLS = 5;
   public final static int NUM_OF_Degree = 3;
   
   public final static int ShowGauge_x = 630;
   public final static int ShowGauge_y = 400;

   public final static int ShowGauge_x2_dist = 140;
   public final static int ShowGauge_y2_dist = 0;   
   
   public final static int ShowGauge_dist = 25;
   
   public final static String StudyID = "0";
   
   public String ShowText = "Study #1";
   public int NowMainStage = 1;
   public int NowStudyStage = 0;
   
   public int NowDegree = 0;      //3
   public int NowCol1 = 0;         //5
   public int NowRow1 = 0;          //6  =90
   public int NowFinger = 0;      //5
   public int NowLevel = 0;      //0: mid 1:high 2:low
   public boolean NowBend = false; 

   public int NowCol2 = NUM_OF_HAND_COLS-NowCol1-1;         
   public int NowRow2 = NUM_OF_HAND_ROWS-NowRow1-1;          
   
   public boolean TransFlg = false; 

   public boolean loadTableFlg = false; 
   
   // public int RowCount;

   Table table;
   
   public StudyMgr (HandTieArduinoSystemOnProcessing mainClass) {
      this.mainClass = mainClass;
      
      // RowCount = 0;
      
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
            text("Degree: "+ ((NowDegree==0)?"0":((NowDegree==1)?"45":"90"))+"\nCol1: "+NowCol1+", Row1: "+NowRow1+"\nFinger: "+NowFinger+"\nLevel: "+((NowLevel==0)?"Mid":((NowLevel==1)?"High":"Low"))+"\nBend: "+((NowBend==false)?"Straight":"Bend"), 10, 30);
            text("Col2: "+NowCol2+" Row2: "+NowRow2, width-140, 60);
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
                   fill(getHeatmapRGB(mainClass.sgManager.getOneElongationValsOfGauges(i*2+j)));
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

                   fill(getHeatmapRGB(mainClass.sgManager.getOneElongationValsOfGauges(8+i*2+j)));
                   pushMatrix();
                   if(NowDegree==0){
                     translate(ShowGauge_x+ShowGauge_x2_dist, ShowGauge_y+ShowGauge_y2_dist);
                   }
                   else if(NowDegree==1){
                     translate(ShowGauge_x+ShowGauge_x2_dist-30,ShowGauge_y+ShowGauge_y2_dist+80);
                   }
                   else if(NowDegree==2){
                     translate(ShowGauge_x+ShowGauge_x2_dist,ShowGauge_y+ShowGauge_y2_dist+160);
                   }
                   rotate(radians(-45*NowDegree));
                     rect( ShowGauge_dist*2*j, ShowGauge_dist*i,ShowGauge_dist*2,ShowGauge_dist);
                   popMatrix();
                }
             } 
           break;
         case 3:
             textSize(40);
            fill(0, 0, 0);
            text("Done", width*0.39, height*0.45); 
          break;
     }
//     for(int k=0; k < 3; k++ ){
       
//     }
   }
   public color getHeatmapRGB(float value){
     float minimum=0.5;
     float maximum=1.5;
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
            NewTable(); 
            NowMainStage=2;
            NowStudyStage=0;
            NowDegree = 0;      //3
            NowCol1 = 0;         //5
            NowRow1 = 0; 
            NowLevel=0;      //mid
            NowBend=false;     //s
            TransFlg=false;

            NowCol2 = NUM_OF_HAND_COLS-NowCol1-1;         
            NowRow2 = NUM_OF_HAND_ROWS-NowRow1-1;    

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
            NowDegree = table.getInt(lastRow,"Degree");
            NowCol1 = table.getInt(lastRow,"Cols1");        
            NowRow1 = table.getInt(lastRow,"Rows1"); 
            NowCol2 = table.getInt(lastRow,"Cols2");        
            NowRow2 = table.getInt(lastRow,"Rows2"); 
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
            nextStep();
          break;
      }
   }
   public void AddNewRow(){
    if(loadTableFlg){
        loadTableFlg=false;
    }
    else{
      TableRow tmpNewRow = table.addRow();

      tmpNewRow.setString("Degree",str(NowDegree));
      tmpNewRow.setString("Cols1", str(NowCol1));
      tmpNewRow.setString("Rows1", str(NowRow1));
      tmpNewRow.setString("Finger", str(NowFinger));
      tmpNewRow.setString("Stage", str(NowStudyStage));
      tmpNewRow.setString("Level", str(NowLevel));
      tmpNewRow.setString("Bend", str(NowBend));
      tmpNewRow.setString("SG1_0",str(mainClass.sgManager.getOneElongationValsOfGauges(0)));
      tmpNewRow.setString("SG1_1",str(mainClass.sgManager.getOneElongationValsOfGauges(1)));
      tmpNewRow.setString("SG1_2",str(mainClass.sgManager.getOneElongationValsOfGauges(2)));
      tmpNewRow.setString("SG1_3",str(mainClass.sgManager.getOneElongationValsOfGauges(3)));
      tmpNewRow.setString("SG1_4",str(mainClass.sgManager.getOneElongationValsOfGauges(4)));
      tmpNewRow.setString("SG1_5",str(mainClass.sgManager.getOneElongationValsOfGauges(5)));
      tmpNewRow.setString("SG1_6",str(mainClass.sgManager.getOneElongationValsOfGauges(6)));
      tmpNewRow.setString("SG1_7",str(mainClass.sgManager.getOneElongationValsOfGauges(7)));     
      tmpNewRow.setString("Cols2", str(NowCol2));
      tmpNewRow.setString("Rows2", str(NowRow2));
      tmpNewRow.setString("SG2_0",str(mainClass.sgManager.getOneElongationValsOfGauges(8)));
      tmpNewRow.setString("SG2_1",str(mainClass.sgManager.getOneElongationValsOfGauges(9)));
      tmpNewRow.setString("SG2_2",str(mainClass.sgManager.getOneElongationValsOfGauges(10)));
      tmpNewRow.setString("SG2_3",str(mainClass.sgManager.getOneElongationValsOfGauges(11)));
      tmpNewRow.setString("SG2_4",str(mainClass.sgManager.getOneElongationValsOfGauges(12)));
      tmpNewRow.setString("SG2_5",str(mainClass.sgManager.getOneElongationValsOfGauges(13)));
      tmpNewRow.setString("SG2_6",str(mainClass.sgManager.getOneElongationValsOfGauges(14)));
      tmpNewRow.setString("SG2_7",str(mainClass.sgManager.getOneElongationValsOfGauges(15))); 
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
      
      table.addColumn("Degree");
      table.addColumn("Cols1");
      table.addColumn("Rows1");
      table.addColumn("Finger");
      table.addColumn("Stage");
      table.addColumn("Level");
      table.addColumn("Bend");
      table.addColumn("SG1_0");
      table.addColumn("SG1_1");
      table.addColumn("SG1_2");
      table.addColumn("SG1_3");
      table.addColumn("SG1_4");
      table.addColumn("SG1_5");
      table.addColumn("SG1_6");
      table.addColumn("SG1_7");
      table.addColumn("Cols2");
      table.addColumn("Rows2");
      table.addColumn("SG2_0");
      table.addColumn("SG2_1");
      table.addColumn("SG2_2");
      table.addColumn("SG2_3");
      table.addColumn("SG2_4");
      table.addColumn("SG2_5");
      table.addColumn("SG2_6");
      table.addColumn("SG2_7");

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
                        NowStudyStage=0;

                        if(NowFinger>1){
                          NowFinger--;
                        }
                        else{
                          NowFinger=NUM_OF_FINGERS-1;
                          
                          if(NowRow1>1){
                            NowRow1--;
                          }
                          else{
                            NowRow1=NUM_OF_HAND_ROWS-1;
                            if(NowCol1>1){
                              NowCol1--;
                            }
                            else{
                              NowCol1=NUM_OF_HAND_COLS-1;
                              if(NowDegree>1){
                                NowDegree--;
                              }
                              else{
                                NowMainStage=NUM_OF_Degree-1;
                                
                              }
                            }
                          }
                        }

                    }

                }

            }
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
                      
                      if(NowRow1<NUM_OF_HAND_ROWS-1){
                        NowRow1++;
                        NowRow2--;
                      }
                      else{
                        NowRow1=0;
                        NowRow2=NUM_OF_HAND_ROWS-1-NowRow1;
                        if(NowCol1< ceil((float)(NUM_OF_HAND_COLS)/2)){
                          NowCol1++;
                          NowCol2--;
                          // if(NowCol1== floor((float)(NUM_OF_HAND_COLS)/2)){

                          // }
                        }
                        else{
                          NowCol1=0;
                          NowCol2=NUM_OF_HAND_COLS-1-NowCol1;
                          if(NowDegree<NUM_OF_Degree-1){
                            NowDegree++;
                          }
                          else{
                            NowMainStage=3;
                            saveTable(table, "StudyData/User"+StudyID+".csv");
                          }
                        }
                      }
                    }
                  }
                }
            }

   }

   // public void performMousePress(){

   // }

}

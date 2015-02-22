import controlP5.*;
public final static int NUM_OF_FINGERS = 5;
public final static int NUM_OF_SG_ROWS = 4;
public final static int NUM_OF_SG_COLS = 2;

public final static int NUM_OF_HAND_ROWS = 4;
public final static int NUM_OF_HAND_COLS = 5;
// public final static int NUM_OF_Degree = 3;
 
public final static int ShowGauge_x = 350;
public final static int ShowGauge_y = 220;

public final static int ShowGauge_dist_x = 40;
public final static int ShowGauge_dist_y = 20;

public final static int ShowGaugeGroup_dist = 4;

public final static int ButtonPosX = 10;
public final static int ButtonPosY = 250;

public final static int UserNum = 1;
public int UserStartFrom = 0;

Table[] tableArray = new Table[UserNum];

 // public int NowDegree = 0;      //3
 public int NowCol = 0;         //5
 public int NowRow = 0;          //6  =90
 public int NowFinger = 0;      //5
 public int NowLevel = 0;      //0: mid 1:high 2:low
 public boolean NowBend = false; 
 public int ShowingType = 0;
 public int InterpolateType =0;  //0:origin , 1:bilinear

 // public boolean assignSGcolorArrayFlg = false; 
 public boolean showPointFlg = false;
 public float[][][][][][] SGcolorArray = new float[2][NUM_OF_FINGERS][3][2][NUM_OF_HAND_COLS*NUM_OF_SG_COLS][NUM_OF_HAND_ROWS*NUM_OF_SG_ROWS];
 public float [][][][][][] interArray = new float[2][NUM_OF_FINGERS][3][2][ShowGauge_dist_x*(NUM_OF_SG_COLS*(NUM_OF_HAND_COLS)-1)][ShowGauge_dist_y*(NUM_OF_SG_ROWS*(NUM_OF_HAND_ROWS)-1)];
ControlP5 cp5;
RadioButton r1, r2, r3, r4, r5;

void setup() {
  size(800, 600);
  
  cp5 = new ControlP5(this);
  
  r1 = cp5.addRadioButton("Finger")
     .setPosition(350,30)
     .setSize(50,150)
     .setColorForeground(color(251,220,201))
     .setColorBackground(color(247,187,141))
     .setColorActive(color(186,115,34))
     .setColorLabel(color(0))
     .setItemsPerRow(5)
     .setSpacingColumn(40)
     .addItem("Finger_0",1)
     .addItem("Finger_1",2)
     .addItem("Finger_2",3)
     .addItem("Finger_3",4)
     .addItem("Finger_4",5)
     ;
     
     for(Toggle t:r1.getItems()) {
       t.captionLabel().style().moveMargin(-90,0,0,-60);
       t.captionLabel().style().movePadding(6,-10,25,10);
       t.captionLabel().setSize(16);
       t.captionLabel().style().backgroundWidth = 45;
       t.captionLabel().style().backgroundHeight = 13;
     }
     
  
  
  r2 = cp5.addRadioButton("Level")
     .setPosition(ButtonPosX,ButtonPosY)
     .setSize(60,40)
     .setColorForeground(color(120))
     .setColorBackground(color(100,100,100))
     .setColorActive(color(255))
     .setColorLabel(color(0))
     .setItemsPerRow(5)
     .setSpacingColumn(40)
     .addItem("Mid",1)
     .addItem("High",2)
     .addItem("Low",3)
     ;
     
     for(Toggle t:r2.getItems()) {
       t.captionLabel().setSize(16);
       t.captionLabel().style().backgroundWidth = 45;
       t.captionLabel().style().backgroundHeight = 13;
     }
     
   r3 = cp5.addRadioButton("BendStraight")
     .setPosition(ButtonPosX,ButtonPosY+80)
     .setSize(60,40)
     .setColorForeground(color(120))
     .setColorBackground(color(100,100,100))
     .setColorActive(color(255))
     .setColorLabel(color(0))
     .setItemsPerRow(5)
     .setSpacingColumn(100)
     .addItem("Bend",1)
     .addItem("Straight",2)
     ;  
     
     for(Toggle t:r3.getItems()) {
       t.captionLabel().setSize(16);
       t.captionLabel().style().backgroundWidth = 45;
       t.captionLabel().style().backgroundHeight = 13;
     }
   r4 = cp5.addRadioButton("ShowData")
     .setPosition(ButtonPosX,ButtonPosY+200)
     .setSize(60,40)
     .setColorForeground(color(120))
     .setColorBackground(color(100,100,100))
     .setColorActive(color(255))
     .setColorLabel(color(0))
     .setItemsPerRow(5)
     .setSpacingColumn(100)
     .addItem("Raw",1)
     .addItem("Sub",2)
     ; 
     
     for(Toggle t:r4.getItems()) {
       t.captionLabel().setSize(16);
       t.captionLabel().style().backgroundWidth = 45;
       t.captionLabel().style().backgroundHeight = 13;
     }
   r5 = cp5.addRadioButton("interpolation")
     .setPosition(ButtonPosX,50)
     .setSize(60,40)
     .setColorForeground(color(120))
     .setColorBackground(color(100,100,100))
     .setColorActive(color(255))
     .setColorLabel(color(0))
     .setItemsPerRow(5)
     .setSpacingColumn(100)
     .addItem("Origin",1)
     .addItem("Bilinear",2)
     ; 
     
     for(Toggle t:r5.getItems()) {
       t.captionLabel().setSize(16);
       t.captionLabel().style().backgroundWidth = 45;
       t.captionLabel().style().backgroundHeight = 13;
     }
     
   r1.activate(0);
   r2.activate(0);
   r3.activate(0);
   r4.activate(1);
   r5.activate(0);
   
   for(int i = UserStartFrom; i < UserNum; i++){
     tableArray[i]=loadTable("StudyData/User"+i+".csv","header");
   }

   float interX, interY;
    for(int s=0; s<2;s++){
      for(int f=0; f<NUM_OF_FINGERS; f++){
         for(int l=0; l<3; l++){
            for(int b=0; b<2; b++){
                for(int i =0; i < NUM_OF_HAND_ROWS*NUM_OF_SG_ROWS; i++){
                  for(int j=0; j < NUM_OF_HAND_COLS*NUM_OF_SG_COLS; j++){
                      if((i%NUM_OF_SG_ROWS%2==0 && j%NUM_OF_SG_COLS%2==0) || (i%NUM_OF_SG_ROWS%2==1 && j%NUM_OF_SG_COLS%2==1)){
                        SGcolorArray[s][f][l][b][j][i] = calSGValue(s,floor((float)j/NUM_OF_SG_COLS),floor((float)i/NUM_OF_SG_ROWS),f,l,b,floor(((i%NUM_OF_SG_ROWS)*2+(j%NUM_OF_SG_COLS))/2));
                      }
                  }
                }
                for(int i =0; i < NUM_OF_HAND_ROWS*NUM_OF_SG_ROWS; i++){
                  for(int j=0; j < NUM_OF_HAND_COLS*NUM_OF_SG_COLS; j++){
                      if((i%NUM_OF_SG_ROWS%2!=0 || j%NUM_OF_SG_COLS%2!=0) && (i%NUM_OF_SG_ROWS%2!=1 || j%NUM_OF_SG_COLS%2!=1)){
          
                        if(j>0 && j<NUM_OF_HAND_COLS*NUM_OF_SG_COLS-1){
                          interX = lerp(SGcolorArray[s][f][l][b][j-1][i], SGcolorArray[s][f][l][b][j+1][i], .5); 
                        }
                        else if(j==NUM_OF_HAND_COLS*NUM_OF_SG_COLS-1){
                          interX = SGcolorArray[s][f][l][b][j-1][i]; 
                        }
                        else{
                          interX = SGcolorArray[s][f][l][b][j+1][i]; 
                        }
                        if(i>0 && i<NUM_OF_HAND_ROWS*NUM_OF_SG_ROWS-1){
                          interY = lerp(SGcolorArray[s][f][l][b][j][i-1], SGcolorArray[s][f][l][b][j][i+1], .5); 
                        }
                        else if(i==NUM_OF_HAND_ROWS*NUM_OF_SG_ROWS-1){
                          interY = SGcolorArray[s][f][l][b][j][i-1]; 
                        }
                        else{
                          interY = SGcolorArray[s][f][l][b][j][i+1]; 
                        }
                        SGcolorArray[s][f][l][b][j][i] = lerp(interX, interY, .5); 
                      }
                  }
                }
            }
         }
      }
    }
    float interX1,interX2;

    for(int s=0; s<2;s++){
      for(int f=0; f<NUM_OF_FINGERS; f++){
         for(int l=0; l<3; l++){
            for(int b=0; b<2; b++){
                    for(int i =0; i < ShowGauge_dist_y*(NUM_OF_SG_ROWS*(NUM_OF_HAND_ROWS)-1); i++){
                      for(int j=0 ; j < ShowGauge_dist_x*(NUM_OF_SG_COLS*(NUM_OF_HAND_COLS)-1); j++){
                        // if(i%ShowGauge_dist_y==0 && j%ShowGauge_dist_x==0){
                          interX1 = lerp(SGcolorArray[s][f][l][b][floor((float)j/ShowGauge_dist_x)][floor((float)i/ShowGauge_dist_y)],SGcolorArray[s][f][l][b][floor((float)j/ShowGauge_dist_x)+1][floor((float)i/ShowGauge_dist_y)],(float)(j-ShowGauge_dist_x*floor((float)j/ShowGauge_dist_x))/ShowGauge_dist_x);
                          interX2 = lerp(SGcolorArray[s][f][l][b][floor((float)j/ShowGauge_dist_x)][floor((float)i/ShowGauge_dist_y)+1],SGcolorArray[s][f][l][b][floor((float)j/ShowGauge_dist_x)+1][floor((float)i/ShowGauge_dist_y)+1],(float)(j-ShowGauge_dist_x*floor((float)j/ShowGauge_dist_x))/ShowGauge_dist_x);
                          
                          interArray[s][f][l][b][j][i] = lerp(interX1,interX2,(float)(i-ShowGauge_dist_y*floor((float)i/ShowGauge_dist_y))/ShowGauge_dist_y);
                      }
                    }     

            }
          }
      }
    }

}

void draw() { 
  background(243,243,240); 
  if(InterpolateType==1){
      
      
      //draw every pixel
      // float interX1,interX2,interY;
      noStroke();
      for(int i =0; i < ShowGauge_dist_y*(NUM_OF_SG_ROWS*(NUM_OF_HAND_ROWS)-1); i++){
        for(int j=0 ; j < ShowGauge_dist_x*(NUM_OF_SG_COLS*(NUM_OF_HAND_COLS)-1); j++){
          // if(i%ShowGauge_dist_y==0 && j%ShowGauge_dist_x==0){
            stroke((ShowingType==0)?getHeatmapRGB(interArray[ShowingType][NowFinger][NowLevel][NowBend==true?1:0][j][i]):getSubRGB(interArray[ShowingType][NowFinger][NowLevel][NowBend==true?1:0][j][i]));
            // fill(lerpColor(interX1,interX2,(float)(i-ShowGauge_dist_y*floor((float)i/ShowGauge_dist_y))/ShowGauge_dist_y));
            // fill(interX1);
            point(ShowGauge_x+ShowGauge_dist_x/2+j,ShowGauge_y+ShowGauge_dist_y/2+i);
          // }
        }
      }
      // draw border
      noFill();
      stroke(color(0));
      for(int i =0; i < NUM_OF_HAND_ROWS; i++){
        for(int j=0; j < NUM_OF_HAND_COLS; j++){
            rect(ShowGauge_x+ShowGauge_dist_x*NUM_OF_SG_COLS*j,ShowGauge_y+ShowGauge_dist_y*NUM_OF_SG_ROWS*i,ShowGauge_dist_x*NUM_OF_SG_COLS,ShowGauge_dist_y*NUM_OF_SG_ROWS);
            ellipse(ShowGauge_x+ShowGauge_dist_x*(1+NUM_OF_SG_COLS*j),ShowGauge_y+ShowGauge_dist_y*(2+NUM_OF_SG_ROWS*i), 2, 2);
        }
      }
      if(showPointFlg){
          for(int i =0; i < NUM_OF_SG_ROWS*(NUM_OF_HAND_ROWS); i++){
            for(int j=0 ; j < NUM_OF_SG_COLS*(NUM_OF_HAND_COLS); j++){
              
                  ellipse(ShowGauge_x+ShowGauge_dist_x/2+ShowGauge_dist_x*j,ShowGauge_y+ShowGauge_dist_y/2+ShowGauge_dist_y*i, 3, 3);
              
            }
          }
      }

  }
  else{
    stroke(color(0));
      for(int i =0; i < NUM_OF_HAND_ROWS; i++){
        for(int j=0; j < NUM_OF_HAND_COLS; j++){
              //c0_r0  ->0
              fill((ShowingType==0)?getHeatmapRGB(calSGValue(ShowingType, j,i,NowFinger,NowLevel,NowBend==true?1:0,0)):getSubRGB(calSGValue(ShowingType, j,i,NowFinger,NowLevel,NowBend==true?1:0,0)));
              rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_x*NUM_OF_SG_COLS*j,ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_y*NUM_OF_SG_ROWS*i,ShowGauge_dist_x,ShowGauge_dist_y, 5);
              //c1_r0  ->1
              // fill(color(255));
              // rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_x*(1+NUM_OF_SG_COLS*j),ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_y*NUM_OF_SG_ROWS*i,ShowGauge_dist_x,ShowGauge_dist_y, 5);
              //c0_r1  ->2
              // fill(color(255));
              // rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_x*NUM_OF_SG_COLS*j,ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_y*(1+NUM_OF_SG_ROWS*i),ShowGauge_dist_x,ShowGauge_dist_y, 5);
              //c1_r1  ->3
              fill((ShowingType==0)?getHeatmapRGB(calSGValue(ShowingType, j,i,NowFinger,NowLevel,NowBend==true?1:0,1)):getSubRGB(calSGValue(ShowingType, j,i,NowFinger,NowLevel,NowBend==true?1:0,1)));
              rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_x*(1+NUM_OF_SG_COLS*j),ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_y*(1+NUM_OF_SG_ROWS*i),ShowGauge_dist_x,ShowGauge_dist_y, 5);
              //c0_r2  ->4
              fill((ShowingType==0)?getHeatmapRGB(calSGValue(ShowingType, j,i,NowFinger,NowLevel,NowBend==true?1:0,2)):getSubRGB(calSGValue(ShowingType, j,i,NowFinger,NowLevel,NowBend==true?1:0,2)));
              rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_x*NUM_OF_SG_COLS*j,ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_y*(2+NUM_OF_SG_ROWS*i),ShowGauge_dist_x,ShowGauge_dist_y, 5);
              //c1_r2  ->5
              // fill(color(255));
              // rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_x*(1+NUM_OF_SG_COLS*j),ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_y*(2+NUM_OF_SG_ROWS*i),ShowGauge_dist_x,ShowGauge_dist_y, 5);
              // //c0_r3  ->6
              // fill(color(255));
              // rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_x*NUM_OF_SG_COLS*j,ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_y*(3+NUM_OF_SG_ROWS*i),ShowGauge_dist_x,ShowGauge_dist_y, 5);
              //c1_r3  ->7
              fill((ShowingType==0)?getHeatmapRGB(calSGValue(ShowingType, j,i,NowFinger,NowLevel,NowBend==true?1:0,3)):getSubRGB(calSGValue(ShowingType, j,i,NowFinger,NowLevel,NowBend==true?1:0,3))); 
              rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_x*(1+NUM_OF_SG_COLS*j),ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_y*(3+NUM_OF_SG_ROWS*i),ShowGauge_dist_x,ShowGauge_dist_y, 5);
            
        }
      }
  }
}

void keyPressed() {
  switch(key){
    case 'p':
      showPointFlg=!showPointFlg;
      break;

    case '9':
      r5.activate(0);
      break;
    case '0':
      r5.activate(1);
      break;

    case '1':
      r1.activate(0);
      break;
    case '2':
      r1.activate(1);
      break;
    case '3':
      r1.activate(2);
      break;
    case '4':
      r1.activate(3);
      break;
    case '5':
      r1.activate(4);
      break;
      
    case 'q':
      r2.activate(0);
      break;
    case 'w':
      r2.activate(1);
      break;
    case 'e':
      r2.activate(2);
      break;

    case 'a':
      r3.activate(0);
      break;
    case 's':
      r3.activate(1);
      break;

    case 'z':
      r4.activate(0);
      break;
    case 'x':
      r4.activate(1);
      break;
  }
}

public void controlEvent(ControlEvent theEvent) {
  if(theEvent.isFrom(r1)) {
    NowFinger = (int)theEvent.getValue()-1;
    println("NowFinger="+NowFinger);
  }
  if(theEvent.isFrom(r2)) {
    NowLevel = (int)theEvent.getValue()-1;
    println("NowLevel="+NowLevel);
  }
  if(theEvent.isFrom(r3)) {
    NowBend = (boolean)((theEvent.getValue()-1)<1)?true:false;
    println("NowBend="+NowBend);
  }
  if(theEvent.isFrom(r4)) {
    ShowingType = (int)theEvent.getValue()-1;
    println("ShowingType="+ShowingType);
  }
   if(theEvent.isFrom(r5)) {
    InterpolateType = (int)theEvent.getValue()-1;
    println("InterpolateType="+InterpolateType);
  }
  // assignSGcolorArrayFlg = true;
}
void Finger(int a) {
  println("a radio Button event: "+a);
}
public float calSGValue(int showtype, int Col, int Row, int Finger, int Level, int tmpBend, int index){

  float allValue =0;
  int count =0;
  float allValue2 =0;
  int count2 =0;
  float allValue3 =0;
  int count3 =0;
    
  boolean Bend = tmpBend==0?false:true;

    if(showtype==0 ||  Level!=0){
      for(TableRow row : tableArray[0].findRows(str( Finger), "Finger")){
         
          
          if(boolean(row.getString("Bend"))== Bend && row.getInt("Level")== Level && row.getInt("Cols1")==Col && row.getInt("Rows1")==Row){
              
              allValue+=row.getFloat("SG1_"+index);
              count++;
          }
          else if(boolean(row.getString("Bend"))== Bend && row.getInt("Level")== Level && row.getInt("Cols2")==Col && row.getInt("Rows2")==Row){
               
              allValue+=row.getFloat("SG2_"+index);
              count++;
          }
          else if(boolean(row.getString("Bend"))== Bend && row.getInt("Level")== Level && row.getInt("Cols3")==Col && row.getInt("Rows3")==Row){
               
              allValue+=row.getFloat("SG3_"+index);
              count++;
          }
          else if(boolean(row.getString("Bend"))== Bend && row.getInt("Level")== Level && row.getInt("Cols4")==Col && row.getInt("Rows4")==Row){
               
              allValue+=row.getFloat("SG4_"+index);
              count++;
          }
      }
    }
    if(showtype!=0){
        if( Level==0){
          for(TableRow row : tableArray[0].findRows(str( Finger), "Finger")){
              /////////----------------------------v high
              if(boolean(row.getString("Bend"))== Bend && row.getInt("Level")==1 && row.getInt("Cols1")==Col && row.getInt("Rows1")==Row){
                  
                  allValue2+=row.getFloat("SG1_"+index);
                  count2++;
              }
              else if(boolean(row.getString("Bend"))== Bend && row.getInt("Level")==1 && row.getInt("Cols2")==Col && row.getInt("Rows2")==Row){
                   
                  allValue2+=row.getFloat("SG2_"+index);
                  count2++;
              }
              else if(boolean(row.getString("Bend"))== Bend && row.getInt("Level")==1 && row.getInt("Cols3")==Col && row.getInt("Rows3")==Row){
                  
                  allValue2+=row.getFloat("SG3_"+index);
                  count2++;
              }
              else if(boolean(row.getString("Bend"))== Bend && row.getInt("Level")==1 && row.getInt("Cols4")==Col && row.getInt("Rows4")==Row){
                   
                  allValue2+=row.getFloat("SG4_"+index);
                  count2++;
              }
              /////////----------------------------v low
              else if( boolean(row.getString("Bend"))== Bend && row.getInt("Level")==2 && row.getInt("Cols1")==Col && row.getInt("Rows1")==Row){
                  
                  allValue3+=row.getFloat("SG1_"+index);
                  count3++;
              }
              else if( boolean(row.getString("Bend"))== Bend && row.getInt("Level")==2 && row.getInt("Cols2")==Col && row.getInt("Rows2")==Row){
                   
                  allValue3+=row.getFloat("SG2_"+index);
                  count3++;
              }
              else if( boolean(row.getString("Bend"))== Bend && row.getInt("Level")==2 && row.getInt("Cols3")==Col && row.getInt("Rows3")==Row){
                  
                  allValue3+=row.getFloat("SG3_"+index);
                  count3++;
              }
              else if( boolean(row.getString("Bend"))== Bend && row.getInt("Level")==2 && row.getInt("Cols4")==Col && row.getInt("Rows4")==Row){
                   
                  allValue3+=row.getFloat("SG4_"+index);
                  count3++;
              }
          }
          
        }
        else if( Level==1){
            for(TableRow row : tableArray[0].findRows(str( Finger), "Finger")){
                if( boolean(row.getString("Bend"))== Bend && row.getInt("Level")==0 && row.getInt("Cols1")==Col && row.getInt("Rows1")==Row){
                    
                    allValue2+=row.getFloat("SG1_"+index);
                    count2++;
                }
                else if( boolean(row.getString("Bend"))== Bend && row.getInt("Level")==0 && row.getInt("Cols2")==Col && row.getInt("Rows2")==Row){
                     
                    allValue2+=row.getFloat("SG2_"+index);
                    count2++;
                }
                else if( boolean(row.getString("Bend"))== Bend && row.getInt("Level")==0 && row.getInt("Cols3")==Col && row.getInt("Rows3")==Row){
                    
                    allValue2+=row.getFloat("SG3_"+index);
                    count2++;
                }
                else if( boolean(row.getString("Bend"))== Bend && row.getInt("Level")==0 && row.getInt("Cols4")==Col && row.getInt("Rows4")==Row){
                     
                    allValue2+=row.getFloat("SG4_"+index);
                    count2++;
                }
            }
            
        }
        else if( Level==2){
            for(TableRow row : tableArray[0].findRows(str( Finger), "Finger")){
                if( boolean(row.getString("Bend"))== Bend && row.getInt("Level")==0 && row.getInt("Cols1")==Col && row.getInt("Rows1")==Row){
                    
                    allValue2+=row.getFloat("SG1_"+index);
                    count2++;
                }
                else if( boolean(row.getString("Bend"))== Bend && row.getInt("Level")==0 && row.getInt("Cols2")==Col && row.getInt("Rows2")==Row){
                     
                    allValue2+=row.getFloat("SG2_"+index);
                    count2++;
                }
                else if( boolean(row.getString("Bend"))== Bend && row.getInt("Level")==0 && row.getInt("Cols3")==Col && row.getInt("Rows3")==Row){
                    
                    allValue2+=row.getFloat("SG3_"+index);
                    count2++;
                }
                else if( boolean(row.getString("Bend"))== Bend && row.getInt("Level")==0 && row.getInt("Cols4")==Col && row.getInt("Rows4")==Row){
                     
                    allValue2+=row.getFloat("SG4_"+index);
                    count2++;
                }
            }
            
        }
    
    }
    if(showtype==0){
      return allValue/count;
    }
    else{
      if( Level==0){
        return allValue2/count2-allValue3/count3;
      }
      else if( Level==1){
        return allValue/count-allValue2/count2;
      }
      else if( Level==2){
        return allValue2/count2-allValue/count;
      }
      else{
        return allValue;
      }
    }
  
    
}
public color getHeatmapRGB(float value){
     float minimum=0.6;
     float maximum=1.4;
     float ratio = 2 * (value-minimum) / (maximum - minimum);
     
     color heatmapRGB = color((int)max(0, 255*(ratio - 1)), 255-(int)max(0, 255*(1 - ratio))-(int)max(0, 255*(ratio - 1)), (int)max(0, 255*(1 - ratio)) );
     
     return heatmapRGB;
}
public color getSubRGB(float value){
     float minimum=-0.3;
     float maximum=0.3;
     float ratio = 2 * (value-minimum) / (maximum - minimum);
     
     color heatmapRGB = color((int)max(0, 255*(ratio - 1)), 255-(int)max(0, 255*(1 - ratio))-(int)max(0, 255*(ratio - 1)), (int)max(0, 255*(1 - ratio)) );
     
     return heatmapRGB;
}



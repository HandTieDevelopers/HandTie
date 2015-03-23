import controlP5.*;

public final static int NUM_OF_GESTURE_SET = 17;

public final static int NUM_OF_HAND_ROWS = 4;
public final static int NUM_OF_SG_ROWS = 2;

public final static int NUM_OF_SG = 19;
public final static int NUM_OF_SG_FIRSTROW = 9;
public final static int NUM_OF_INTERPOLATION_TYPE = 2;
public final static int NUM_OF_TIMES = 10;

   public final static int ShowGauge_x = 450;
   public final static int ShowGauge_y = 300;

   public final static int EachSG_x = 40;
   public final static int EachSG_y = 20;   


public final static int ShowGaugeGroup_dist = 4;
public final static int ShowGauge_dist = 35;
public final static int ButtonPosX = 10;
public final static int ButtonPosY = 250;

public final static int UserNum = 10;

Table[] tableArray = new Table[UserNum];
PImage[] imgArray = new PImage[NUM_OF_GESTURE_SET];
boolean loadedImgFlg = false;

   public final static int imgWidth = 640;
   public final static int imgHeight = 50;
 // public int NowDegree = 0;      //3
 public int NowTimes = NUM_OF_TIMES;
 public int NowRow = 0;          //6  =90
 public int NowGesture = 0;        
 public int ShowingType = 0;
 public int InterpolateType =0;  //0:origin , 1:bilinear
 public int NowUser =1;
 // public boolean assignSGcolorArrayFlg = false; 
 public boolean showPointFlg = false;
 public float [][][][][][] SGcolorArray = new float[UserNum][NUM_OF_INTERPOLATION_TYPE][NUM_OF_GESTURE_SET][NUM_OF_TIMES+1][NUM_OF_HAND_ROWS][NUM_OF_SG];
 public boolean loadTimeFlg = true;
 // public color [][][][] interArray = new color[NUM_OF_INTERPOLATION_TYPE][NUM_OF_GESTURE_SET][ShowGauge_dist_x*(NUM_OF_SG_COLS*(NUM_OF_HAND_COLS)-1)][ShowGauge_dist_y*(NUM_OF_SG_ROWS*(NUM_OF_HAND_ROWS)-1)];
ControlP5 cp5;
RadioButton r1, r2 ,r4, r5, r6;

void setup() {
 size(900, 650);
   // size(480, 400);

 
  

  cp5 = new ControlP5(this);
  
  r1 = cp5.addRadioButton("Gesture")
     .setPosition(20,160)
     .setSize(50,50)
     .setColorForeground(color(251,220,201))
     .setColorBackground(color(247,187,141))
     .setColorActive(color(186,115,34))
     .setColorLabel(color(0))
     .setItemsPerRow(5)
     .setSpacingColumn(20)
     .setSpacingRow(20)
     .addItem("0",1)
     .addItem("1",2)
     .addItem("2",3)
     .addItem("3",4)
     .addItem("4",5)
     .addItem("5",6)
     .addItem("6",7)
     .addItem("7",8)
     .addItem("8",9)
     .addItem("9",10)
     .addItem("10",11)
     .addItem("11",12)
     .addItem("12",13)
     .addItem("13",14)
     .addItem("14",15)
     .addItem("15",16)
     .addItem("16",17)
//     .setImage(loadImage("GestureSet/0.jpg"))
    ;
     
     for(Toggle t:r1.getItems()) {
       t.captionLabel().style().moveMargin(-10,0,0,-10);
       t.captionLabel().style().movePadding(6,-10,25,10);
       t.captionLabel().setSize(16);
       t.captionLabel().style().backgroundWidth = 45;
       t.captionLabel().style().backgroundHeight = 13;
     }
   r2 = cp5.addRadioButton("times")
     .setPosition(width*0.44,height*0.94)
     .setSize(20,30)
     .setColorForeground(color(120))
     .setColorBackground(color(100,100,100))
     .setColorActive(color(255))
     .setColorLabel(color(0))
     .setItemsPerRow(11)
     .setSpacingColumn(25)
     .setSpacingRow(20)
     .addItem("t1",0)
     .addItem("t2",1)
     .addItem("t3",2)
     .addItem("t4",3)
     .addItem("t5",4)
     .addItem("t6",5)
     .addItem("t7",6)
     .addItem("t8",7)
     .addItem("t9",8)
     .addItem("t10",9)
     .addItem("tall",10)
     ; 
     
     for(Toggle t:r2.getItems()) {
       t.captionLabel().setSize(10);
       t.captionLabel().style().backgroundWidth = 45;
       t.captionLabel().style().backgroundHeight = 13;
     }

   r4 = cp5.addRadioButton("ShowData")
     .setPosition(ButtonPosX,100)
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

    r6 = cp5.addRadioButton("user")
     .setPosition(ButtonPosX,height*0.72)
     .setSize(40,40)
     .setColorForeground(color(120))
     .setColorBackground(color(100,100,100))
     .setColorActive(color(255))
     .setColorLabel(color(0))
     .setItemsPerRow(4)
     .setSpacingColumn(50)
     .setSpacingRow(20)
     .addItem("user1",1)
     .addItem("user2",2)
     .addItem("user3",3)
     .addItem("user4",4)
     .addItem("user5",5)
     .addItem("user6",6)
     .addItem("user7",7)
     .addItem("user8",8)
     .addItem("user9",9)
     .addItem("user10",10)
     ; 
     
     for(Toggle t:r6.getItems()) {
       t.captionLabel().setSize(10);
       t.captionLabel().style().backgroundWidth = 45;
       t.captionLabel().style().backgroundHeight = 13;
     }
     
   r1.activate(0);
   r2.activate(NUM_OF_TIMES);
   r4.activate(1);
   r5.activate(0);
   r6.activate(0);
   

   for(int i = 0; i < UserNum; i++){
     tableArray[i]=loadTable("StudyData/User"+i+".csv","header");
   }

  for(int i=0; i<NUM_OF_GESTURE_SET;i++){
    imgArray[i]=loadImage("GestureSet/"+i+".jpg");
  }
  loadedImgFlg=true;
   loadUserData();
   loadTimeFlg = false;

}

void draw() { 
  background(243,243,240); 

    if(loadedImgFlg){
    showImage();
    textSize(35);
    fill(color(200));
    if(NowGesture <= 10){

        text("Number:"+NowGesture, width*0.42, height*0.22);
    }
    else{
        switch (NowGesture) {
            case 11:
              text("Y", width*0.42, height*0.22);
              break;
            case 12:
              text("L", width*0.42, height*0.22);
              break;
            case 13:
              text("S", width*0.42, height*0.22);
              break;
            case 14:
              text("Fuxk", width*0.42, height*0.22);
              break;
            case 15:
              text("Rock", width*0.42, height*0.22);
              break;
        }
    }
  }

  if(InterpolateType==1){
      
      //draw every pixel
      float interX1,interX2,interY;

      noStroke();
      for(int y =0; y < (ShowGauge_dist*2)*NUM_OF_HAND_ROWS+EachSG_y-ShowGauge_dist; y++){
        for(int x=0; x < EachSG_x*(NUM_OF_SG-NUM_OF_SG_FIRSTROW); x++){
         
            stroke(color(250));
            
            point(ShowGauge_x-EachSG_x/2+x, ShowGauge_y+y);
     
        }
      }
      // // draw border
      // noFill();
      // stroke(color(0));
      // for(int i =0; i < NUM_OF_HAND_ROWS; i++){
      //   for(int j=0; j < NUM_OF_HAND_COLS; j++){
      //       noFill();
      //       rect(ShowGauge_x+ShowGauge_dist_x*NUM_OF_SG_COLS*j,ShowGauge_y+ShowGauge_dist_y*NUM_OF_SG_ROWS*i,ShowGauge_dist_x*NUM_OF_SG_COLS,ShowGauge_dist_y*NUM_OF_SG_ROWS);   
      //       ellipse(ShowGauge_x+ShowGauge_dist_x*(1+NUM_OF_SG_COLS*j),ShowGauge_y+ShowGauge_dist_y*(2+NUM_OF_SG_ROWS*i), 4, 4);
      //   }
      // }
      // fill(color(0));
      // if(showPointFlg){
      //     for(int i =0; i < NUM_OF_SG_ROWS*(NUM_OF_HAND_ROWS); i++){
      //       for(int j=0 ; j < NUM_OF_SG_COLS*(NUM_OF_HAND_COLS); j++){
      //             if((i%2==0 && j%2==0) || (i%2==1 && j%2==1)){
      //             ellipse(ShowGauge_x+ShowGauge_dist_x/2+ShowGauge_dist_x*j,ShowGauge_y+ShowGauge_dist_y/2+ShowGauge_dist_y*i, 3, 3);
      //             }
      //       }
      //     }
      // }

  }
  else{
    stroke(color(0));
      for(int eachRowi = 0; eachRowi < NUM_OF_HAND_ROWS; eachRowi++){
        
        for(int sgi=0; sgi<NUM_OF_SG; sgi++){

                fill((ShowingType==0)?getHeatmapRGB(SGcolorArray[NowUser-1][ShowingType][NowGesture][NowTimes][eachRowi][sgi]):getSubRGB(SGcolorArray[NowUser-1][ShowingType][NowGesture][NowTimes][eachRowi][sgi]));
              
                if(sgi<NUM_OF_SG_FIRSTROW){
                    rect(ShowGauge_x+sgi*EachSG_x,ShowGauge_y+2*eachRowi*ShowGauge_dist,EachSG_x,EachSG_y);
                }
                else{
                    rect(ShowGauge_x+(sgi-NUM_OF_SG_FIRSTROW-0.5)*EachSG_x,ShowGauge_y+(2*eachRowi+1)*ShowGauge_dist,EachSG_x,EachSG_y);

                }

        }
        
      }
      
  }
}

void keyPressed() {
  switch(key){
    case ' ':
//      saveFrame("user"+NowUser+"/"+"F"+NowFinger+"_L"+NowLevel+"_B"+((NowBend==true)?1:0)+".png");
      break;
    case 'p':
      showPointFlg=!showPointFlg;
      break;      
    case '1':
      r5.activate(0);
      break;
    case '2':
      r5.activate(1);
      break;

    case 'a':
      if(NowGesture>0){
        r1.activate(NowGesture-1);
      }
      else{
        r1.activate(NUM_OF_GESTURE_SET-1);
      }
      break;
    case 's':
      if(NowGesture < NUM_OF_GESTURE_SET-1){
        r1.activate(NowGesture+1);
      }
      else{
        r1.activate(0);
      }
      break;
     case ',':
       if(NowTimes>0){
        r2.activate(NowTimes-1);
       }
       else{
        r2.activate(NUM_OF_TIMES);
       }
      break;
    case '.':
      if(NowTimes < NUM_OF_TIMES){
        r2.activate(NowTimes+1);
       }
       else{
        r2.activate(0);
       }
     
      break; 
    // case 'q':
    //   r2.activate(0);
    //   break;
    // case 'w':
    //   r2.activate(1);
    //   break;
    // case 'e':
    //   r2.activate(2);
    //   break;

    // case 'a':
    //   r3.activate(0);
    //   break;
    // case 's':
    //   r3.activate(1);
    //   break;

    case 'q':
      r4.activate(0);
      break;
    case 'w':
      r4.activate(1);
      break;

    case 'z':
      if(NowUser>1){
        r6.activate(NowUser-2);
        // loadUserData();
      }
      else{
        r6.activate(UserNum-1);
      }
      break;
    case 'x':
      if(NowUser < UserNum){
         r6.activate(NowUser);
         // loadUserData();
      }
      else{
        r6.activate(0);
      }
      break;
  }
}

public void controlEvent(ControlEvent theEvent) {
  if(theEvent.isFrom(r1)) {
    if(theEvent.getValue()>=0){
    NowGesture = (int)theEvent.getValue()-1;
    println("NowGesture="+NowGesture);
    // loadUserData();
    }
  }
  if(theEvent.isFrom(r2)) {
    if(theEvent.getValue()>=0){
      if(!loadTimeFlg){
        loadTimeFlg = true;
        println("loadTimes()");
        loadTimes();
      }
    NowTimes = (int)theEvent.getValue();
    println("NowTimes="+NowTimes);
    // loadUserData();
    }
  }
  if(theEvent.isFrom(r4)) {
    if(theEvent.getValue()>=0){
      ShowingType = (int)theEvent.getValue()-1;
      println("ShowingType="+ShowingType);
    }
  }
   if(theEvent.isFrom(r5)) {
    if(theEvent.getValue()>=0){
    InterpolateType = (int)theEvent.getValue()-1;
    println("InterpolateType="+InterpolateType);
    }
  }
   if(theEvent.isFrom(r6)) {
    if(theEvent.getValue()>=0){
    NowUser = (int)theEvent.getValue();
    // loadUserData();
    println("NowUser="+NowUser);
     }
  }
  // assignSGcolorArrayFlg = true;
}

public float calSGValue(int user, int showtype, int Gesture, int NowTimes , int Row, int index){

  float allValue =0;
  int count =0;
  float allValue2 =0;
  int count2 =0;

    
      for(TableRow row : tableArray[user].findRows(str(Gesture), "Gesture")){
         if(NowTimes == NUM_OF_TIMES){
              if(row.getInt("Line1")==Row){
                  
                  allValue+=row.getFloat("SG1_"+index);
                  count++;
              }
              else if(row.getInt("Line2")==Row){

                  allValue+=row.getFloat("SG2_"+(index-NUM_OF_SG_FIRSTROW));
                  count++;
              }
         }
         else{
            if(row.getInt("Times") == NowTimes){
              if(row.getInt("Line1") == Row){
                  
                  allValue+=row.getFloat("SG1_"+index);
                  count++;
              }
              else if(row.getInt("Line2")==Row){

                  allValue+=row.getFloat("SG2_"+(index-NUM_OF_SG_FIRSTROW));
                  count++;
              }
            }

         }
          
      }
    
    if(showtype!=0){
       for(TableRow row : tableArray[user].findRows(str(NUM_OF_GESTURE_SET-1), "Gesture")){
         if(NowTimes == NUM_OF_TIMES){
              if(row.getInt("Line1")==Row){
                  
                  allValue2+=row.getFloat("SG1_"+index);
                  count2++;
              }
              else if(row.getInt("Line2")==Row){

                  allValue2+=row.getFloat("SG2_"+(index-NUM_OF_SG_FIRSTROW));
                  count2++;
              }
          }
          else{
              if(row.getInt("Times") == NowTimes){
              if(row.getInt("Line1") == Row){
                  
                  allValue2+=row.getFloat("SG1_"+index);
                  count2++;
              }
              else if(row.getInt("Line2")==Row){

                  allValue2+=row.getFloat("SG2_"+(index-NUM_OF_SG_FIRSTROW));
                  count2++;
              }
            }

          }
       }
     }  

    
    
    float mainAvg = allValue/count;

    if(showtype==0){
      return mainAvg;
    }
    else{
      // if( Level==0){                  //mid
      //   return allValue2/count2-allValue3/count3;
      // }
      // else if( Level==1){                //high
        return mainAvg-allValue2/count2;
      // }
      // else if( Level==2){                //low
      //   return mainAvg-allValue2/count2;
      // }
      // else{
      //   return mainAvg;
      // }
      // return mainAvg;
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
     float minimum=-0.25;
     float maximum=0.25;
     float ratio = 2 * (value-minimum) / (maximum - minimum);
     
     color heatmapRGB = color((int)max(0, 255*(ratio - 1)), 255-(int)max(0, 255*(1 - ratio))-(int)max(0, 255*(ratio - 1)), (int)max(0, 255*(1 - ratio)) );
     
     return heatmapRGB;
}
public void loadTimes(){
  for(int u=0; u<UserNum; u++){
    for(int s=0; s<NUM_OF_INTERPOLATION_TYPE ; s++){
              for(int g=0; g<NUM_OF_GESTURE_SET; g++){
                 for(int t=0; t<NUM_OF_TIMES; t++){
                    for(int eachRowi = 0; eachRowi < NUM_OF_HAND_ROWS; eachRowi++){
                        for(int sgi=0; sgi<NUM_OF_SG; sgi++){
                            SGcolorArray[u][s][g][t][eachRowi][sgi] = calSGValue(u,s,g,t,eachRowi*2+(sgi<NUM_OF_SG_FIRSTROW?0:1) , sgi);
                        }
                    }
                 }
              }
    }
  }

}
public void loadUserData(){

   float interX, interY;
   for(int u=0; u<UserNum; u++){
    for(int s=0; s<NUM_OF_INTERPOLATION_TYPE ; s++){
              for(int g=0; g<NUM_OF_GESTURE_SET; g++){
                 // for(int t=0; t<=NUM_OF_TIMES; t++){
                    for(int eachRowi = 0; eachRowi < NUM_OF_HAND_ROWS; eachRowi++){
                        for(int sgi=0; sgi<NUM_OF_SG; sgi++){
                            SGcolorArray[u][s][g][NUM_OF_TIMES][eachRowi][sgi] = calSGValue(u,s,g,NUM_OF_TIMES,eachRowi*2+(sgi<NUM_OF_SG_FIRSTROW?0:1) , sgi);
                        }
                    }
                 // }
              }
    }
  }

}

public void showImage(){
      
        image(imgArray[NowGesture], imgWidth, imgHeight, floor(width/5) , floor(height/3) );
      
}

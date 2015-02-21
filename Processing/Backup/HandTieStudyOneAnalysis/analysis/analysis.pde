import controlP5.*;

public final static int NUM_OF_SG_ROWS = 4;
public final static int NUM_OF_SG_COLS = 2;

public final static int NUM_OF_HAND_ROWS = 4;
public final static int NUM_OF_HAND_COLS = 5;
public final static int NUM_OF_Degree = 3;
 
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

 public int NowDegree = 0;      //3
 public int NowCol = 0;         //5
 public int NowRow = 0;          //6  =90
 public int NowFinger = 0;      //5
 public int NowLevel = 0;      //0: mid 1:high 2:low
 public boolean NowBend = false; 
 public int ShowingType = 0;
 
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
   r5 = cp5.addRadioButton("Degree0_90")
     .setPosition(ButtonPosX,50)
     .setSize(60,40)
     .setColorForeground(color(120))
     .setColorBackground(color(100,100,100))
     .setColorActive(color(255))
     .setColorLabel(color(0))
     .setItemsPerRow(5)
     .setSpacingColumn(100)
     .addItem("Degree_0",1)
     .addItem("Degree_90",2)
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
 
}

void draw() { 
  background(243,243,240); 
  for(int i =0; i < NUM_OF_HAND_ROWS; i++){
    for(int j=0; j < NUM_OF_HAND_COLS; j++){
        if(NowDegree>0){
          
            fill((ShowingType==0)?getHeatmapRGB(calSGValue(j,i,0)):getSubRGB(calSGValue(j,i,0)));
            rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_y*(NUM_OF_SG_ROWS*j),ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_x*(1+NUM_OF_SG_COLS*i),ShowGauge_dist_y, ShowGauge_dist_x, 5);
            fill((ShowingType==0)?getHeatmapRGB(calSGValue(j,i,1)):getSubRGB(calSGValue(j,i,1)));
            rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_y*(NUM_OF_SG_ROWS*j),ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_x*(NUM_OF_SG_COLS*i),ShowGauge_dist_y, ShowGauge_dist_x, 5);
            fill((ShowingType==0)?getHeatmapRGB(calSGValue(j,i,2)):getSubRGB(calSGValue(j,i,2)));
            rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_y*(1+NUM_OF_SG_ROWS*j),ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_x*(1+NUM_OF_SG_COLS*i),ShowGauge_dist_y, ShowGauge_dist_x, 5);
            fill((ShowingType==0)?getHeatmapRGB(calSGValue(j,i,3)):getSubRGB(calSGValue(j,i,3)));
            rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_y*(1+NUM_OF_SG_ROWS*j),ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_x*(NUM_OF_SG_COLS*i),ShowGauge_dist_y, ShowGauge_dist_x, 5);
            fill((ShowingType==0)?getHeatmapRGB(calSGValue(j,i,4)):getSubRGB(calSGValue(j,i,4)));
            rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_y*(2+NUM_OF_SG_ROWS*j),ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_x*(1+NUM_OF_SG_COLS*i),ShowGauge_dist_y, ShowGauge_dist_x, 5);
            fill((ShowingType==0)?getHeatmapRGB(calSGValue(j,i,5)):getSubRGB(calSGValue(j,i,5)));
            rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_y*(2+NUM_OF_SG_ROWS*j),ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_x*(NUM_OF_SG_COLS*i),ShowGauge_dist_y, ShowGauge_dist_x, 5);
            fill((ShowingType==0)?getHeatmapRGB(calSGValue(j,i,6)):getSubRGB(calSGValue(j,i,6)));
            rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_y*(3+NUM_OF_SG_ROWS*j),ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_x*(1+NUM_OF_SG_COLS*i),ShowGauge_dist_y, ShowGauge_dist_x, 5);
            fill((ShowingType==0)?getHeatmapRGB(calSGValue(j,i,7)):getSubRGB(calSGValue(j,i,7)));
            rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_y*(3+NUM_OF_SG_ROWS*j),ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_x*(NUM_OF_SG_COLS*i),ShowGauge_dist_y, ShowGauge_dist_x, 5);
          
        }
        else{
          fill((ShowingType==0)?getHeatmapRGB(calSGValue(j,i,0)):getSubRGB(calSGValue(j,i,0)));
          rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_x*NUM_OF_SG_COLS*j,ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_y*NUM_OF_SG_ROWS*i,ShowGauge_dist_x,ShowGauge_dist_y, 5);
          fill((ShowingType==0)?getHeatmapRGB(calSGValue(j,i,1)):getSubRGB(calSGValue(j,i,1)));
          rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_x*(1+NUM_OF_SG_COLS*j),ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_y*NUM_OF_SG_ROWS*i,ShowGauge_dist_x,ShowGauge_dist_y, 5);
          fill((ShowingType==0)?getHeatmapRGB(calSGValue(j,i,2)):getSubRGB(calSGValue(j,i,2)));
          rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_x*NUM_OF_SG_COLS*j,ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_y*(1+NUM_OF_SG_ROWS*i),ShowGauge_dist_x,ShowGauge_dist_y, 5);
          fill((ShowingType==0)?getHeatmapRGB(calSGValue(j,i,3)):getSubRGB(calSGValue(j,i,3)));
          rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_x*(1+NUM_OF_SG_COLS*j),ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_y*(1+NUM_OF_SG_ROWS*i),ShowGauge_dist_x,ShowGauge_dist_y, 5);
          fill((ShowingType==0)?getHeatmapRGB(calSGValue(j,i,4)):getSubRGB(calSGValue(j,i,4)));
          rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_x*NUM_OF_SG_COLS*j,ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_y*(2+NUM_OF_SG_ROWS*i),ShowGauge_dist_x,ShowGauge_dist_y, 5);
          fill((ShowingType==0)?getHeatmapRGB(calSGValue(j,i,5)):getSubRGB(calSGValue(j,i,5)));
          rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_x*(1+NUM_OF_SG_COLS*j),ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_y*(2+NUM_OF_SG_ROWS*i),ShowGauge_dist_x,ShowGauge_dist_y, 5);
          fill((ShowingType==0)?getHeatmapRGB(calSGValue(j,i,6)):getSubRGB(calSGValue(j,i,6)));
          rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_x*NUM_OF_SG_COLS*j,ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_y*(3+NUM_OF_SG_ROWS*i),ShowGauge_dist_x,ShowGauge_dist_y, 5);
          fill((ShowingType==0)?getHeatmapRGB(calSGValue(j,i,7)):getSubRGB(calSGValue(j,i,7)));
          rect(ShowGauge_x+ShowGaugeGroup_dist*j+ShowGauge_dist_x*(1+NUM_OF_SG_COLS*j),ShowGauge_y+ShowGaugeGroup_dist*i+ShowGauge_dist_y*(3+NUM_OF_SG_ROWS*i),ShowGauge_dist_x,ShowGauge_dist_y, 5);
        }
    }
  }
}

void keyPressed() {
  switch(key){
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
    NowDegree = (int)theEvent.getValue()-1;
    println("NowDegree="+NowDegree);
  }
}
void Finger(int a) {
  println("a radio Button event: "+a);
}
public float calSGValue(int Col, int Row, int index){

  float allValue =0;
  int count =0;
  float allValue2 =0;
  int count2 =0;
  float allValue3 =0;
  int count3 =0;
    
  
    if(ShowingType==0 || NowLevel!=0){
      for(TableRow row : tableArray[0].findRows(str(NowDegree), "Degree")){
         
          
          if(row.getInt("Finger")==NowFinger && boolean(row.getString("Bend"))==NowBend && row.getInt("Level")==NowLevel && row.getInt("Cols1")==Col && row.getInt("Rows1")==Row){
              
              allValue+=row.getFloat("SG1_"+index);
              count++;
          }
          else if(row.getInt("Finger")==NowFinger && boolean(row.getString("Bend"))==NowBend && row.getInt("Level")==NowLevel && row.getInt("Cols2")==Col && row.getInt("Rows2")==Row){
               
              allValue+=row.getFloat("SG2_"+index);
              count++;
          }
      }
    }
    if(ShowingType!=0){
        if(NowLevel==0){
          for(TableRow row : tableArray[0].findRows(str(NowDegree), "Degree")){
              if(row.getInt("Finger")==NowFinger && boolean(row.getString("Bend"))==NowBend && row.getInt("Level")==1 && row.getInt("Cols1")==Col && row.getInt("Rows1")==Row){
                  
                  allValue2+=row.getFloat("SG1_"+index);
                  count2++;
              }
              else if(row.getInt("Finger")==NowFinger && boolean(row.getString("Bend"))==NowBend && row.getInt("Level")==1 && row.getInt("Cols2")==Col && row.getInt("Rows2")==Row){
                   
                  allValue2+=row.getFloat("SG2_"+index);
                  count2++;
              }
              else if(row.getInt("Finger")==NowFinger && boolean(row.getString("Bend"))==NowBend && row.getInt("Level")==2 && row.getInt("Cols1")==Col && row.getInt("Rows1")==Row){
                  
                  allValue3+=row.getFloat("SG1_"+index);
                  count3++;
              }
              else if(row.getInt("Finger")==NowFinger && boolean(row.getString("Bend"))==NowBend && row.getInt("Level")==2 && row.getInt("Cols2")==Col && row.getInt("Rows2")==Row){
                   
                  allValue3+=row.getFloat("SG2_"+index);
                  count3++;
              }
          }
          
        }
        else if(NowLevel==1){
            for(TableRow row : tableArray[0].findRows(str(NowDegree), "Degree")){
                if(row.getInt("Finger")==NowFinger && boolean(row.getString("Bend"))==NowBend && row.getInt("Level")==0 && row.getInt("Cols1")==Col && row.getInt("Rows1")==Row){
                    
                    allValue2+=row.getFloat("SG1_"+index);
                    count2++;
                }
                else if(row.getInt("Finger")==NowFinger && boolean(row.getString("Bend"))==NowBend && row.getInt("Level")==0 && row.getInt("Cols2")==Col && row.getInt("Rows2")==Row){
                     
                    allValue2+=row.getFloat("SG2_"+index);
                    count2++;
                }
            }
            
        }
        else if(NowLevel==2){
            for(TableRow row : tableArray[0].findRows(str(NowDegree), "Degree")){
                if(row.getInt("Finger")==NowFinger && boolean(row.getString("Bend"))==NowBend && row.getInt("Level")==0 && row.getInt("Cols1")==Col && row.getInt("Rows1")==Row){
                    
                    allValue2+=row.getFloat("SG1_"+index);
                    count2++;
                }
                else if(row.getInt("Finger")==NowFinger && boolean(row.getString("Bend"))==NowBend && row.getInt("Level")==0 && row.getInt("Cols2")==Col && row.getInt("Rows2")==Row){
                     
                    allValue2+=row.getFloat("SG2_"+index);
                    count2++;
                }
            }
            
        }
    
    }
    if(ShowingType==0){
      return allValue/count;
    }
    else{
      if(NowLevel==0){
        return allValue2/count2-allValue3/count3;
      }
      else if(NowLevel==1){
        return allValue/count-allValue2/count2;
      }
      else if(NowLevel==2){
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



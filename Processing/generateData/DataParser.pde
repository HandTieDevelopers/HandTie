import java.util.HashSet;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.PrintWriter;

class DataParser {
  int mNumGestures;
  int mNumSamplePerGesture;
  int mNumMaxTrialsPerGesture;
  final char delimeter = ' ';
  final int GestureIdx = 0;
  final int TrialIdx = 1;
  final int[] RowIdxs = new int[]{ 2, 12 };
  final int[] FirstGaugeIdxs = new int[]{ 3, 13 };
  final int[] NumGages = new int[]{ 9, 10 };
  final int bufferSize = 300;
  boolean[] rowIsChosen = new boolean[RowIdxs.length];
  StringBuffer[][] dataInstances;
  int[] trainingTrialNums;
  int[] testingTrialNums;
  int numTrainingTrials;
  int numTestingTrials;

  public DataParser(int numGestures, int numSamplesPerGesture, int numMaxTrialsPerGesture) {
    mNumGestures = numGestures;
    mNumSamplePerGesture = numSamplesPerGesture;
    mNumMaxTrialsPerGesture = numMaxTrialsPerGesture;
  }

  public void parse(File dataFile, ParseCondition condition) {
    if(dataFile == null) {
      println("dataFile is null, unable to parse");
      return;
    }

    int[] selectedRows = condition.selectedRows;
    trainingTrialNums = condition.trialNums;
    numTrainingTrials = trainingTrialNums.length;
    numTestingTrials = mNumMaxTrialsPerGesture - numTrainingTrials;
    testingTrialNums = new int[numTestingTrials];
    HashSet<Integer> trainingTrialNumsSet = new HashSet<Integer>();
    for(int trialNum : trainingTrialNums) {
      trainingTrialNumsSet.add(trialNum);
    }

    for(int i = 0,j = 0;i < mNumMaxTrialsPerGesture;i++) {
      if(!trainingTrialNumsSet.contains(i)) {
        testingTrialNums[j] = i;
        j++;
        if(j == numTestingTrials) {
          break;
        }
      }
    }

    dataInstances = new StringBuffer[mNumGestures][mNumMaxTrialsPerGesture];

    for(int i = 0;i < mNumGestures;i++) {
      for(int j = 0;j < mNumMaxTrialsPerGesture;j++) {
        dataInstances[i][j] = new StringBuffer();
        dataInstances[i][j].append(i);
        dataInstances[i][j].append(delimeter);
      }
    }

    HashSet<Integer> selectedRowsSet = new HashSet<Integer>();
    for(int rowNum : selectedRows) {
      selectedRowsSet.add(rowNum);
    }
    BufferedReader reader = null;
    try {
      reader = new BufferedReader(new FileReader(dataFile), bufferSize);
      String lineOfData;
      lineOfData = reader.readLine(); //first line is currently useless.
      if(lineOfData == null) {
        return;
      } 
      int numGesturesNeedToBeCollected = mNumGestures * mNumMaxTrialsPerGesture * selectedRows.length; //early stop mechanism
      while((lineOfData = reader.readLine()) != null ) {
        /*
        if(numGesturesNeedToBeCollected == 0) {
          break;
        }
        */
        String[] splitedData = lineOfData.split(",");
        boolean toSkipThisGesture = true;

        for(int i = 0;i < RowIdxs.length;i++) {
          if(selectedRowsSet.contains(Integer.parseInt(splitedData[RowIdxs[i]]))) { //this gesture contains the desired row of data
            rowIsChosen[i] = true;
            numGesturesNeedToBeCollected--;
            toSkipThisGesture = false;
          }
          else {
            rowIsChosen[i] = false;
          }
        }
        
        int remainNumSamples = mNumSamplePerGesture - 1;
        if(toSkipThisGesture) { // not in selected rows
          while(remainNumSamples > 0 && reader.readLine() != null) {
            remainNumSamples--;
          }
        }
        else {
          while(true) {
            for(int i = 0;i < RowIdxs.length;i++) {
              if(rowIsChosen[i]) {
                concatFeatureVector(splitedData, FirstGaugeIdxs[i], NumGages[i]);
              }
            }
            
            if(remainNumSamples > 0 && (lineOfData = reader.readLine()) != null) {
              splitedData = lineOfData.split(",");
              remainNumSamples--;
            }
            else {
              break;
            }

          }          
        }

        if(remainNumSamples > 0) {
          println("number of samples record per gesture was wrong");
        }
      }

      if(numGesturesNeedToBeCollected < 0 || numGesturesNeedToBeCollected > 0) {
        println("numGesturesNeedToBeCollected is abnormal:" + numGesturesNeedToBeCollected);
      }
      

    } catch (Exception e) {
      println(e.getLocalizedMessage());
    } finally {
      try {
        reader.close();
      } catch (Exception e) {
        
      }
    }


  }

  public void concatFeatureVector(String[] splitedData, int startIndex, int numData) {
    int gestureID = Integer.parseInt(splitedData[GestureIdx]);
    int trialNum = Integer.parseInt(splitedData[TrialIdx]);
    for(int i = startIndex;i < numData;i++) {
      dataInstances[gestureID][trialNum].append(splitedData[i]);  
      dataInstances[gestureID][trialNum].append(delimeter);
    }
  }

  public void outputToFile(File directory, String fileName, DataType dataType) {
    File outputFile = new File(directory, fileName);
    PrintWriter pw = null;
    try {
      pw = new PrintWriter(outputFile);
      if(dataType == DataType.Training) {
        for(int i = 0;i < mNumGestures;i++) {
          for(int j = 0;j < numTrainingTrials;j++) {
            pw.println(dataInstances[i][trainingTrialNums[j]].toString());
          }
        }  
       
      }
      else if(dataType == DataType.Testing) {
        for(int i = 0;i < mNumGestures;i++) {
          for(int j = 0;j < numTestingTrials;j++) {
            pw.println(dataInstances[i][testingTrialNums[j]].toString());
          }
        }    
      }
    } catch (Exception e) {
      println(e.getLocalizedMessage());
    } finally {
      try {
        pw.close();
      } catch (Exception e) {
        println(e.getLocalizedMessage());
      }
    }
    
  }


};


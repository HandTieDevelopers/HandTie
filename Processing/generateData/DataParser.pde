import java.util.HashSet;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.PrintWriter;

class DataParser {
  int mNumGestures;
  int mNumSamplesPerTrial;
  int mNumMaxTrialsPerGesture;
  final char delimeter = ' ';
  final int GestureIdx = 0;
  final int TrialIdx = 1;
  final int[] RowIdxs = new int[]{ 2, 12 };
  final int[] FirstGaugeIdxs = new int[]{ 3, 13 };
  final int[] NumGages = new int[]{ 9, 10 };
  final int bufferSize = 300;
  boolean[] rowIsChosen = new boolean[RowIdxs.length];
  StringBuffer[][][] dataInstances;
  int[] trainingTrialNums;
  int[] testingTrialNums;
  int numTrainingTrials;
  int numTestingTrials;
  int[][][] vecNum;
  DataFormat mDataFormat;

  public DataParser(int numGestures, int numSamplesPerTrial, int numMaxTrialsPerGesture) {
    mNumGestures = numGestures;
    mNumSamplesPerTrial = numSamplesPerTrial;
    mNumMaxTrialsPerGesture = numMaxTrialsPerGesture;
    vecNum = new int[numGestures][numMaxTrialsPerGesture][numSamplesPerTrial];
    dataInstances = new StringBuffer[mNumGestures][mNumMaxTrialsPerGesture][mNumSamplesPerTrial];
    for(int i = 0;i < mNumGestures;i++) {
      for(int j = 0;j < mNumMaxTrialsPerGesture;j++) {
        for(int k = 0;k < mNumSamplesPerTrial;k++) {
          dataInstances[i][j][k] = new StringBuffer();
        }
      }
    }
  }

  void initVariables() {
    for(int i = 0;i < mNumGestures;i++) {
      for(int j = 0;j < mNumMaxTrialsPerGesture;j++) {
        for(int k = 0;k < mNumSamplesPerTrial;k++) {
          vecNum[i][j][k] = 1;  
          dataInstances[i][j][k].setLength(0);
          dataInstances[i][j][k].append(i);
          dataInstances[i][j][k].append(delimeter); 
        }
      }
    }
  }

  public void parse(File dataFile, ParseCondition condition) {
    if(dataFile == null) {
      println("dataFile is null, unable to parse");
      return;
    }
    initVariables();

    int[] selectedRows = condition.selectedRows;
    trainingTrialNums = condition.trialNums;
    mDataFormat = condition.dataFormat;
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
      int numDataNeedToBeCollected = mNumGestures * mNumMaxTrialsPerGesture * selectedRows.length; //early stop mechanism
      while((lineOfData = reader.readLine()) != null ) {
        /*
        if(numDataNeedToBeCollected == 0) {
          break;
        }
        */
        String[] splitedData = lineOfData.split(",");
        boolean toSkipThisGesture = true;

        for(int i = 0;i < RowIdxs.length;i++) {
          if(selectedRowsSet.contains(Integer.parseInt(splitedData[RowIdxs[i]]))) { //this gesture contains the desired row of data
            rowIsChosen[i] = true;
            numDataNeedToBeCollected--;
            toSkipThisGesture = false;
          }
          else {
            rowIsChosen[i] = false;
          }
        }
        
        int remainNumSamples = mNumSamplesPerTrial - 1;
        int sampleIndex = 0;
        if(toSkipThisGesture) { // not in selected rows
          while(remainNumSamples > 0 && reader.readLine() != null) {
            remainNumSamples--;
          }
        }
        else {
          while(true) {
            for(int i = 0;i < RowIdxs.length;i++) {
              if(rowIsChosen[i]) {
                concatFeatureVector(splitedData, FirstGaugeIdxs[i], NumGages[i], sampleIndex);
              }
            }
            
            if(sampleIndex < remainNumSamples && (lineOfData = reader.readLine()) != null) {
              splitedData = lineOfData.split(",");
              sampleIndex++;
            }
            else {
              break;
            }

          }          
        }

        if(remainNumSamples > 0 && sampleIndex < remainNumSamples) {
          println("number of samples record per gesture was wrong");
        }
      }

      if(numDataNeedToBeCollected < 0 || numDataNeedToBeCollected > 0) {
        println("numDataNeedToBeCollected is abnormal:" + numDataNeedToBeCollected);
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


  public void concatFeatureVector(String[] splitedData, int startIndex, int numDataPoints, int sampleIndex) {
    int gestureID = Integer.parseInt(splitedData[GestureIdx]);
    int trialNum = Integer.parseInt(splitedData[TrialIdx]);
    int endIndex = startIndex + numDataPoints;
    StringBuffer instance = dataInstances[gestureID][trialNum][sampleIndex];
    if(mDataFormat == DataFormat.LibLinearAndSVM) { 
      for(int i = startIndex;i < endIndex;i++) {
        instance.append(vecNum[gestureID][trialNum][sampleIndex]);
        instance.append(':');
        vecNum[gestureID][trialNum][sampleIndex]++;
        instance.append(splitedData[i]);
        instance.append(delimeter);
      }
    }
    else {
      for(int i = startIndex;i < endIndex;i++) {
        instance.append(splitedData[i]);
        instance.append(delimeter);
      }
    }
    
  }

  public void outputToFile(File directory, String fileName, DataType dataType) {
    File outputFile = new File(directory, fileName);
    PrintWriter pw = null;
    try {
      pw = new PrintWriter(outputFile);
      int numTrials = 0;
      int[] trialNumsArray = null;
      if(dataType == DataType.Training) {
        numTrials = numTrainingTrials;
        trialNumsArray = trainingTrialNums;
      }
      else if(dataType == DataType.Testing) {
        numTrials = numTestingTrials;
        trialNumsArray = testingTrialNums;  
      }
      for(int i = 0;i < mNumGestures;i++) {
        for(int j = 0;j < numTrials;j++) {
          for(int k = 0;k < mNumSamplesPerTrial;k++) {
            pw.println(dataInstances[i][trialNumsArray[j]][k].toString());  
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

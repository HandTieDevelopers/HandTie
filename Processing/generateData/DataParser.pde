import java.util.HashSet;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.PrintWriter;

class DataParser {
  int mNumGestures;
  int mNumSamplesPerTrial;
  int mNumMaxTrialsPerGesture;
  int mNumTotalRows;
  int mNumHalfTotalRows;
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
  int[] gestureNums;
  int numTrainingTrials;
  int numTestingTrials;
  int[][][] vecNum;
  DataFormat mDataFormat;
  int numTotalInstances;
  int[] numInstancesPerClass;
  int numDimensions = 0;
  int[][][] sampleIdx;
  final int offSet = 2;
  int[] allGestures;
  int numGesturesSelected;

  public DataParser(int numGestures, int numSamplesPerTrial, int numMaxTrialsPerGesture, int numTotalRows) {
    mNumGestures = numGestures;
    allGestures = new int[mNumGestures];
    mNumSamplesPerTrial = numSamplesPerTrial;
    mNumMaxTrialsPerGesture = numMaxTrialsPerGesture;
    mNumTotalRows = numTotalRows;
    mNumHalfTotalRows = mNumTotalRows/2;
    vecNum = new int[numGestures][numMaxTrialsPerGesture][mNumSamplesPerTrial];
    dataInstances = new StringBuffer[mNumGestures][mNumMaxTrialsPerGesture][mNumSamplesPerTrial];
    sampleIdx = new int[numGestures][numMaxTrialsPerGesture][mNumHalfTotalRows];
    for(int i = 0;i < mNumGestures;i++) {
      allGestures[i] = i;
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
          vecNum[i][j][k] = 1; //feature vector index for libsvm and liblinear format
          dataInstances[i][j][k].setLength(0);
          dataInstances[i][j][k].append(i + 1); //label
          dataInstances[i][j][k].append(delimeter);  
        }
        for(int k = 0;k < mNumHalfTotalRows;k++) {
          sampleIdx[i][j][k] = 0;
        }
      }
    }
  }

  File currentFile;
  int gestureID;
  int trialNum;
  int rowIdxForSampleIdx;
  
  public void parse(File dataFile, ParseCondition condition) {
    if(dataFile == null) {
      println("dataFile is null, unable to parse");
      return;
    }

    currentFile = dataFile;
    
    initVariables();

    int[] selectedRows = condition.selectedRows;
    trainingTrialNums = condition.trialNums;
    mDataFormat = condition.dataFormat;
    gestureNums = condition.selectedGestures;
    if(gestureNums == null || gestureNums.length == 0) {
      gestureNums = allGestures;
    }
    numGesturesSelected = gestureNums.length;
    numTrainingTrials = trainingTrialNums.length;
    numTestingTrials = mNumMaxTrialsPerGesture - numTrainingTrials;
    testingTrialNums = new int[numTestingTrials];

    numDimensions = 0;
    for(int rowNum : selectedRows) {
      numDimensions += (((rowNum + 1) % 2) * 9 + (rowNum % 2) * 10);
    }

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
    //println(selectedRowsSet);

    BufferedReader reader = null;
    try {
      reader = new BufferedReader(new FileReader(dataFile), bufferSize);
      String lineOfData;
      lineOfData = reader.readLine(); //first line is currently useless.
      if(lineOfData == null) {
        return;
      } 
      //int numDataNeedToBeCollected = mNumGestures * mNumMaxTrialsPerGesture * selectedRows.length; //early stop mechanism
      while((lineOfData = reader.readLine()) != null ) {
          
        String[] splitedData = lineOfData.split(",");
        gestureID = Integer.parseInt(splitedData[GestureIdx]);
        trialNum = Integer.parseInt(splitedData[TrialIdx]);
        rowIdxForSampleIdx = Integer.parseInt(splitedData[RowIdxs[0]])/2;
        
        for(int i = 0;i < RowIdxs.length;i++) {
          if(selectedRowsSet.contains(Integer.parseInt(splitedData[RowIdxs[i]]))) { //this gesture contains the desired row of data
            concatFeatureVector(splitedData, FirstGaugeIdxs[i], NumGages[i]);
          }
        }

        sampleIdx[gestureID][trialNum][rowIdxForSampleIdx]++;
        
        /*
        if(remainNumSamples > 0 && sampleIndex < remainNumSamples) {
          println("number of samples record per gesture was wrong:" + sampleIndex + "," + remainNumSamples + ",fileName:" + dataFile.getName() );
        }
        */
      }
      // if(numDataNeedToBeCollected < 0 || numDataNeedToBeCollected > 0) {
      //   println("numDataNeedToBeCollected is abnormal:" + numDataNeedToBeCollected + ",fileName:" + dataFile.getName());
      // }
    } catch (Exception e) {
      println("Exception:" + e.getLocalizedMessage());
    } finally {
      try {
        reader.close();
      } catch (Exception e) {
        
      }
    }

  }


  public void concatFeatureVector(String[] splitedData, int startIndex, int numDataPoints) {
    
    int endIndex = startIndex + numDataPoints;
    int localSampleIdx = sampleIdx[gestureID][trialNum][rowIdxForSampleIdx];
    StringBuffer instance = null;
    
    try {
      instance = dataInstances[gestureID][trialNum][localSampleIdx];  
    } catch (Exception e) {
      println("exception:" + currentFile.getName() + "," + gestureID + "," + trialNum + "," + localSampleIdx);
      return;
    }

    if(mDataFormat == DataFormat.LibLinearAndSVM) { 
      for(int i = startIndex;i < endIndex;i++) {
        instance.append(vecNum[gestureID][trialNum][localSampleIdx]);
        instance.append(':');
        instance.append(splitedData[i]);
        instance.append(delimeter);
        vecNum[gestureID][trialNum][localSampleIdx]++;
      }
    }
    else {
      for(int i = startIndex;i < endIndex;i++) {
        instance.append(splitedData[i]);
        instance.append(delimeter);
      }
    }
    
    
  }
 
  StringBuffer tempStrBuf = new StringBuffer();
  public void writeHeader(PrintWriter pw) {
    if(mDataFormat == DataFormat.GRT) {
      pw.println("GRT_LABELLED_CLASSIFICATION_DATA_FILE_V1.0");
      pw.println("DatasetName: NOT_SET");
      pw.println("InfoText: ");
      pw.println("NumDimensions: " + numDimensions);
      pw.println("TotalNumExamples: "  + numTotalInstances);
      pw.println("NumberOfClasses: " + numGesturesSelected);
      pw.println("ClassIDsAndCounters: ");
      for(int i = 0;i < numGesturesSelected;i++) {
        tempStrBuf.setLength(0);
        tempStrBuf.append(gestureNums[i] + 1);
        tempStrBuf.append(' ');
        tempStrBuf.append(numInstancesPerClass[i]);
        tempStrBuf.append(" NOT_SET");
        pw.println(tempStrBuf.toString());
      }
      pw.println("UseExternalRanges: 0");
      pw.println("Data:");

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

      numTotalInstances = 0;
      numInstancesPerClass = new int[numGesturesSelected];
      for(int i = 0;i < numGesturesSelected;i++) {
        numInstancesPerClass[i] = numTrials * mNumSamplesPerTrial;
        for(int j = 0;j < numTrials;j++) {
          for(int k = 0;k < mNumSamplesPerTrial;k++) {
            if(dataInstances[gestureNums[i]][trialNumsArray[j]][k].length() <= 3) { //the length only containing label would be 3
              numInstancesPerClass[i]--;
            }
          }
        }
        numTotalInstances += numInstancesPerClass[i];
      }
      
      writeHeader(pw);
      for(int i = 0;i < numGesturesSelected;i++) {
        for(int j = 0;j < numTrials;j++) {
          for(int k = 0;k < mNumSamplesPerTrial;k++) {
            String outputStr = dataInstances[gestureNums[i]][trialNumsArray[j]][k].toString();
            if(outputStr.length() > 3) { //the length only containing label would be 3
              pw.println(outputStr);  
            }
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

import java.io.*;

//Config
String fileFolderName = "data_input";
int GNum = 16;
String desiredRowComb = "rows12";
String outputConfusionMatrixFileName = "AllUsers_" + desiredRowComb + ".CM";

char delimiter = ',';
int[] gMappingIndex = new int[] {
0,1,2,3,4,5,6,7,8,9,10,11,12,13,-1,14,15
};

void setup() {
  //first dimension : predicted Label, second dimension : ground truth label
  int[][] MatrixCount = new int[GNum][GNum]; 
  String currentSketchPath = sketchPath("");
  File dir = new File(currentSketchPath + "/" + fileFolderName); 
  if(dir == null) {
    println("directory not found");
    return;
  }
  
  String[] allFileNames = dir.list();
  
  if (allFileNames == null) {
    println("-- file not found");
    return;
  } else {
    ArrayList<String> allTestingFileNames = new ArrayList<String>();
    //ArrayList<String> allResultFileNames = new ArrayList<String>();
    
    for(String fileName : allFileNames) {
      if(fileName.contains("testing") && fileName.contains(desiredRowComb) && fileName.contains(".txt")) {
        allTestingFileNames.add(fileName);  
      }
      /*
      else if(fileName.contains("result") && fileName.contains(desiredRowComb)) {
        allResultFileNames.add(fileName);
      }
      */
    }
    
    for(String testFileName : allTestingFileNames) {
      File testFile = new File(dir,testFileName);
      String correspondingResultFileName = testFileName.substring(0, testFileName.lastIndexOf('.')) + ".result";
      File resultFile = new File(dir,correspondingResultFileName);
      
      if(!testFile.exists() || !resultFile.exists()) {
        println("test or result file didn't exist, testFileName:" + testFileName);
        continue;
      }
      
      BufferedReader testFileReader = null,resultFileReader = null;
      try {
        testFileReader = new BufferedReader(new FileReader(testFile));
        resultFileReader = new BufferedReader(new FileReader(resultFile));
        String aLineInTestFile = null;
        while((aLineInTestFile = testFileReader.readLine()) != null) {
          int groundTruthLabel = Integer.parseInt(aLineInTestFile.substring(0,aLineInTestFile.indexOf(' '))) - 1; // -1 due to label is 1 to number_gestures
          String aLineInResultFile = resultFileReader.readLine();
          if(aLineInResultFile == null) {
            println("a error happened during reading line from :" + correspondingResultFileName);
            println("error happened, didn't output result");
            return;
          }
          
          int predictedLabel = Integer.parseInt(aLineInResultFile) - 1; // -1 due to label is 1 to number_gestures
          //println(predictedLabel + " " +groundTruthLabel);
          MatrixCount[gMappingIndex[groundTruthLabel]][gMappingIndex[predictedLabel]]++;
          
        }
      }
      catch(Exception e) {
        println(e.getLocalizedMessage());
        println("exception happened, didn't output result");
        return;
      }
      finally {
        try {
          testFileReader.close();
        }
        catch(Exception e) { }
        try {
          resultFileReader.close();
        }
        catch(Exception e) { }
      }
    }
    
    int[] totalCount = new int[GNum];
    for(int i = 0;i < GNum;i++) {
      for(int j = 0;j < GNum;j++) {
         totalCount[i] =  totalCount[i] + MatrixCount[i][j];
      }
    }
    
    StringBuffer[] matrixRowStr = new StringBuffer[GNum];
    for(int i = 0;i < GNum;i++)
      matrixRowStr[i] = new StringBuffer();
    for(int i = 0;i < GNum;i++) {
      for(int j = 0;j < GNum;j++) {
        if(totalCount[i] != 0) {
          float value = MatrixCount[i][j]/(float)totalCount[i];
          matrixRowStr[i].append(value * 100); //output unit : %
          matrixRowStr[i].append(delimiter);
        }
        else {
          break;
        }
      }
    }
    
    PrintWriter outputWriter = null;
    try {
      File outputFile = new File(currentSketchPath,outputConfusionMatrixFileName);
//    if(outputFile.exists()) {
//      outputFile.delete();
//    }
      outputWriter = new PrintWriter(new FileWriter(outputFile));
      for(int i = 0;i < GNum;i++) {
        outputWriter.println(matrixRowStr[i].toString());
      }
    }
    catch(Exception e) {
      println(e.getLocalizedMessage());
      println("exception happened, didn't output result");
      return;
    }
    finally {
      try {
        outputWriter.close();
      }
      catch(Exception e) { }
    }
    println("done without any error");
    exit();
  }
  
}

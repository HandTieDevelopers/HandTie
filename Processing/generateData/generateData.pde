import controlP5.*;
import java.util.Random;
import java.util.Set;
import java.util.HashSet;
import java.util.List;
import java.util.ArrayList;

final int windowWidth = 1100;
final int windowHeight = 700;

final int NumGestures = 17;
final int NumRowsPerRound = 2;
final int NumRepeatedTimes = 4; //put strain gages at different positions
final int NumTrialsPerGesture = 10;
final int NumSamplesPerTrial = 20;
final int TotalNumRows = NumRowsPerRound * NumRepeatedTimes;

final String ConfigFileName = "config.json";
final String buttonEventHandlerName = "buttonEventHandler";
final String inputDataFilePath_Key = "inputDataFilePath";
final String outputDataDirPath_Key = "outputDataDirPath";
final String inputDataDirPath_Key = "inputDataDirPath";
final String fileExtensionName = ".txt";

final String checkBatchingIntent = "start to batch?(y/n)";

final String[] fileNameToIgnore = new String[] {".DS_Store", "User0"};

final String[] dataTypes = new String[] {"training" , "testing"};
String currentSketchPath = null;

//used to save where data should be placed.
//default is [sketchPath]/outputData
File outputDataDir = null;
File inputDataFile = null;
File inputDataDir = null;
JSONObject config = null;

int numTrialsToUse = 1; //linked with slider

//-- Processing State Machines --



void setup() {
  currentSketchPath = sketchPath("");

  loadConfig();
  
  new DisposeHandler(this); //exit handler
  
  initView();
  
  new ControlEventHandler(this);
  
  for(int i = 0;i < NumTrialsPerGesture;i++) {
    trialNumsForShuffle[i] = i;
  }
}

void draw() {
  background(200);
}

final int char0AsciiVal = (int)'0';
final int char9AsciiVal = (int)'9';
int controlCheckBoxDataIndex = 0;
String statusTxt;

void keyPressed() {
  //println(key);
  int asciiVal = key;
  if(asciiVal >= char0AsciiVal && asciiVal <= char9AsciiVal) {
    //println(asciiVal - char0AsciiVal);
    int controlIndex = asciiVal - char0AsciiVal;
    CheckBox cb = cbArray[controlCheckBoxDataIndex];
    if(controlIndex < cb.getArrayValue().length) {
      if(cb.getState(controlIndex)) {
        cb.deactivate(controlIndex);
      }
      else {
        cb.activate(controlIndex);
      }
    }
    
  
  }
  else {
    if(key == '`') {
      controlCheckBoxDataIndex++;
      if(controlCheckBoxDataIndex == CheckBoxData.numDataType.ordinal()) {
        controlCheckBoxDataIndex = 0;
      }
    }
    //TO DO : we should use label to indicate which checkbox is under control.
    else if(key == 'q') {
      changeCheckBoxAllStatus(false);
    }
    else if(key == 'w') {
      changeCheckBoxAllStatus(true);
    }
    else if(key == 'r') {
      randomSelectTrialNums(numTrialsToUse);
    }
    else if(key == 'b') {
      // may be we should use a message box to prevent falsely triggering.
      systemStatus_textlabel.setText(checkBatchingIntent);
    }
    else if(key == 'y') {
      statusTxt = systemStatus_textlabel.get().getText();
      if(statusTxt.equals(checkBatchingIntent)) {
        systemStatus_textlabel.setText(SystemStatus.Do_Batching.toString());
        batchTasks();
      }
    }
    else if(key == 'n') {
      statusTxt = systemStatus_textlabel.get().getText();
      if(statusTxt.equals(checkBatchingIntent)) {
        systemStatus_textlabel.setText(SystemStatus.Idle.toString());
      }
    }
  }

}

//--

//controlp5 and UI components
ControlP5 cp5;
ControlGroup messageBox;
//DropdownList dataType_dropdownList;
CheckBox usedRow_checkBox;
CheckBox usedTrials_checkBox;
CheckBox usedGestures_checkBox;
CheckBox[] cbArray;
Textlabel inputDataFilePath_textlabel;
Textlabel outputDataDirPath_textlabel;
Textlabel inputDataDirPath_textlabel;
Textlabel messageText = null;
Textlabel systemStatus_textlabel;

//Textfield numTrialsToUse_textfield;
Slider numTrialsToUse_slider;
RadioButton inputDataSource_radioButton;
RadioButton dataFormat_radioButton;
Button inputDataFileSelector, inputDataDirSelector, outputDataDirSelector, generatingDataButton;
String generateDataButtonName = "Generate_Button";

//-- View --
final int buttonWidth = 250,buttonHeight = 30;
void initView() {
  size(windowWidth, windowHeight);
  cp5 = new ControlP5(this);
  
  ControlFont font = new ControlFont(createFont("Arial",12),12);
  cp5.setControlFont(font);
  
  //dropdown lists
  // dataType_dropdownList = cp5.addDropdownList("dataType")
  //                            .setPosition(400, 100)
  //                            .setSize(200,200)
  //                            .setItemHeight(20)
  //                            .setBarHeight(15)
  //                            .setCaptionLabel("select data type")
  //                            //.setBackgroundColor(color(190))
  //                            .setColorBackground(color(60))
  //                            .setColorActive(color(255, 128));
  // dataType_dropdownList.captionLabel().style().marginTop = 3;
  // dataType_dropdownList.captionLabel().style().marginLeft = 3;
  // dataType_dropdownList.valueLabel().style().marginTop = 3;
  // dataType_dropdownList.addItems(dataTypes);
  
  
  int firstButtonY = 68;
  int textLabelAlignX = 140;
  int textPathAlignX = textLabelAlignX + 121;
  int buttonAlignX = textPathAlignX;
  int textFontSize = 14;
  int firstTextY = 28;
  int textSpaceHeight = 120 -28;
  int textAndButtonHeight = firstButtonY - firstTextY;
  int genDataBtnX = windowWidth/2 - buttonWidth/2;
  int genDataBtnY = windowHeight - 70;
  
  
  //Text labels
  String textToBeSet = null;
  if(inputDataFile == null) {
    textToBeSet = "";
  }
  else {
    textToBeSet = inputDataFile.getAbsolutePath();
  }
  
  cp5.addTextlabel("Input File Label")
     .setText("Input File")
     .setPosition(textLabelAlignX,firstTextY)
     .setColorValue(0xffffff00)
     .setFont(createFont("Georgia",textFontSize));
  
  inputDataFilePath_textlabel = cp5.addTextlabel(inputDataFilePath_Key)
                                   .setText(textToBeSet)
                                   .setPosition(textPathAlignX,firstTextY)
                                   //.setWidth(textBoxWidth)
                                   .setColorValue(0xffffff00)
                                   .setFont(createFont("Georgia",textFontSize));

  if(inputDataDir == null) {
    textToBeSet = "";
  }
  else {
    textToBeSet = inputDataDir.getAbsolutePath();
  }
  
  cp5.addTextlabel("Input Dir Label")
     .setText("Input Dir")
     .setPosition(textLabelAlignX,firstTextY + textSpaceHeight)
     .setColorValue(0xffffff00)
     .setFont(createFont("Georgia",textFontSize));
  
  inputDataDirPath_textlabel = cp5.addTextlabel(inputDataDirPath_Key)
                                  .setText(textToBeSet)
                                  .setPosition(textPathAlignX,firstTextY + textSpaceHeight)
                                  //.setWidth(textBoxWidth)
                                  .setColorValue(0xffffff00)
                                  .setFont(createFont("Georgia",textFontSize));
  
  if(outputDataDir == null) {
    textToBeSet = "";
  }
  else {
    textToBeSet = outputDataDir.getAbsolutePath();
  }
  
  cp5.addTextlabel("Output Dir Label")
     .setText("Output Dir")
     .setPosition(textLabelAlignX, firstTextY + textSpaceHeight * 2)
     .setColorValue(color(238,115,54))
     .setFont(createFont("Georgia",textFontSize));
  
  outputDataDirPath_textlabel = cp5.addTextlabel(outputDataDirPath_Key)
                                   .setText(textToBeSet)
                                   .setPosition(textPathAlignX,firstTextY + textSpaceHeight * 2)
                                   //.setWidth(textBoxWidth)
                                   .setColorValue(color(238,115,54))
                                   .setFont(createFont("Georgia",textFontSize));
  
  systemStatus_textlabel = cp5.addTextlabel("System Status")
     .setText(SystemStatus.Idle.toString())
     .setPosition(genDataBtnX + 300, genDataBtnY)
     .setColorValue(color(49,171,47))
     .setFont(createFont("Georgia",20));
  
  //Buttons
  inputDataFileSelector = cp5.addButton("To_Select_Input_File")
     .setPosition(buttonAlignX,firstButtonY)
     .setSize(buttonWidth,buttonHeight);
//     .setBroadcast(false)
//     .setValue(ButtonEventCode.InputDataFileSelectorPressed.ordinal())
//     .setBroadcast(true);

  inputDataDirSelector = cp5.addButton("To_Select_Input_Directory")
     .setPosition(buttonAlignX,firstTextY + textSpaceHeight + textAndButtonHeight)
     .setSize(buttonWidth,buttonHeight)
     .setBroadcast(false)
     .setValue(ButtonEventCode.InputDataDirSelectorPressed.ordinal())
     .setBroadcast(true);

  outputDataDirSelector = cp5.addButton("To_Select_Output_Directory")
     .setPosition(buttonAlignX,firstTextY + textSpaceHeight*2 + textAndButtonHeight)
     .setSize(buttonWidth,buttonHeight)
     .setBroadcast(false)
     .setValue(ButtonEventCode.OutputDataDirSelectorPressed.ordinal())
     .setBroadcast(true);
  
  // TODO:generating data button
  generatingDataButton = cp5.addButton("Generating_Button")
     .setPosition(genDataBtnX,genDataBtnY)
     .setSize(buttonWidth,buttonHeight)
     .setBroadcast(false)
     .setValue(ButtonEventCode.GeneratingDataButtonPressed.ordinal())
     .setBroadcast(true);

//  CustomizedButton genDataButton = new CustomizedButton(, 
//                                                        windowWidth/2 - buttonWidth/2, 
//                                                        windowHeight - 70, 
//                                                        buttonWidth, 
//                                                        buttonHeight);

  //Text fields
  // numTrialsToUse_textfield = cp5.addTextfield("numTrialsToUse")
  //                               .setPosition(130,250)
  //                               .setSize(200,19)
  //                               .setFont(createFont("Arial",20))
  //                               .setColor(color(255,0,0));

  //Sliders
  numTrialsToUse_slider = cp5.addSlider("numTrialsToUse") //linked with variable "numTrialsToUse"
                             .setRange(1, NumTrialsPerGesture)
                             .setPosition(50, 200)
                             .setSize(50, 100)
                             .setCaptionLabel("number trials to random")
                             .setNumberOfTickMarks(NumTrialsPerGesture);

  int certainY = firstTextY + textSpaceHeight*2 + textAndButtonHeight + 60;
  int uiSpaceColumn = 60;
  int radioButtonsAlignX = textLabelAlignX - 100;
  //Radio buttons
  //TODO:select which input source(file or directory) to use.
  inputDataSource_radioButton = cp5.addRadioButton("inputDataSourceIndex")
                                   .setPosition(radioButtonsAlignX, firstTextY - 10)
                                   .setSize(40, 40)
                                   .setColorForeground(color(120))
                                   .setColorActive(color(255))
                                   .setColorLabel(0xffffff00)
                                   .setItemsPerRow(1)
                                   .setSpacingRow(50)
                                   .setSpacingColumn(uiSpaceColumn)
                                   .addItem("File",DataSource.SingleFile.ordinal())
                                   .addItem("Dir",DataSource.MultipleFiles.ordinal());
  
  inputDataSource_radioButton.activate(0);
  
  dataFormat_radioButton = cp5.addRadioButton("dataFormatSelector")
                              .setPosition(radioButtonsAlignX, windowHeight - 70)
                              .setSize(40, 40)
                              .setColorForeground(color(120))
                              .setColorActive(color(255))
                              .setColorLabel(0xffffff00)
                              .setItemsPerRow(2)
                              .setSpacingRow(20)
                              .setSpacingColumn(uiSpaceColumn + 100)
                              .addItem("LibSVMAndLinear",DataFormat.LibLinearAndSVM.ordinal())
                              .addItem("GRT",DataFormat.GRT.ordinal());

  dataFormat_radioButton.activate(0);

  //check Boxes
  //checkbox.getItem(i).internalValue()
  //checkbox.getArrayValue()
  //checkbox.activate(i)

  //TODO:Select All and Deselect All Rows
  //we can also use keyPressed to select and deselect
  //checkbox.activate(i)
  //checkbox.deactivate(i)
  
  int uiSpaceHeight = 80;
  
  int firstCheckBoxY = certainY + uiSpaceHeight - 50;

  usedRow_checkBox = cp5.addCheckBox("usedRow") 
                        .setPosition(radioButtonsAlignX, firstCheckBoxY)
                        .setColorForeground(color(120))
                        .setColorActive(color(255))
                        .setColorLabel(color(255))
                        .setSize(40, 40)
                        .setItemsPerRow(10)
                        .setSpacingRow(20)
                        .setSpacingColumn(uiSpaceColumn);

  String prefixName = "Row_";
  for(int i = 0;i < TotalNumRows;i++) {
    usedRow_checkBox.addItem(prefixName + i, i);
  }

  usedTrials_checkBox = cp5.addCheckBox("usedTrial")
                           .setPosition(radioButtonsAlignX, firstCheckBoxY + uiSpaceHeight)
                           .setColorForeground(color(120))
                           .setColorActive(color(255))
                           .setColorLabel(color(255))
                           .setSize(40, 40)
                           .setItemsPerRow(10)
                           .setSpacingRow(20)
                           .setSpacingColumn(uiSpaceColumn);

  prefixName = "Trial_";
  for(int i = 0;i < NumTrialsPerGesture;i++) {
    usedTrials_checkBox.addItem(prefixName + i, i);
  }
  
  usedGestures_checkBox =  cp5.addCheckBox("usedGesture")
                             .setPosition(radioButtonsAlignX, firstCheckBoxY + uiSpaceHeight * 2)
                             .setColorForeground(color(120))
                             .setColorActive(color(255))
                             .setColorLabel(color(255))
                             .setSize(40, 40)
                             .setItemsPerRow(10)
                             .setSpacingRow(20)
                             .setSpacingColumn(uiSpaceColumn);

  prefixName = "G_";
  for(int i = 0;i < NumGestures;i++) {
    usedGestures_checkBox.addItem(prefixName + i, i);
  }
  
  

  cbArray = new CheckBox[]{usedRow_checkBox, usedTrials_checkBox, usedGestures_checkBox};
  
  createMessageBox("init message");
  messageBox.hide();
  
}

Button messageBoxButton;

void createMessageBox(String message) {

  // create a group to store the messageBox elements
  messageBox = cp5.addGroup("Message Box",width/2 - 150,100,300);
  messageBox.setBackgroundHeight(120);
  messageBox.setBackgroundColor(color(128));
  messageBox.hideBar();
  
  // add a TextLabel to the messageBox.
  messageText = cp5.addTextlabel("message text",message,20,20);
  messageText.moveTo(messageBox);

  // add the OK button to the messageBox.
  // the name of the button corresponds to function buttonOK
  // below and will be triggered when pressing the button.
  messageBoxButton = cp5.addButton(ButtonEventCode.MessageBoxButtonPressed.toString(),0,65,80,80,24);
  messageBoxButton.moveTo(messageBox);
  
  // by default setValue would trigger function buttonOK, 
  // therefore we disable the broadcasting before setting
  // the value and enable broadcasting again afterwards.
  // same applies to the cancel button below.
  messageBoxButton.setBroadcast(false);
  messageBoxButton.setValue(ButtonEventCode.MessageBoxButtonPressed.ordinal());
  messageBoxButton.setBroadcast(true);
  messageBoxButton.setCaptionLabel("OK");
  // centering of a label needs to be done manually 
  // with marginTop and marginLeft
  messageBoxButton.captionLabel().style().marginTop = -2;
  messageBoxButton.captionLabel().style().marginLeft = 26;
}

void setMessageText(String contentStr) {
  messageText.setText(contentStr);
} 

//-- Event Handler --

public class ControlEventHandler implements ControlListener{
  
  ControlEventHandler(PApplet pa) {
    cp5.addListener(this);
  }
  
  @Override
  public void controlEvent(ControlEvent ctrlEvent) {
    if(ctrlEvent.isFrom(generatingDataButton.getName())) {
      generatingDataButton.setBroadcast(false);
      systemStatus_textlabel.setText(SystemStatus.Generating_Data.toString());
      println("start generating data");
      generateData();
      println("finish generating data");
      systemStatus_textlabel.setText(SystemStatus.Idle.toString());
      generatingDataButton.setBroadcast(true);
    }
  }
  
}


void MessageBoxButtonPressed(int value) {
  
  messageBox.hide();
  
}

void To_Select_Input_File(int value) {
  
  selectInput("Select a file to be input data file", "inputDataFileSelected");
    
}
  

void To_Select_Output_Directory(int value) {
  
  selectFolder("Select a folder to be output directory", "outputDataFolderSelected");  
  
}

void To_Select_Input_Directory(int value) {
  
  selectFolder("Select a folder to be input data directory", "inputDataFolderSelected");  
  
}

void inputDataFileSelected(File selectedFile) {
  if (selectedFile == null) {
    println("didn't select any file as input file");
  } 
  else {
    inputDataFile = selectedFile;
    updateUI(inputDataFilePath_Key);
  }
}

void inputDataFolderSelected(File selectedFolder) {
  if(selectedFolder == null) {
    println("didn't select any folder as input data folder");
  }
  else {
    inputDataDir = selectedFolder;
    updateUI(inputDataDirPath_Key);
  }
}

void outputDataFolderSelected(File selectedFolder) {
  if(selectedFolder == null) {
    println("didn't select any folder as output data folder");
  }
  else {
    outputDataDir = selectedFolder;
    updateUI(outputDataDirPath_Key);
  }
}


//-- Controller --

ParseCondition mCondition = new ParseCondition();
DataParser parser = new DataParser(NumGestures, NumSamplesPerTrial, NumTrialsPerGesture);
DataFormat[] dataFormatEnums = DataFormat.values();
String fileIDForOutput = "";

void generateData() {
  //feature vectors according to rows selected 
  //num Entries according to numTrialsToUse
  File[] inputFilesToBeProcessed = null;
  int dataSrcOptionIdx = (int)inputDataSource_radioButton.getValue();
  if(dataSrcOptionIdx == DataSource.SingleFile.ordinal()) {
    if(inputDataFile != null) {
      inputFilesToBeProcessed = new File[]{ inputDataFile };
    }
    else {
      setMessageText("input file hasn't been set");
      messageBox.show();
      return;
    }
  }
  else if(dataSrcOptionIdx == DataSource.MultipleFiles.ordinal()){
    if(inputDataDir != null) {
      inputFilesToBeProcessed = inputDataDir.listFiles(); 
    }
    else {
      setMessageText("input directory hasn't been set");
      messageBox.show();
      return;
    }
  }
  else {
    inputFilesToBeProcessed = null;
  }

  mCondition.selectedGestures = getCheckBoxStatusVals(CheckBoxData.gestureNums, 1);
  mCondition.selectedRows = getCheckBoxStatusVals(CheckBoxData.rowNums, 1);
  mCondition.trialNums = getCheckBoxStatusVals(CheckBoxData.trialNums, 1 - DataType.Training.ordinal());
  mCondition.dataFormat = dataFormatEnums[(int)dataFormat_radioButton.getValue()];

  //num trials
  for(File file : inputFilesToBeProcessed) {
    if(filterThisFile(file)) {
      continue;
    }
    try {
      //read file
      parser.parse(file, mCondition);
      fileIDForOutput = String.valueOf(System.currentTimeMillis());
      parser.outputToFile(outputDataDir, getOutputFileName(file, DataType.Training), DataType.Training);
      parser.outputToFile(outputDataDir, getOutputFileName(file, DataType.Testing), DataType.Testing);
    } catch (Exception e) {
      println(e.getLocalizedMessage());
    }
  }

}

boolean filterThisFile(File file) {
  for(String name : fileNameToIgnore) {
    if(file.getName().contains(name)) {
      return true;
    }
  }
  return false; 
}

void updateUI(String uiID) {
  if(uiID.equals(outputDataDirPath_Key)) {
    outputDataDirPath_textlabel.setText(outputDataDir.getAbsolutePath());
  }
  else if(uiID.equals(inputDataFilePath_Key)) {
    inputDataFilePath_textlabel.setText(inputDataFile.getAbsolutePath());
  }
  else if(uiID.equals(inputDataDirPath_Key)) {
    inputDataDirPath_textlabel.setText(inputDataDir.getAbsolutePath());
  }
}

void setDefaultValue(String id) {
  if(id.equals(outputDataDirPath_Key)) {
    outputDataDir = new File(currentSketchPath, "outputData");
    if(!outputDataDir.exists()) {
      outputDataDir.mkdirs();
    }
    else if(!outputDataDir.isDirectory()) {
      setMessageText("outputData is not a directory");
      messageBox.show();
      outputDataDir = null;
    }
  }
  else if(id.equals(inputDataDirPath_Key)) {
    inputDataDir = null;
  }
  else if(id.equals(inputDataFilePath_Key)) {
    inputDataFile = null;
  }

}

void saveConfig() {
  if(inputDataFile != null) {
    config.setString(inputDataFilePath_Key, inputDataFile.getAbsolutePath());
  }

  if(outputDataDir != null) {
    config.setString(outputDataDirPath_Key, outputDataDir.getAbsolutePath());
  }

  if(inputDataDir != null) {
    config.setString(inputDataDirPath_Key, inputDataDir.getAbsolutePath());
  }

  saveJSONObject(config, ConfigFileName);
}

void loadConfig() {
  try {
    config = loadJSONObject(ConfigFileName);  
  } catch (Exception e) {
    println(e.getLocalizedMessage());
    config = null;
  }

  if(config == null) {
    config = new JSONObject(); 
  }
  
  String data;
  try {
    data = config.getString(inputDataFilePath_Key);
  } catch (Exception e) {
    data = null;
  }

  if(!isStringEmpty(data)) {
    try {
      inputDataFile = new File(data);  
    } catch (Exception e) {
      println(e.getLocalizedMessage());
    }
  }
  else {
    setDefaultValue(inputDataFilePath_Key);
  }

  try {
    data = config.getString(outputDataDirPath_Key);
  } catch (Exception e) {
    data = null;
  }
  
  if(!isStringEmpty(data)) {
    try {
      outputDataDir = new File(data);  
    } catch (Exception e) {
      println(e.getLocalizedMessage());
    }
  }
  else {
    setDefaultValue(outputDataDirPath_Key);
  }

  try {
    data = config.getString(inputDataDirPath_Key);  
  } catch (Exception e) {
    data = null;  
  }
  
  if(!isStringEmpty(data)) {
    try {
      inputDataDir = new File(data);
    } catch (Exception e) {
      println(e.getLocalizedMessage());
    }
  }
  else {
    setDefaultValue(inputDataDirPath_Key);
  }

}

void changeCheckBoxAllStatus(boolean activate) {
  CheckBox cb = cbArray[controlCheckBoxDataIndex];
  if(activate) {
    cb.activateAll();
  }
  else {
    cb.deactivateAll();
  }
}

int[] trialNumsForShuffle = new int[NumTrialsPerGesture];

void randomSelectTrialNums(int numValsToSelect) {
  RandomizeArray(trialNumsForShuffle);
  RandomizeArray(trialNumsForShuffle);
  usedTrials_checkBox.deactivateAll();
  for(int i = 0;i < numValsToSelect;i++) {
    usedTrials_checkBox.activate(trialNumsForShuffle[i]);
  }
}

//-- Utility --
String getOutputFileName(File inputFile, DataType dataType) {
  String outputFileName = inputFile.getName();
  if(outputFileName.indexOf(".") > 0) { //trim file extension
    outputFileName = outputFileName.substring(0, outputFileName.lastIndexOf("."));
  }
  int dataTypeIdx = dataType.ordinal();
  outputFileName = fileIDForOutput + 
                   "_" + outputFileName + 
                   "_" + dataTypes[dataTypeIdx] + 
                   "_rows" + getCheckBoxNumsString(CheckBoxData.rowNums, 1) +  
                   "_trials" + getCheckBoxNumsString(CheckBoxData.trialNums , 1 - dataType.ordinal()) +
                   fileExtensionName;
                   
  return outputFileName;
}

int[] getCheckBoxStatusVals(CheckBoxData cbData, int desireValToSelected) {
  ArrayList<Integer> tempContainer = new ArrayList<Integer>();
  CheckBox cb = null;
  if(cbData == CheckBoxData.rowNums) {
    cb = usedRow_checkBox;
  }
  else if(cbData == CheckBoxData.trialNums) {
    cb = usedTrials_checkBox;
  }
  else if(cbData == CheckBoxData.gestureNums) {
    cb = usedGestures_checkBox;
  }
  else {
    cb = null;
  }
  
  float[] values = cb.getArrayValue();
  int numVals = values.length;
  for(int i = 0;i < numVals;i++) {
    if(((int)(values[i])) == desireValToSelected) {
      tempContainer.add(i);
    }
  }
  int numSelectedVals = tempContainer.size();
  int[] mSelectedNums = new int[numSelectedVals];
  for(int i = 0;i < numSelectedVals;i++) {
    mSelectedNums[i] = tempContainer.get(i);
  }
  
  return mSelectedNums;
}

StringBuffer strBuf = new StringBuffer();

String getCheckBoxNumsString(CheckBoxData cbData, int desireValToSelected) {
  strBuf.setLength(0);
  CheckBox cb = null;
  if(cbData == CheckBoxData.rowNums) {
    cb = usedRow_checkBox;
  }
  else if(cbData == CheckBoxData.trialNums) {
    cb = usedTrials_checkBox;
  }
  else if(cbData == CheckBoxData.gestureNums) {
    cb = usedGestures_checkBox;
  }
  else {
    cb = null;
  }

  float[] values = cb.getArrayValue();
  int numVals = values.length;
  for(int i = 0;i < numVals;i++) {
    if(((int)(values[i])) == desireValToSelected) {
      strBuf.append(i);
    }
  }
  return strBuf.toString();
}

boolean isStringEmpty(String testingStr) {
  return (testingStr == null || testingStr.equals(""));
}

public class DisposeHandler {
   
  DisposeHandler(PApplet pa)
  {
    pa.registerMethod("dispose", this);
  }
   
  public void dispose()
  {     
    println("Closing sketch");
    // Place here the code you want to execute on exit
    saveConfig();
  }

}

void RandomizeArray(int[] inputArray){
  Random rgen = new Random(millis());  // Random number generator    
  int numElement = inputArray.length;
  
  for (int i = 0; i < numElement; i++) {
      int randomPosition = rgen.nextInt(numElement);
      int temp = inputArray[i];
      inputArray[i] = inputArray[randomPosition];
      inputArray[randomPosition] = temp;
  }

  return;
}

Set<Set<Integer>> powerSet(Set<Integer> originalSet) {
  Set<Set<Integer>> sets = new HashSet<Set<Integer>>();
  if (originalSet.isEmpty()) {
    sets.add(new HashSet<Integer>());
    return sets;
  }
  List<Integer> list = new ArrayList<Integer>(originalSet);
  Integer head = list.get(0);
  Set<Integer> rest = new HashSet<Integer>(list.subList(1, list.size())); 
  for (Set<Integer> set : powerSet(rest)) {
    Set<Integer> newSet = new HashSet<Integer>();
    newSet.add(head);
    newSet.addAll(set);
    sets.add(newSet);
    sets.add(set);
  }   
  return sets;
}

//void testPwSet() {
//  Set<Integer> mySet = new HashSet<Integer>();
//  mySet.add(1);
//  mySet.add(2);
//  mySet.add(3);
//  Set<Set<Integer>> results = powerSet(mySet);
//  for (Set<Integer> s : results) {
//    for(Integer w : s) {
//      println(w);
//    }
//  }
//}

//-- others


void batchTasks() {
  //CheckBox usedRow_checkBox;
  //CheckBox usedTrials_checkBox;
  ArrayList<Integer[]> rowCombin = new ArrayList<Integer[]>();
  for(int i = 0;i < TotalNumRows;i++) {
    rowCombin.add(new Integer[]{i});
  }
  int numVals = TotalNumRows/2;
  for(int i = 0;i < numVals;i++) {
    rowCombin.add(new Integer[]{i * 2, i * 2 + 1});
  }

  usedTrials_checkBox.deactivateAll();
  for(int i = 0;i < 3;i++) {
    usedTrials_checkBox.activate(i);
  }
  
  for(Integer[] rowConfig : rowCombin) {
    usedRow_checkBox.deactivateAll();
    for(Integer rowNum : rowConfig) {
      usedRow_checkBox.activate(rowNum);
    }
    generateData();
  }
  
  //done
  systemStatus_textlabel.setText(SystemStatus.Idle.toString());
}

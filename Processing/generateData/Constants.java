enum ButtonEventCode {
  MessageBoxButtonPressed,
  InputDataFileSelectorPressed,
  InputDataDirSelectorPressed,
  OutputDataDirSelectorPressed,
  GeneratingDataButtonPressed
};


enum DataType {
  Training,
  Testing
};

enum DataSource {
  SingleFile,
  MultipleFiles
};

enum CheckBoxData {
  gestureNums,
  rowNums,
  trialNums,
  numDataType
};

enum SystemStatus {
  Idle,
  Generating_Data,
  Do_Batching
};

enum DataFormat {
  LibLinearAndSVM,
  GRT
};
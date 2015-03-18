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
  rowNums,
  trialNums,
  numDataType
};

enum SystemStatus {
  Idle,
  Generating_Data
};

enum DataFormat {
  LibLinearAndSVM,
  GRT
};
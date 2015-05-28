#include <SPI.h>
#include <Wire.h>
#include "SGManager.h"
#include "ParserWithAction.h"
#include "RecordButton.h"
#include "ADXL345.h"

SGManager sgManager;
ParserWithAction parser(&sgManager);
RecordButton recordButton;
ADXL345 * accel;

void setup(){
   Serial.begin(38400);
   sgManager.allCalibrationAtConstAmp();
   accel = new ADXL345();
}

void loop(){
   sgManager.serialPrint();
   accel->serialPrintRaw();
   recordButton.checkClick();
   
   Serial.println();
}

void serialEvent(){
   while(Serial.available()){
     parser.parse();
   }
}

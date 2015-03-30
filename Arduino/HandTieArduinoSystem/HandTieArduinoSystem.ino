#include <SPI.h>
#include "SGManager.h"
#include "ParserWithAction.h"
#include "RecordButton.h"

SGManager sgManager;
ParserWithAction parser(&sgManager);
RecordButton recordButton;

void setup(){
   Serial.begin(115200);
   sgManager.allCalibrationAtConstAmp();
}

void loop(){
   sgManager.serialPrint();
   recordButton.checkClick();
}

void serialEvent(){
   while(Serial.available()){
      parser.parse();
   }
}

#include <SPI.h>
#include "SGManager.h"
#include "ParserWithAction.h"
#include "RecordButton.h"

#define RECORD_BUTTON_PIN 6

SGManager sgManager;
ParserWithAction parser(&sgManager);
RecordButton recordButton;

void setup(){
   Serial.begin(115200);
   sgManager.allCalibration();
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

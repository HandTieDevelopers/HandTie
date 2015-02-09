#include <SPI.h>
#include "SGManager.h"
#include "ParserWithAction.h"

SGManager sgManager;
ParserWithAction parser(&sgManager);

void setup(){
   Serial.begin(115200);
//   sgManager.allCalibration();
}

void loop(){
   sgManager.serialPrint();
}

void serialEvent(){
   while(Serial.available()){
      parser.parse();
   }
}

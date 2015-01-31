#include <SPI.h>
#include "SGManager.h"

SGManager sgManager;

void setup()
{
   Serial.begin(115200);
}

void loop()
{
   // delay(1000);
   // sgManager.calibration();
  sgManager.serialPrint();
}

void serialEvent(){
   while(Serial.available()){
      sgManager.manualChangePotPos(Serial.parseInt(), Serial.parseInt());
   }
}

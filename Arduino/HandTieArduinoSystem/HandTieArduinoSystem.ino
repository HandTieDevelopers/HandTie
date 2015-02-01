#include <SPI.h>
#include "SGManager.h"

SGManager sgManager;

void setup(){
   Serial.begin(115200);
   sgManager.calibration();
}

void loop(){
   sgManager.serialPrint();
}

void serialEvent(){
   while(Serial.available()){
      if(Serial.read() == 'c'){
          sgManager.calibration();
      }
   }
}

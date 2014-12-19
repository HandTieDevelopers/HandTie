#include <SPI.h>
#include "SGManager.h"

SGManager * sgManager = new SGManager();

void setup()
{
   Serial.begin(57600);
   Serial.println("setup");
   
}

void loop()
{
   sgManager->calibrationWithPot();
   delay(1000);
   Serial.println("in loop");
   sgManager->serialPrint();
   delay(1000);
}

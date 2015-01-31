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

   // Serial.print("\t newWiper0Pos = ");
   // Serial.print(wiper0Pos);
   // Serial.print("\t newWiper1Pos = ");
   // Serial.print(wiper1Pos);
   // Serial.println();
}

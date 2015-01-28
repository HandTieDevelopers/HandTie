#include <SPI.h>
#include "SGManager.h"

SGManager sgManager;

void setup()
{
  Serial.begin(9600);
  Serial.println("setup");
//  sgManager.calibrationWithPot();
}

void loop()
{
  Serial.println("in loop");
  sgManager.serialPrint();
  delay(1000);
}


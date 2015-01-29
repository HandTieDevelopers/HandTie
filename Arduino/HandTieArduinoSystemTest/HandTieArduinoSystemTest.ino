#include <SPI.h>
#include "SGManager.h"

SGManager sgManager;

void setup()
{   
   Serial.begin(9600);
}

void loop()
{
   sgManager.SerialPrint();

   // Serial.print("\t newWiper0Pos = ");
   // Serial.print(wiper0Pos);
   // Serial.print("\t newWiper1Pos = ");
   // Serial.print(wiper1Pos);
   // Serial.println();
   
   // if(Serial.available()){
   //    wiper0Pos = Serial.parseInt();
   //    wiper1Pos = Serial.parseInt();
   //    mcp4251.wiper0_pos(wiper0Pos);
   //    mcp4251.wiper1_pos(wiper1Pos);
   // }
}

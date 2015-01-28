#include <SPI.h>
#include "MCP4251.h"

#define SS_PIN 53
#define OHM_AB 5040
#define OHM_WIPER 102

//MCP4251 mcp4251(SS_PIN, OHM_AB);
MCP4251 mcp4251(SS_PIN, OHM_AB, OHM_WIPER);
int wiper0Pos = 5;
int wiper1Pos = 77;

void setup(){
   mcp4251.wiper0_pos(wiper0Pos);
   mcp4251.wiper1_pos(wiper1Pos);
   
   Serial.begin(9600);
}

void loop(){
//   mcp4251.wiper0_pos(255);
   Serial.print("newWiper0Pos = ");
   Serial.print(wiper0Pos);
   Serial.print("\t newWiper1Pos = ");
   Serial.println(wiper1Pos);
   Serial.println();
   
   if(Serial.available()){
      wiper0Pos = Serial.parseInt();
      wiper1Pos = Serial.parseInt();
      mcp4251.wiper0_pos(wiper0Pos);
      mcp4251.wiper1_pos(wiper1Pos);
   }
}

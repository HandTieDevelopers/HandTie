#include <SPI.h>
#include "analogmuxdemux.h"
#include "MCP4251.h"

//MCP4251 macros
#define POT_SS_PIN 53
#define OHM_AB 5040
#define OHM_WIPER 102

//analogmuxdemux
#define MS0 2
#define MS1 3
#define MS2 4
#define READPIN A0
#define NUM_OF_MUX_PIN 8
#define MUX1_CS_PIN 5
#define MUX2_CS_PIN 6

AnalogMux analogMux(MS0, MS1, MS2, READPIN);

MCP4251 mcp4251(POT_SS_PIN, OHM_AB, OHM_WIPER);
int wiper0Pos = 5;
int wiper1Pos = 77;


void setup()
{
   mcp4251.wiper0_pos(wiper0Pos);
   mcp4251.wiper1_pos(wiper1Pos);
   pinMode(MUX1_CS_PIN, OUTPUT);
   pinMode(MUX2_CS_PIN, OUTPUT);
   digitalWrite(MUX1_CS_PIN, LOW);
   digitalWrite(MUX2_CS_PIN, HIGH);
   
   Serial.begin(9600);
}

void loop()
{
   digitalWrite(MUX1_CS_PIN, LOW);
   digitalWrite(MUX2_CS_PIN, HIGH);
   for(int i=0; i<NUM_OF_MUX_PIN; i++){
       Serial.print(analogMux.AnalogRead(i));
       Serial.print("\t");
//       delay(1000);
   }

   digitalWrite(MUX1_CS_PIN, HIGH);
   digitalWrite(MUX2_CS_PIN, LOW);
   for(int i=0; i<NUM_OF_MUX_PIN; i++){
       Serial.print(analogMux.AnalogRead(i));
       Serial.print("\t");
//       delay(1000);
   }

//   Serial.println();
//   if(muxCSPinStatus)
//       Serial.print("\n");
//   muxCSPinStatus = !muxCSPinStatus;
//   digitalWrite(MUX1_CS_PIN, muxCSPinStatus);

//   Serial.print(analogMux.AnalogRead(4));
   Serial.print("\t newWiper0Pos = ");
   Serial.print(wiper0Pos);
   Serial.print("\t newWiper1Pos = ");
   Serial.print(wiper1Pos);
   Serial.println();
   
   if(Serial.available()){
      wiper0Pos = Serial.parseInt();
      wiper1Pos = Serial.parseInt();
      mcp4251.wiper0_pos(wiper0Pos);
      mcp4251.wiper1_pos(wiper1Pos);
   }
}

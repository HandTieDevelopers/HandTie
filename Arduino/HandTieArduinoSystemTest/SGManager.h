#ifndef SGManager_h
#define SGManager_h

#include <Arduino.h>
#include "analogmuxdemux.h"
#include "MCP4251.h"

// --------- AnalogMux Macro Define --------- //
#define NUM_OF_MUX 1
#define NUM_OF_MUX_PIN 8

#define MUX_CS_PIN 5

#define MS0 2
#define MS1 3
#define MS2 4
#define READPIN A0

// ---------   MCP4251 Macro Define --------- //
#define POT_SS_PIN 53
#define OHM_AB 5040
#define OHM_WIPER 102

#define WIPER0_INIT_POS 30
#define WIPER1_INIT_POS 85

// ------------- SGManager class ------------ //

class SGManager{

public:
   SGManager();
   ~SGManager();

   void SerialPrint();

private:
   AnalogMux * analogMux;
   MCP4251 * mcp4251;

};

#endif   //SGManager_h
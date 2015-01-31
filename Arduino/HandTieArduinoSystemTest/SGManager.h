#ifndef SGManager_h
#define SGManager_h

#include <Arduino.h>
#include "analogmuxdemux.h"
#include "MCP4251.h"
#include "StrainGauge.h"

// --------- AnalogMux Macro Define --------- //
#define NUM_OF_MUX 2
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

#define WIPER0_INIT_POS 50
#define WIPER1_INIT_POS 85

#define TARGET_NO_AMP 20
#define TARGET_WITH_AMP 295
#define TARGET_TOLERANCE_NO_AMP 5
#define TARGET_TOLERANCE_WITH_AMP 10

// -------- StrainGauge Macro Define -------- //
#define NUM_OF_GAUGES 16

// ------------- SGManager class ------------ //

class SGManager{

public:
   SGManager();
   ~SGManager();

   void serialPrint();
   void calibration();
   void manualChangePotPos(uint8_t, uint8_t);

private:
   AnalogMux * analogMux;
   MCP4251 * mcp4251;
   StrainGauge * gauges[NUM_OF_GAUGES];

   void calibrateBridgePot(int, int);
   void calibrateAmpPot(int, int);

};

#endif   //SGManager_h
#ifndef SGManager_h
#define SGManager_h

#include <Arduino.h>
#include "analogmuxdemux.h"
#include "MCP4251.h"
#include "StrainGauge.h"

// --------- AnalogMux Macro Define --------- //
#define SS0 2
#define SS1 3
#define SS2 4
#define MS0 5
#define MS1 255
#define MS2 255
#define READPIN A0

// ---------   MCP4251 Macro Define --------- //
#define POT_SS_PIN 53
#define OHM_AB 5040
#define OHM_WIPER 102

#define WIPER0_INIT_POS 255
#define WIPER1_INIT_POS 255

// #define TARGET_NO_AMP 20
// #define TARGET_WITH_AMP 295
#define TARGET_TOLERANCE_NO_AMP 1
#define TARGET_TOLERANCE_WITH_AMP 5

// -------- StrainGauge Macro Define -------- //
#define NUM_OF_GAUGES 16
// #define BROKEN_OMIT

// ------------- Serial Protocol ------------ //
enum{
   SEND_NORMAL_VALS,
   SEND_CALI_VALS,

   SEND_TARGET_NO_AMP_VALS,
   SEND_TARGET_AMP_VALS,

   SEND_BRIDGE_POT_POS_VALS,
   SEND_AMP_POT_POS_VALS,

   SEND_CALIBRATING_NO_AMP_VALS,
   SEND_CALIBRATING_AMP_VALS
};

// ------------- SGManager class ------------ //

class SGManager{

public:
   SGManager();
   ~SGManager();

   void serialPrint();
   void serialPrint(int);

   void sendTargetValsNoAmp();
   void sendTargetValsWithAmp();
   // void sendBridgePotPosVals();
   // void sendAmpPotPosVals();

   void allCalibration();

   void manualAssignBridgePotPosForOneGauge(uint8_t, uint8_t);
   void manualAssignAmpPotPosForOneGauge(uint8_t, uint8_t);

   void manualAssignTargetValNoAmpForOneGauge(uint8_t, uint16_t);
   void manualAssignTargetValWithAmpForOneGauge(uint8_t, uint16_t);

   void manualAssignTargetValNoAmpForAllGauges(uint16_t);
   void manualAssignTargetValWithAmpForAllGauges(uint16_t);

private:
   AnalogMux * analogMux;
   MCP4251 * mcp4251;
   StrainGauge * gauges[NUM_OF_GAUGES];

   void calibration();
   boolean calibrateBridgePot(int);
   boolean calibrateAmpPot(int);

   void sendStoredValues(int);

};

#endif   //SGManager_h

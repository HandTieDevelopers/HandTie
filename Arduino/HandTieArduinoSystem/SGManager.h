#ifndef SGManager_h
#define SGManager_h

#include <Arduino.h>
#include "analogmuxdemux.h"
#include "MCP4251.h"
#include "StrainGauge.h"
#include "SerialProtocol.h"
#include "Filter.h"

// --------- AnalogMux Macro Define --------- //
#define SS0 2
#define SS1 3
#define SS2 4
#define MS0 5
#define MS1 6
#define MS2 7
#define READPIN A0

// ---------   MCP4251 Macro Define --------- //
#define POT_SS_PIN 10
#define OHM_AB 5040
#define OHM_WIPER 102

#define WIPER0_INIT_POS 2
#define WIPER1_INIT_POS 255

// #define TARGET_NO_AMP 20
// #define TARGET_WITH_AMP 295
#define TARGET_TOLERANCE_NO_AMP 1
#define TARGET_TOLERANCE_WITH_AMP 5

// -------- StrainGauge Macro Define -------- //
#define NUM_OF_GAUGES 19
#define CALI_TIMEOUT ((unsigned long)10000)
// #define BROKEN_OMIT

#define TARGET_VAL_MIN_AMP 15
#define TARGET_VAL_WITH_AMP 300

// ------------- SGManager class ------------ //

class SGManager{

public:
   SGManager();
   ~SGManager();

   void serialPrint();
   void serialPrint(int);

   void sendStoredValues(int);

   void allCalibration();
   void allCalibrationAtConstAmp();

   void manualAssignBridgePotPosForOneGauge(uint8_t, uint8_t);
   void manualAssignAmpPotPosForOneGauge(uint8_t, uint8_t);

   void manualAssignBridgePotPosForAllGauges(uint8_t);
   void manualAssignAmpPotPosForAllGauges(uint8_t);

   void manualAssignTargetValMinAmpForOneGauge(uint8_t, uint16_t);
   void manualAssignTargetValWithAmpForOneGauge(uint8_t, uint16_t);
   void manualAssignTargetValAtConstAmpForOneGauge(uint8_t, uint16_t);

   void manualAssignTargetValMinAmpForAllGauges(uint16_t);
   void manualAssignTargetValWithAmpForAllGauges(uint16_t);
   void manualAssignTargetValAtConstAmpForAllGauges(uint16_t);

private:
   AnalogMux * analogMux;
   MCP4251 * mcp4251;
   StrainGauge * gauges[NUM_OF_GAUGES];
   FilterConfig* config;

   unsigned long startCaliTime;

   boolean isCalibratingBridgeAtMinAmp;
   boolean isCalibratingAmpAtConstBridge;
   boolean isCalibratingBridgeAtConstAmp;

   void calibrateBridgeAtMinAmp();
   void calibrateAmpAtConstBridge();
   void calibrateBridgeAtConstAmp();

   boolean calibrateBridgePotMinAmp(int);
   boolean calibrateAmpPotAtConstBridge(int);
   boolean calibrateBridgePotAtConstAmp(int);

   void sendCalibratedInfo();

};

#endif   //SGManager_h

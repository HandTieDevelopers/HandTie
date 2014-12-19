#include "StrainGauge.h"
#include "MCP4251.h"
#include "analogmuxdemux.h"

// Digital Potentiometer Macro Define
#define NUM_OF_MCP4251 3
#define MIN_CS_PIN 10
#define POT_RESISTOR 5000
#define TARGET_ANALOG_VAL_TOLER 0.1
#define TARGET_POSITIVE_TOLER(TARGET_ANALOG_VAL) (TARGET_ANALOG_VAL)*(1+TARGET_ANALOG_VAL_TOLER)
#define TARGET_NEGATIVE_TOLER(TARGET_ANALOG_VAL) (TARGET_ANALOG_VAL)*(1-TARGET_ANALOG_VAL_TOLER)
#define MAX_TIME_CALIBRATION 5000
#define INITIAL_POSITION 137

// Analog Multiplexer Macro Define
#define NUM_OF_MUX 1
// master selects
#define M_S0 6
#define M_S1 6
#define M_S2 6
// slave selects
#define S_S0 3
#define S_S1 4
#define S_S2 5
// read pin
#define MIN_READPIN 0


// Strain Gauge
#define NUM_OF_GAUGES 5
#define TARGET_ANALOG_VAL_NO_AMP 50
#define TARGET_ANALOG_VAL_WITH_AMP 150

class SGManager
{
public:
   // -------------- Constructor ------------------//
   SGManager();
   ~SGManager();

   // -------------- Calibration ------------------//
   void calibrationWithoutPot();
   void calibrationWithPot();

   // -------------- Serial Print -----------------//
   void serialPrint();

   // -------- Parse Message from Serial ----------//
   // void parseMessage(char * message);

   // ---------- For Testing and Debug ------------//
   void setTargetValuesForSG();

private:
   StrainGauge * gauges[NUM_OF_GAUGES];
   MCP4251 * mcp4251s[NUM_OF_MCP4251];
   AnalogMux * amxes[NUM_OF_MUX];

   // -------------- Calibration ------------------//
   void calibratingBridge();
   void calibratingAmp();

};

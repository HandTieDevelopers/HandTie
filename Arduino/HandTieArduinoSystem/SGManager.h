#include "StrainGauge.h"
#include "MCP4251.h"
#include "analogmuxdemux.h"

// Digital Potentiometer Macro Define
#define CS_PIN 53
#define POT_RESISTOR 5000
#define TARGET_ANALOG_VAL_TOLER 0.1
#define TARGET_POSITIVE_TOLER(TARGET_ANALOG_VAL) (TARGET_ANALOG_VAL)*(1+TARGET_ANALOG_VAL_TOLER)
#define TARGET_NEGATIVE_TOLER(TARGET_ANALOG_VAL) (TARGET_ANALOG_VAL)*(1-TARGET_ANALOG_VAL_TOLER)
#define MAX_TIME_CALIBRATION 5000
#define INITIAL_POSITION 137

// Analog Multiplexer Macro Define
// master selects
#define M_S0 6
#define M_S1 6
#define M_S2 6
// slave selects
#define S_S0 3
#define S_S1 4
#define S_S2 5
// read pin
#define READPIN 0

class SGManager
{
public:
   SGManager(uint8_t gaugePin, uint8_t numOfGauges);    //with multiplexer on gaugePin
   SGManager(uint8_t * gaugePins, uint8_t numOfGauges); //without multiplexer
   ~SGManager();

   void calibrationWithoutPot();
   void calibrationWithPot();

private:
   uint8_t numOfGauges;
   StrainGauge * gauges;

   MCP4251 * mcp4251;

   AnalogMux * amx;

   void calibratingBridge();
   void calibratingAmp();

};
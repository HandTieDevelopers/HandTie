#include "StrainGauge.h"
#include "MCP4251.h"

// Digital Potentiometer Parameters
#define CS_PIN 53
#define TARGET_ANALOG_VAL_TOLER 0.1
#define TARGET_POSITIVE_TOLER(TARGET_ANALOG_VAL) (TARGET_ANALOG_VAL)*(1+TARGET_ANALOG_VAL_TOLER)
#define TARGET_NEGATIVE_TOLER(TARGET_ANALOG_VAL) (TARGET_ANALOG_VAL)*(1-TARGET_ANALOG_VAL_TOLER)
#define MAX_TIME_CALIBRATION 5000
#define INITIAL_POSITION 137

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
};
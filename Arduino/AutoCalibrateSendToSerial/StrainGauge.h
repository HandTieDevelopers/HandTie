#ifndef STRAIN_GAUGE_H
#define STRAIN_GAUGE_H

#include <Arduino.h>

class StrainGauge
{
public:
   StrainGauge();
   StrainGauge(uint8_t pin);
   ~StrainGauge();
   
   uint16_t AnalogRead();
   float getNormalizedVal();

   uint16_t getTargetCaliVal();

   uint16_t getBridgePotPos();
   uint16_t getAmpPotPos();

   void setPin(uint8_t pin);
   void setTargetValues(uint16_t targetCaliValsNoAmp, uint16_t targetCaliVals);
   void resetCalibrateBaseVal();
   void setCalibratedValues(uint16_t caliVal,
                            uint16_t bridgePotPos,
                            uint16_t ampPotPos);

private:
   uint8_t pin;

   uint16_t targetCaliValsNoAmp;
   uint16_t targetCaliVals;
   
   uint16_t caliVal;
   uint16_t bridgePotPos;
   uint16_t ampPotPos;
};

#endif //STRAIN_GAUGE_H
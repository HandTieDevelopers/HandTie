#ifndef STRAIN_GAUGE_H
#define STRAIN_GAUGE_H

#include <Arduino.h>

class StrainGauge
{
public:
   StrainGauge();
   StrainGauge(uint8_t pin);
   ~StrainGauge();
   
   uint16_t getAnalogVal();
   float getNormalizedVal();

   uint16_t getBridgePotPos();
   uint16_t getAmpPotPos();

   void setPin(uint8_t pin);
   void setTargetCalibrateBaseVal(uint16_t targetCaliVal);
   void resetCalibrateBaseVal();
   void setCalibratedValues(uint16_t caliVal,
                            uint16_t bridgePotPos,
                            uint16_t ampPotPos);

private:
   uint8_t pin;

   uint16_t targetCaliVal;
   uint16_t caliVal;
   uint16_t bridgePotPos;
   uint16_t ampPotPos;
};

#endif //STRAIN_GAUGE_H
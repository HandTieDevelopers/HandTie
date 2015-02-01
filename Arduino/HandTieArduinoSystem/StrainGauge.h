#ifndef StrainGauge_h
#define StrainGauge_h

#include <Arduino.h>

class StrainGauge
{
public:
   StrainGauge();
   StrainGauge(uint8_t, uint8_t);
   ~StrainGauge();

   void setAmpPotPos(uint8_t);
   uint8_t getAmpPotPos();

   void setBridgePotPos(uint8_t);
   uint8_t getBridgePotPos();

private:
   uint8_t ampPotPos;
   uint8_t bridgePotPos;
};

#endif   //StrainGauge_h

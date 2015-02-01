#ifndef StrainGauge_h
#define StrainGauge_h

#include <Arduino.h>

class StrainGauge
{
public:
   StrainGauge();
   StrainGauge(uint8_t, uint8_t, uint8_t, uint8_t);
   ~StrainGauge();

   void setAmpPotPos(uint8_t);
   uint8_t getAmpPotPos();

   void setBridgePotPos(uint8_t);
   uint8_t getBridgePotPos();

   void setTargetValNoAmp(uint8_t);
   uint8_t getTargetValNoAmp();

   void setTargetValWithAmp(uint8_t);
   uint8_t getTargetValWithAmp();

private:
   uint8_t ampPotPos;
   uint8_t bridgePotPos;

   uint8_t targetValNoAmp;
   uint8_t targetValWithAmp;
};

#endif   //StrainGauge_h

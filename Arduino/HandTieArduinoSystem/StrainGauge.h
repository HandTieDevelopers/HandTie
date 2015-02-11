#ifndef StrainGauge_h
#define StrainGauge_h

#include <Arduino.h>

class StrainGauge
{
public:
   StrainGauge();
   StrainGauge(uint8_t, uint8_t, uint16_t, uint16_t);
   ~StrainGauge();

   void setAmpPotPos(uint8_t);
   uint8_t getAmpPotPos();

   void setBridgePotPos(uint8_t);
   uint8_t getBridgePotPos();

   void setTargetValNoAmp(uint16_t);
   uint16_t getTargetValNoAmp();

   void setTargetValWithAmp(uint16_t);
   uint16_t getTargetValWithAmp();

   void setBridgeCaliNeeded();
   void setBridgeCaliComplete();
   boolean isBridgeCaliComplete();

   void setAmpCaliNeeded();
   void setAmpCaliComplete();
   boolean isAmpCaliComplete();

   void setBroken();
   boolean isBroken();

   uint16_t* getInputVals();
   const static uint32_t numValsToCached = 5;

   void updateInputVals(uint16_t val);

private:
   uint8_t ampPotPos;
   uint8_t bridgePotPos;

   uint16_t targetValNoAmp;
   uint16_t targetValWithAmp;

   boolean bridgeCaliComplete;
   boolean ampCaliComplete;

   boolean broken;

   uint16_t inputVals[numValsToCached];
   uint32_t currentIndexToUpdate;
};

#endif   //StrainGauge_h

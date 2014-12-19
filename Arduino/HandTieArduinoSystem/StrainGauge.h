#ifndef STRAIN_GAUGE_H
#define STRAIN_GAUGE_H

#include <Arduino.h>

class StrainGauge
{
public:
   // -------------- Constructor ------------------//
   StrainGauge(uint8_t pin, uint16_t targetCaliValNoAmp, uint16_t targetCaliVal);
   ~StrainGauge();
   
   // ----------------- Getter --------------------//
   uint16_t AnalogRead();
   float getNormalizedVal();

   uint16_t getTargetCaliVal();
   uint16_t getTargetCaliValNoAmp();

   uint16_t getBridgePotPos();
   uint16_t getAmpPotPos();

   // ----------------- Setter --------------------//
   void setPin(uint8_t pin);
   void setTargetValues(uint16_t targetCaliValNoAmp, uint16_t targetCaliVal);
   void resetCalibrateBaseVal();
   
   void setCaliVal(uint16_t caliVal);
   void setBridgePotPos(uint16_t bridgePotPos);
   void setAmpPotPos(uint16_t ampPotPos);

private:
   uint8_t pin;

   // ---------------- Calibration ----------------//
   uint16_t targetCaliValNoAmp;
   uint16_t targetCaliVal;
   
   uint16_t caliVal;
   uint16_t bridgePotPos;
   uint16_t ampPotPos;
};

#endif //STRAIN_GAUGE_H
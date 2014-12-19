#include "StrainGauge.h"

// ----------------------------- Constructor ------------------------------------//
StrainGauge::StrainGauge(uint8_t pin, uint16_t targetCaliValNoAmp, uint16_t targetCaliVal){
   this->pin = pin;
   this->targetCaliValNoAmp = targetCaliValNoAmp;
   this->targetCaliVal = targetCaliVal;
}

// --------------------------------- Getter -------------------------------------//
uint16_t StrainGauge::AnalogRead(){
   return analogRead(pin);
}

float StrainGauge::getNormalizedVal(){
   return analogRead(pin)/caliVal;
}

uint16_t StrainGauge::getTargetCaliValNoAmp(){
  return targetCaliValNoAmp;
}

uint16_t StrainGauge::getTargetCaliVal(){
  return targetCaliVal;
}

uint16_t StrainGauge::getBridgePotPos(){
   return bridgePotPos;
}

uint16_t StrainGauge::getAmpPotPos(){
   return ampPotPos;
}

// --------------------------------- Setter -------------------------------------//
void StrainGauge::setPin(uint8_t pin){
   this->pin = pin;
}

void StrainGauge::setTargetValues(uint16_t targetCaliValNoAmp, uint16_t targetCaliVal){
   this->targetCaliValNoAmp = targetCaliValNoAmp;
   this->targetCaliVal = targetCaliVal;
}

void StrainGauge::resetCalibrateBaseVal(){
   caliVal = analogRead(pin);
}

void StrainGauge::setCaliVal(uint16_t caliVal){
  this->caliVal = caliVal;
}

void StrainGauge::setBridgePotPos(uint16_t bridgePotPos){
  this->bridgePotPos = bridgePotPos;
}

void StrainGauge::setAmpPotPos(uint16_t ampPotPos){
  this->ampPotPos = ampPotPos;
}

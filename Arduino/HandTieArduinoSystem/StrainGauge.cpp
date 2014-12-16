#include "StrainGauge.h"

StrainGauge::StrainGauge(){
   pin = 0;
}

StrainGauge::StrainGauge(uint8_t pin){
   this->pin = pin;
}

uint16_t StrainGauge::getAnalogVal(){
   return analogRead(pin);
}

float StrainGauge::getNormalizedVal(){
   return analogRead(pin)/caliVal;
}

uint16_t StrainGauge::getBridgePotPos(){
   return bridgePotPos;
}

uint16_t StrainGauge::getAmpPotPos(){
   return ampPotPos;
}

void StrainGauge::setPin(uint8_t pin){
   this->pin = pin;
}

void StrainGauge::setTargetCalibrateBaseVal(uint16_t targetCaliVal){
   this->targetCaliVal = targetCaliVal;
}

void StrainGauge::resetCalibrateBaseVal(){
   caliVal = analogRead(pin);
}

void StrainGauge::setCalibratedValues(uint16_t caliVal,
                                      uint16_t bridgePotPos,
                                      uint16_t ampPotPos){
   this->caliVal = caliVal;
   this->bridgePotPos = bridgePotPos;
   this->ampPotPos = ampPotPos;
}

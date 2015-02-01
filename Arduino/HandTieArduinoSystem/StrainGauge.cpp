#include "StrainGauge.h"

StrainGauge::StrainGauge(){

}

StrainGauge::StrainGauge(uint8_t ampPotPos, uint8_t bridgePotPos){
   this->ampPotPos = ampPotPos;
   this->bridgePotPos = bridgePotPos;
}

StrainGauge::~StrainGauge(){

}

void StrainGauge::setAmpPotPos(uint8_t ampPotPos){
   this->ampPotPos = ampPotPos;
}

uint8_t StrainGauge::getAmpPotPos(){
   return ampPotPos;
}

void StrainGauge::setBridgePotPos(uint8_t bridgePotPos){
   this->bridgePotPos = bridgePotPos;
}

uint8_t StrainGauge::getBridgePotPos(){
   return bridgePotPos;
}

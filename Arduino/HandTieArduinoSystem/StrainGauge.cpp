#include "StrainGauge.h"

StrainGauge::StrainGauge(){

}

StrainGauge::StrainGauge(uint8_t ampPotPos, uint8_t bridgePotPos, uint8_t targetValNoAmp,
                         uint8_t targetValWithAmp){
   this->ampPotPos = ampPotPos;
   this->bridgePotPos = bridgePotPos;
   this->targetValNoAmp = targetValNoAmp;
   this->targetValWithAmp = targetValWithAmp;
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

void StrainGauge::setTargetValNoAmp(uint8_t targetVal){
   this->targetValNoAmp = targetVal;
}

uint8_t StrainGauge::getTargetValNoAmp(){
   return targetValNoAmp;
}

void StrainGauge::setTargetValWithAmp(uint8_t targetVal){
   this->targetValWithAmp = targetVal;
}

uint8_t StrainGauge::getTargetValWithAmp(){
   return targetValWithAmp;
}
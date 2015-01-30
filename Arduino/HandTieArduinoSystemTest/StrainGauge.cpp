#include "StrainGauge.h"

StrainGauge::StrainGauge(){

}

StrainGauge::~StrainGauge(){

}

void StrainGauge::setAmpPotPos(int ampPotPos){
   this->ampPotPos = ampPotPos;
}

int StrainGauge::getAmpPotPos(){
   return ampPotPos;
}

void StrainGauge::setBridgePotPos(int bridgePotPos){
   this->bridgePotPos = bridgePotPos;
}

int StrainGauge::getBridgePotPos(){
   return bridgePotPos;
}

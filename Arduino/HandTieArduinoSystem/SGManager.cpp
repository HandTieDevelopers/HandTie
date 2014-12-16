#include "SGManager.h"

SGManager::SGManager(uint8_t gaugePin, uint8_t numOfGauges){
   this->numOfGauges = numOfGauges;
   gauges = new StrainGauge[numOfGauges];
   for (int i = 0; i < numOfGauges; ++i){
      gauges[i].setPin(gaugePin);
   }
}

SGManager::SGManager(uint8_t * gaugePins, uint8_t numOfGauges){
   this->numOfGauges = numOfGauges;
   gauges = new StrainGauge[numOfGauges];
   for (int i = 0; i < numOfGauges; ++i){
      gauges[i].setPin(gaugePins[i]);
   }
}

SGManager::~SGManager(){
   delete(gauges);
   delete(mcp4251);
}

void SGManager::calibrationWithoutPot(){
   for (int i = 0; i < numOfGauges; ++i){
      gauges[i].resetCalibrateBaseVal();
   }
}

void SGManager::calibrationWithPot(){
   for (int i = 0; i < numOfGauges; ++i){

   }
}
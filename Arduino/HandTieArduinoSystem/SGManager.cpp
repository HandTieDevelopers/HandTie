#include "SGManager.h"

SGManager::SGManager(){
   uint16_t targetValNoAmp[] = {20,20,20,20,20,20,20,20,
                                20,20,20,20,20,20,20,20};
   uint16_t targetValWithAmp[] = {400,400,400,400,400,400,400,400,
                                  400,400,400,400,400,400,400,400};

   analogMux = new AnalogMux(MS0, MS1, MS2, SS0, SS1, SS2, READPIN);
   mcp4251 = new MCP4251(POT_SS_PIN, OHM_AB, OHM_WIPER);
   
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      gauges[i] = new StrainGauge(WIPER0_INIT_POS, WIPER1_INIT_POS,
                                  targetValNoAmp[i], targetValWithAmp[i]);
   }

   mcp4251->wiper0_pos(WIPER0_INIT_POS);
   mcp4251->wiper1_pos(WIPER1_INIT_POS);
}

SGManager::~SGManager(){
   delete(analogMux);
   delete(mcp4251);

   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      delete(gauges[i]);
   }
}

void SGManager::serialPrint(int protocol){
   Serial.print(protocol);
   Serial.print(" ");
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      mcp4251->wiper0_pos(gauges[i]->getAmpPotPos());
      mcp4251->wiper1_pos(gauges[i]->getBridgePotPos());
      Serial.print(analogMux->AnalogRead(i));
      Serial.print(" ");
   }
   Serial.println();
}

void SGManager::sendTargetValNoAmp(){
   Serial.print(SEND_TARGET_NO_AMP_VALS);
   Serial.print(" ");
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
       Serial.print(gauges[i]->getTargetValNoAmp());
       Serial.print(" ");
   }
   Serial.println();
}

void SGManager::sendTargetValWithAmp(){
   Serial.print(SEND_TARGET_AMP_VALS)
   Serial.print(" ");
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
       Serial.print(gauges[i]->getTargetValWithAmp());
       Serial.print(" ");
   }
   Serial.println();
}

void SGManager::allCalibration(){
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      gauges[i]->setBridgeCaliNeeded();
      gauges[i]->setAmpCaliNeeded();
   }
   calibration();
}

void SGManager::calibration(){
   boolean complete = false;
   while(!complete){
      complete = true;
      for (int i = 0; i < NUM_OF_GAUGES; ++i){
         if (!calibrateBridgePot(i))
            complete = false;
      }
   }

   complete = false;
   while(!complete){
      complete = true;
      for (int i = 0; i < NUM_OF_GAUGES; ++i){
         if (!calibrateAmpPot(i))
            complete = false;
      }
   }
   serialPrint(SEND_CALI_VALS);
}

boolean SGManager::calibrateBridgePot(int i){
   uint16_t potPos = gauges[i]->getBridgePotPos();
   mcp4251->wiper0_pos(255);
   mcp4251->wiper1_pos((uint8_t)potPos);

   uint16_t analogVal = analogMux->AnalogRead(i);
   #ifdef BROKEN_OMIT
   if (gauges[i]->isBridgeCaliComplete() || gauges[i]->isBroken())
   #else
   if (gauges[i]->isBridgeCaliComplete())
   #endif   
      return true;
   
   if (analogVal < gauges[i]->getTargetValNoAmp() - TARGET_TOLERANCE_NO_AMP){
      potPos--;
   } else if (analogVal > gauges[i]->getTargetValNoAmp() + TARGET_TOLERANCE_NO_AMP){
      potPos++;
   } else {
      gauges[i]->setBridgeCaliComplete();
   }

   gauges[i]->setBridgePotPos((uint8_t)potPos);

   if (potPos < 0 || potPos > 255){
      gauges[i]->setBridgeCaliComplete();
      gauges[i]->setBroken();
   }

   return gauges[i]->isBridgeCaliComplete();
}

boolean SGManager::calibrateAmpPot(int i){
   uint16_t potPos = gauges[i]->getAmpPotPos();
   mcp4251->wiper0_pos((uint8_t)potPos);
   mcp4251->wiper1_pos(gauges[i]->getBridgePotPos());

   uint16_t analogVal = analogMux->AnalogRead(i);
   #ifdef BROKEN_OMIT
   if (gauges[i]->isAmpCaliComplete() || gauges[i]->isBroken())
   #else
   if (gauges[i]->isAmpCaliComplete())
   #endif
      return true;
   
   if (analogVal < gauges[i]->getTargetValWithAmp() - TARGET_TOLERANCE_WITH_AMP){
      potPos--;
   } else if (analogVal > gauges[i]->getTargetValWithAmp() + TARGET_TOLERANCE_WITH_AMP){
      potPos++;
   } else {
      gauges[i]->setAmpCaliComplete();
   }

   gauges[i]->setAmpPotPos((uint8_t)potPos);

   if (potPos < 0 || potPos > 255){
      gauges[i]->setAmpCaliComplete();
      gauges[i]->setBroken();
   }

   return gauges[i]->isAmpCaliComplete();
}

void SGManager::manualAssignPotPosForOneGauge(uint8_t gaugeIdx, uint8_t bridgePotPos,
                                              uint8_t ampPotPos){
   gauges[gaugeIdx]->setBridgePotPos(bridgePotPos);
   gauges[gaugeIdx]->setAmpPotPos(ampPotPos);
}

void SGManager::manualAssignTargetValNoAmpForOneGauge(uint8_t gaugeIdx, uint16_t targetVal){
   gauges[gaugeIdx]->setTargetValNoAmp(targetVal);
   gauges[gaugeIdx]->setBridgeCaliNeeded();
   calibration();
}

void SGManager::manualAssignTargetValWithAmpForOneGauge(uint8_t gaugeIdx, uint16_t targetVal){
   gauges[gaugeIdx]->setTargetValWithAmp(targetVal);
   gauges[gaugeIdx]->setAmpCaliNeeded();
   calibration();
}

void SGManager::manualAssignTargetValNoAmpForAllGauges(uint16_t targetVal){
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      gauges[i]->setTargetValNoAmp(targetVal);
      gauges[i]->setBridgeCaliNeeded();
   }
   calibration();
}

void SGManager::manualAssignTargetValWithAmpForAllGauges(uint16_t targetVal){
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      gauges[i]->setTargetValWithAmp(targetVal);
      gauges[i]->setAmpCaliNeeded();
   }
   calibration();
}
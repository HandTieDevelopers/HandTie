#include "SGManager.h"

SGManager::SGManager(){
   uint16_t targetValNoAmp[] = {15,15,15,15,15,15,15,15,
                                15,15,15,15,15,15,15,15};
   uint16_t targetValWithAmp[] = {300,300,300,300,300,300,300,300,
                                  300,300,300,300,300,300,300,300};

   analogMux = new AnalogMux(MS0, MS1, MS2, SS0, SS1, SS2, READPIN);
   mcp4251 = new MCP4251(POT_SS_PIN, OHM_AB, OHM_WIPER);
   
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      gauges[i] = new StrainGauge(WIPER0_INIT_POS, WIPER1_INIT_POS,
                                  targetValNoAmp[i], targetValWithAmp[i]);
   }

   mcp4251->wiper0_pos(WIPER0_INIT_POS);
   mcp4251->wiper1_pos(WIPER1_INIT_POS);

   config = new FilterConfig();
   config->filterType = MEDIAN_FILTER;

}

SGManager::~SGManager(){
   delete(analogMux);
   delete(mcp4251);

   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      delete(gauges[i]);
   }

   delete(config);
}

void SGManager::serialPrint(){
   serialPrint(SEND_NORMAL_VALS);
}

void SGManager::serialPrint(int protocol){
   Serial.print(protocol);
   Serial.print(" ");
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      if (protocol == SEND_CALIBRATING_NO_AMP_VALS)
         mcp4251->wiper0_pos(255);
      else
         mcp4251->wiper0_pos(gauges[i]->getAmpPotPos());

      mcp4251->wiper1_pos(gauges[i]->getBridgePotPos());

      //we only do software filter in final stage(after calibrating)
      if(protocol == SEND_NORMAL_VALS) {
         uint16_t unfilteredVal = analogMux->AnalogRead(i);
         gauges[i]->updateInputVals(unfilteredVal);
         config->inputVals = gauges[i]->getInputVals();
         config->numInputVals = StrainGauge::numValsToCached;
         uint16_t filteredVal = Filter::compute(config);
         if(filteredVal != 0) {
            Serial.print(filteredVal);
         }
         else { //number of data points is not enough 
            Serial.print(unfilteredVal);
         }
      }
      else {
         Serial.print(analogMux->AnalogRead(i));
      }

      Serial.print(" ");
   }
   Serial.println();
}

void SGManager::sendStoredValues(int protocol){
   Serial.print(protocol);
   Serial.print(" ");
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      switch(protocol){
         case SEND_TARGET_NO_AMP_VALS:
            Serial.print(gauges[i]->getTargetValNoAmp());
            break;
         case SEND_TARGET_AMP_VALS:
            Serial.print(gauges[i]->getTargetValWithAmp());
            break;
         case SEND_BRIDGE_POT_POS_VALS:
            Serial.print(gauges[i]->getBridgePotPos());
            break;
         case SEND_AMP_POT_POS_VALS:
            Serial.print(gauges[i]->getAmpPotPos());
            break;
      }
      Serial.print(" ");
   }
   Serial.println();
}

#ifdef AC_CALIBRATION //---------------- AC Calibration ---------------------- //
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
      serialPrint(SEND_CALIBRATING_NO_AMP_VALS);
   }

   complete = false;
   while(!complete){
      complete = true;
      for (int i = 0; i < NUM_OF_GAUGES; ++i){
         if (!calibrateAmpPot(i))
            complete = false;
      }
      serialPrint(SEND_CALIBRATING_AMP_VALS);
   }
   serialPrint(SEND_CALI_VALS);
   sendStoredValues(SEND_TARGET_NO_AMP_VALS);
   sendStoredValues(SEND_TARGET_AMP_VALS);
   sendStoredValues(SEND_BRIDGE_POT_POS_VALS);
   sendStoredValues(SEND_AMP_POT_POS_VALS);
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

//------------------------------- AC Calibration End --------------------------------- //

#else //------------------------------ DC Calibration -------------------------------- //
void SGManager::allCalibration(){
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      calibration(i);
   }
   serialPrint(SEND_CALI_VALS);
   sendStoredValues(SEND_TARGET_NO_AMP_VALS);
   sendStoredValues(SEND_TARGET_AMP_VALS);
   sendStoredValues(SEND_BRIDGE_POT_POS_VALS);
   sendStoredValues(SEND_AMP_POT_POS_VALS);
}

void SGManager::calibration(int i){
   calibrateBridgePot(i);
   calibrateAmpPot(i);
}

void SGManager::calibrateBridgePot(int i){
   uint16_t potPos = gauges[i]->getBridgePotPos();
   uint16_t analogVal;
   mcp4251->wiper0_pos(255);
   mcp4251->wiper1_pos((uint8_t)potPos);

   while(potPos >= 0 && potPos <= 255){
      analogVal = analogMux->AnalogRead(i);
      if (analogVal < gauges[i]->getTargetValNoAmp() - TARGET_TOLERANCE_NO_AMP){
         potPos--;
      } else if (analogVal > gauges[i]->getTargetValNoAmp() + TARGET_TOLERANCE_NO_AMP){
         potPos++;
      } else {
         break;
      }
      mcp4251->wiper1_pos((uint8_t)potPos);
      // Serial.print("calibrateBridgePot in while : \t");
      // Serial.print("i : ");
      // Serial.print(i);
      // Serial.print(" potPos : ");
      // Serial.print(potPos);
      // Serial.print(" analogVal : ");
      // Serial.println(analogVal);
   }
   mcp4251->wiper1_pos((uint8_t)potPos);
   gauges[i]->setBridgePotPos((uint8_t)potPos);
   serialPrint(SEND_CALIBRATING_NO_AMP_VALS);
   // Serial.print("calibrateBridgePot : \t");
   // Serial.print("i : ");
   // Serial.print(i);
   // Serial.print(" potPos : ");
   // Serial.print((uint8_t)potPos);
   // Serial.print(" analogVal : ");
   // Serial.println(analogVal);
}

void SGManager::calibrateAmpPot(int i){
   uint16_t potPos = gauges[i]->getAmpPotPos();
   uint16_t analogVal;

   mcp4251->wiper0_pos((uint8_t)potPos);
   mcp4251->wiper1_pos(gauges[i]->getBridgePotPos());

   while(potPos >= 0 && potPos <= 255){
      analogVal = analogMux->AnalogRead(i);
      if (analogVal < gauges[i]->getTargetValWithAmp() - TARGET_TOLERANCE_WITH_AMP){
         potPos--;
      } else if (analogVal > gauges[i]->getTargetValWithAmp() + TARGET_TOLERANCE_WITH_AMP){
         potPos++;
      } else {
         break;
      }
      mcp4251->wiper0_pos((uint8_t)potPos);
      // Serial.print("calibrateAmpPot in while : \t");
      // Serial.print("i : ");
      // Serial.print(i);
      // Serial.print(" potPos : ");
      // Serial.print((uint8_t)potPos);
      // Serial.print(" analogVal : ");
      // Serial.println(analogVal);
   }
   mcp4251->wiper0_pos((uint8_t)potPos);
   gauges[i]->setAmpPotPos((uint8_t)potPos);
   serialPrint(SEND_CALIBRATING_AMP_VALS);
   // Serial.print("calibrateAmpPot : \t");
   // Serial.print("i : ");
   // Serial.print(i);
   // Serial.print(" potPos : ");
   // Serial.print((uint8_t)potPos);
   // Serial.print(" analogVal : ");
   // Serial.println(analogVal);
}
#endif //---------------------------- DC Calibration End -------------------------------- //

void SGManager::manualAssignBridgePotPosForOneGauge(uint8_t gaugeIdx, uint8_t bridgePotPos){
   gauges[gaugeIdx]->setBridgePotPos(bridgePotPos);
}

void SGManager::manualAssignAmpPotPosForOneGauge(uint8_t gaugeIdx, uint8_t ampPotPos){
   gauges[gaugeIdx]->setAmpPotPos(ampPotPos);
}

void SGManager::manualAssignTargetValNoAmpForOneGauge(uint8_t gaugeIdx, uint16_t targetVal){
   gauges[gaugeIdx]->setTargetValNoAmp(targetVal);
   gauges[gaugeIdx]->setBridgeCaliNeeded();
   
   #ifdef AC_CALIBRATION
   calibration();
   #else
   calibration(gaugeIdx);
   #endif
}

void SGManager::manualAssignTargetValWithAmpForOneGauge(uint8_t gaugeIdx, uint16_t targetVal){
   gauges[gaugeIdx]->setTargetValWithAmp(targetVal);
   gauges[gaugeIdx]->setAmpCaliNeeded();

   #ifdef AC_CALIBRATION
   calibration();
   #else
   calibration(gaugeIdx);
   #endif
}

void SGManager::manualAssignTargetValNoAmpForAllGauges(uint16_t targetVal){
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      gauges[i]->setTargetValNoAmp(targetVal);
      gauges[i]->setBridgeCaliNeeded();
   }

   #ifdef AC_CALIBRATION
   calibration();
   #else
   allCalibration();
   #endif
}

void SGManager::manualAssignTargetValWithAmpForAllGauges(uint16_t targetVal){
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      gauges[i]->setTargetValWithAmp(targetVal);
      gauges[i]->setAmpCaliNeeded();
   }

   #ifdef AC_CALIBRATION
   calibration();
   #else
   allCalibration();
   #endif
}
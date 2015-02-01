#include "SGManager.h"

SGManager::SGManager(){
   uint16_t targetValNoAmp[] = {20,20,20,20,20,20,20,20,
                                20,20,20,20,20,20,20,20};
   uint16_t targetValWithAmp[] = {295,295,295,295,295,295,295,295,
                                  295,295,295,295,295,295,295,295};

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

void SGManager::serialPrint(){
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      mcp4251->wiper0_pos(gauges[i]->getAmpPotPos());
      mcp4251->wiper1_pos(gauges[i]->getBridgePotPos());
      Serial.print(analogMux->AnalogRead(i));
      Serial.print(" ");
   }
   Serial.println();
}

void SGManager::allCalibration(){
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      calibrateBridgePot(i);
      calibrateAmpPot(i);
   }
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

   // Serial.print("calibrateAmpPot : \t");
   // Serial.print("i : ");
   // Serial.print(i);
   // Serial.print(" potPos : ");
   // Serial.print((uint8_t)potPos);
   // Serial.print(" analogVal : ");
   // Serial.println(analogVal);
}

void SGManager::manualAssignPotPosForOneGauge(uint8_t gaugeIdx, uint8_t bridgePotPos,
                                              uint8_t ampPotPos){
   gauges[gaugeIdx]->setBridgePotPos(bridgePotPos);
   gauges[gaugeIdx]->setAmpPotPos(ampPotPos);
}

void SGManager::manualAssignTargetValNoAmpForOneGauge(uint8_t gaugeIdx, uint16_t targetVal){
   gauges[gaugeIdx]->setTargetValNoAmp(targetVal);
   calibrateBridgePot(gaugeIdx);
}

void SGManager::manualAssignTargetValWithAmpForOneGauge(uint8_t gaugeIdx, uint16_t targetVal){
   gauges[gaugeIdx]->setTargetValWithAmp(targetVal);
   calibrateAmpPot(gaugeIdx);
}
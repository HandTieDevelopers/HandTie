#include "SGManager.h"

SGManager::SGManager(){
   analogMux = new AnalogMux(MS0, MS1, MS2, READPIN);
   mcp4251 = new MCP4251(POT_SS_PIN, OHM_AB, OHM_WIPER);
   
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      gauges[i] = new StrainGauge(WIPER0_INIT_POS, WIPER1_INIT_POS);
   }

   mcp4251->wiper0_pos(WIPER0_INIT_POS);
   mcp4251->wiper1_pos(WIPER1_INIT_POS);

   pinMode(MUX_CS_PIN, OUTPUT);
}

SGManager::~SGManager(){
   delete(analogMux);
   delete(mcp4251);

   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      delete(gauges[i]);
   }
}

void SGManager::serialPrint(){
   for (int j = 0; j < NUM_OF_MUX; ++j){
      digitalWrite(MUX_CS_PIN, j%2);
      // digitalWrite(MUX_CS_PIN, LOW);

      for(int i=0; i<NUM_OF_MUX_PIN; i++){
         mcp4251->wiper0_pos(gauges[1]->getAmpPotPos());
         mcp4251->wiper1_pos(gauges[1]->getBridgePotPos());
         Serial.print(analogMux->AnalogRead(1));
         Serial.print("\t");
      }
   }
   Serial.println();
}

void SGManager::calibration(){
   for (int j = 0; j < NUM_OF_MUX; ++j){
      digitalWrite(MUX_CS_PIN, j%2);

      for (int i = 0; i < NUM_OF_MUX_PIN; ++i){
         calibrateBridgePot(i);
         calibrateAmpPot(i);
      }
   }
}

void SGManager::calibrateBridgePot(int i){
   mcp4251->wiper0_pos(255);
   uint16_t potPos = gauges[i]->getBridgePotPos();
   uint16_t analogVal;

   while(potPos >= 0 && potPos <= 255){
      analogVal = analogMux->AnalogRead(i);
      if (analogVal < TARGET_NO_AMP - TARGET_TOLERANCE_NO_AMP){
         potPos++;
      } else if (analogVal > TARGET_NO_AMP + TARGET_TOLERANCE_NO_AMP){
         potPos--;
      } else {
         break;
      }
      mcp4251->wiper1_pos((uint8_t)potPos);
      Serial.print("calibrateBridgePot in while : \t");
      Serial.print("i : ");
      Serial.print(i);
      Serial.print(" potPos : ");
      Serial.print(potPos);
      Serial.print(" analogVal : ");
      Serial.println(analogVal);
   }
   mcp4251->wiper1_pos((uint8_t)potPos);
   gauges[i]->setBridgePotPos((uint8_t)potPos);
   
   Serial.print("calibrateBridgePot : \t");
   Serial.print("i : ");
   Serial.print(i);
   Serial.print(" potPos : ");
   Serial.print((uint8_t)potPos);
   Serial.print(" analogVal : ");
   Serial.println(analogVal);
}

void SGManager::calibrateAmpPot(int i){
   uint16_t potPos = gauges[i]->getAmpPotPos();
   uint16_t analogVal;

   while(potPos >= 0 && potPos <= 255){
      analogVal = analogMux->AnalogRead(i);
      if (analogMux->AnalogRead(i) < TARGET_WITH_AMP - TARGET_TOLERANCE_WITH_AMP){
         potPos--;
      } else if (analogMux->AnalogRead(i) > TARGET_WITH_AMP + TARGET_TOLERANCE_WITH_AMP){
         potPos++;
      } else {
         break;
      }
      mcp4251->wiper0_pos((uint8_t)potPos);
      Serial.print("calibrateAmpPot in while : \t");
      Serial.print("i : ");
      Serial.print(i);
      Serial.print(" potPos : ");
      Serial.print(potPos);
      Serial.print(" analogVal : ");
      Serial.println(analogVal);
   }
   mcp4251->wiper0_pos((uint8_t)potPos);
   gauges[i]->setAmpPotPos((uint8_t)potPos);

   Serial.print("calibrateAmpPot : \t");
   Serial.print("i : ");
   Serial.print(i);
   Serial.print(" potPos : ");
   Serial.print((uint8_t)potPos);
   Serial.print(" analogVal : ");
   Serial.println(analogVal);
}

void SGManager::manualChangePotPos(uint8_t ampPotPos, uint8_t brigePotPos){
   mcp4251->wiper0_pos(ampPotPos);
   mcp4251->wiper1_pos(brigePotPos);
}
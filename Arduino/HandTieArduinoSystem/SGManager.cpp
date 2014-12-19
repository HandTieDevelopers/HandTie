#include "SGManager.h"

// --------------------------- Constructor -------------------------------//
SGManager::SGManager(){
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      gauges[i] = new StrainGauge(0, TARGET_ANALOG_VAL_NO_AMP, TARGET_ANALOG_VAL_WITH_AMP);
   }
   for (int i = 0; i < NUM_OF_MCP4251; ++i){
      mcp4251s[i] = new MCP4251(i+MIN_CS_PIN, POT_RESISTOR);
   }
   for (int i = 0; i < NUM_OF_MUX; ++i){
      amxes[i] = new AnalogMux(M_S0,M_S1,M_S2, S_S0,S_S1,S_S2, i+MIN_READPIN);
   }
}

SGManager::~SGManager(){
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      delete(gauges[i]);
   }
   for (int i = 0; i < NUM_OF_MCP4251; ++i){
      delete(mcp4251s[i]);
   }
   for (int i = 0; i < NUM_OF_MUX; ++i){
      delete(amxes[i]);
   }
}

// --------------------------- Serial Print -------------------------------//
void SGManager::serialPrint(){
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      amxes[i/NUM_OF_MUX]->SelectPin(i);
      mcp4251s[i/2]->wiper_pos(gauges[i]->getBridgePotPos(), i%2);
      mcp4251s[2]->wiper1_pos(gauges[i]->getAmpPotPos());
      
      Serial.print(gauges[i]->AnalogRead());
      Serial.print(" ");
   }
}

// -------------------- Parse Message from Serial -------------------------//
// void parseMessage(char * message){
// 
// }

// ---------------------- For Testing and Debug ---------------------------//
void SGManager::setTargetValuesForSG(){

}

// --------------------------- Calibration --------------------------------//
void SGManager::calibrationWithoutPot(){
   Serial.println("Setting calibration base value");
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      gauges[i]->resetCalibrateBaseVal();
   }
}

void SGManager::calibrationWithPot(){
   Serial.println("Calibrating With Pot");
   calibratingBridge();
   calibratingAmp();
}

void SGManager::calibratingBridge(){
   Serial.println("calibrating bridge");

   mcp4251s[2]->wiper1_pos(15);   //turning off

   unsigned long timeNow;
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      amxes[i/NUM_OF_MUX]->SelectPin(i);
      timeNow = millis();

      #define BRIDGE_POT_POS gauges[i]->getBridgePotPos()
      #define TARGET_CALI_VAL gauges[i]->getTargetCaliValNoAmp()
      
      uint16_t bridgePotPos = BRIDGE_POT_POS;
      uint16_t analog;
      
      while(1){
         analog = gauges[i]->AnalogRead();

         if (analog > TARGET_POSITIVE_TOLER(TARGET_CALI_VAL)){
            mcp4251s[i/2]->wiper_pos(--bridgePotPos, i%2);
         } else if (analog < TARGET_NEGATIVE_TOLER(TARGET_CALI_VAL)){
            mcp4251s[i/2]->wiper_pos(++bridgePotPos, i%2);
         } else {
            Serial.print(analog);
            Serial.print(" ");
            break;
         }
         
         if (millis() - timeNow > MAX_TIME_CALIBRATION){
            Serial.print("Timeout ");
            break;
         } 
      }
      gauges[i]->setBridgePotPos(bridgePotPos);
   }
   Serial.println();
}

void SGManager::calibratingAmp(){
   Serial.println("calibrating amp");
   unsigned long timeNow;
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      amxes[i/NUM_OF_MUX]->SelectPin(i);
      timeNow = millis();
      
      #define AMP_POT_POS gauges[i]->getAmpPotPos()
      #define TARGET_CALI_VAL gauges[i]->getTargetCaliVal()

      uint16_t ampPotPos = AMP_POT_POS;
      uint16_t analog;
      while(1){
         analog = gauges[i]->AnalogRead();

         if (analog > TARGET_POSITIVE_TOLER(TARGET_CALI_VAL)){
            mcp4251s[2]->wiper1_pos(--ampPotPos);
         } else if (analog < TARGET_NEGATIVE_TOLER(TARGET_CALI_VAL)){
            mcp4251s[2]->wiper1_pos(++ampPotPos);
         } else {
            Serial.print(analog);
            Serial.print(" ");
            break;
         }
         
         if (millis() - timeNow > MAX_TIME_CALIBRATION){
            Serial.print("Timeout ");
            break;
         } 
      }
      gauges[i]->setAmpPotPos(ampPotPos);
      gauges[i]->setCaliVal(analog);
   }
   Serial.println();
}

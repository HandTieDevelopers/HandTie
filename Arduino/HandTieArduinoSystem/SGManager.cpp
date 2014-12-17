#include "SGManager.h"

SGManager::SGManager(uint8_t gaugePin, uint8_t numOfGauges){
   this->numOfGauges = numOfGauges;
   gauges = new StrainGauge[numOfGauges];
   for (int i = 0; i < numOfGauges; ++i){
      gauges[i].setPin(gaugePin);
   }

   mcp4251 = new MCP4251(CS_PIN, POT_RESISTOR);
   amx = new AnalogMux(M_S0,M_S1,M_S2, S_S0,S_S1,S_S2, READPIN);
}

SGManager::SGManager(uint8_t * gaugePins, uint8_t numOfGauges){
   this->numOfGauges = numOfGauges;
   gauges = new StrainGauge[numOfGauges];
   for (int i = 0; i < numOfGauges; ++i){
      gauges[i].setPin(gaugePins[i]);
   }

   mcp4251 = new MCP4251(CS_PIN, POT_RESISTOR);
   amx = new AnalogMux(M_S0,M_S1,M_S2, S_S0,S_S1,S_S2, READPIN);
}

SGManager::~SGManager(){
   delete(gauges);
   delete(mcp4251);
   delete(amx);
}

void SGManager::calibrationWithoutPot(){
   Serial.println("Setting calibration base value");
   for (int i = 0; i < numOfGauges; ++i){
      gauges[i].resetCalibrateBaseVal();
   }
}

void SGManager::calibrationWithPot(){
   Serial.println("Calibrating With Pot");
   calibratingBridge();
   calibratingAmp();
}

void SGManager::calibratingBridge(){
   Serial.println("calibrating bridge");

   mcp4251->wiper1_pos(15);   //turning off

   unsigned long timeNow;
   for (int i = 0; i < numOfGauges; ++i){
      amx->SelectPin(i);
      timeNow = millis();
      #define BRIDGE_POT_POS gauges[i].getBridgePotPos()
      #define TARGET_CALI_VAL gauges[i].getTargetCaliValNoAmp()
      uint16_t bridgePotPos = BRIDGE_POT_POS;

      while(1){
         uint16_t analog = gauges[i].AnalogRead();

         if (analog > TARGET_POSITIVE_TOLER(TARGET_CALI_VAL)){
            mcp4251->wiper0_pos(--bridgePotPos);
         } else if (analog < TARGET_NEGATIVE_TOLER(TARGET_CALI_VAL)){
            mcp4251->wiper0_pos(++bridgePotPos);
         } else if (timeNow > MAX_TIME_CALIBRATION){
            Serial.print("Timeout");
            break;
         } else {
            Serial.print(analog);
            break;
         }
      }
      gauges[i].setBridgePotPos(bridgePotPos);
   }
}

void SGManager::calibratingAmp(){
   unsigned long timeNow;
   for (int i = 0; i < numOfGauges; ++i){
      amx->SelectPin(i);

      timeNow = millis();
      #define AMP_POT_POS gauges[i].getAmpPotPos()
      #define TARGET_CALI_VAL gauges[i].getTargetCaliVal()
      uint16_t ampPotPos = AMP_POT_POS;

      while(1){
         uint16_t analog = gauges[i].AnalogRead();

         if (analog > TARGET_POSITIVE_TOLER(TARGET_CALI_VAL)){
            mcp4251->wiper1_pos(--ampPotPos);
         } else if (analog < TARGET_NEGATIVE_TOLER(TARGET_CALI_VAL)){
            mcp4251->wiper1_pos(++ampPotPos);
         } else if (timeNow > MAX_TIME_CALIBRATION){
            Serial.print("Timeout");
            break;
         } else {
            Serial.print(analog);
            break;
         }
      }
      gauges[i].setAmpPotPos(ampPotPos);
      gauges[i].setCaliVal(analog);
   }
}
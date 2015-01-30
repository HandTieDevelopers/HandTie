#include "SGManager.h"

SGManager::SGManager(){
   analogMux = new AnalogMux(MS0, MS1, MS2, READPIN);
   mcp4251 = new MCP4251(POT_SS_PIN, OHM_AB, OHM_WIPER);
   
   for (int i = 0; i < NUM_OF_GAUGES; ++i){
      gauges[i] = new StrainGauge();
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
   digitalWrite(MUX_CS_PIN, LOW);
   for(int i=0; i<NUM_OF_MUX_PIN; i++){
       Serial.print(analogMux->AnalogRead(i));
       Serial.print("\t");
   }
   digitalWrite(MUX_CS_PIN, HIGH);
   for(int i=0; i<NUM_OF_MUX_PIN; i++){
       Serial.print(analogMux->AnalogRead(i));
       Serial.print("\t");
   }
   Serial.println();
}

void SGManager::calibration(){
   
}

void SGManager::calibrateBridgePot(){

}

void SGManager::calibrateAmpPot(){

}
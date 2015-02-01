#include "ParserWithAction.h"

ParserWithAction::ParserWithAction(SGManager * sgManager){
   this->sgManager = sgManager;
}

ParserWithAction::~ParserWithAction(){

}

void ParserWithAction::parse(){
   int task = Serial.parseInt();

   switch(task){
      case ALL_AUTO_CALIBRATION:
         sgManager->calibration();
         break;
      case MANUAL_CHANGE_TO_ONE_GAUGE:
         parseForManualChangeToOneGauge();
         break;
      case MANUAL_CHANGE_TO_ALL_GAUGES:
         parseForManualChangeToAllGauges();
         break;
   }
}

void ParserWithAction::parseForManualChangeToOneGauge(){
   int gaugeIdx = Serial.parseInt();
   int targetValNoAmp = Serial.parseInt();
   int targetValWithAmp = Serial.parseInt();

   // sgManager->;
}

void ParserWithAction::parseForManualChangeToAllGauges(){
   int targetValNoAmp = Serial.parseInt();
   int targetValWithAmp = Serial.parseInt();

   // sgManager->;
}
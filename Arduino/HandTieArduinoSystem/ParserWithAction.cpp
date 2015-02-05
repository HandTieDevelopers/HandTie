#include "ParserWithAction.h"

ParserWithAction::ParserWithAction(SGManager * sgManager){
   this->sgManager = sgManager;
}

ParserWithAction::~ParserWithAction(){

}

void ParserWithAction::parse(){
   int task = Serial.parseInt();

   switch(task){
      case ALL_CALIBRATION:
         sgManager->allCalibration();
         break;
      case MANUAL_CHANGE_TO_ONE_GAUGE_NO_AMP:
         parseForManualChangeToOneGaugeNoAmp();
         break;
      case MANUAL_CHANGE_TO_ONE_GAUGE_WITH_AMP:
         parseForManualChangeToOneGaugeWithAmp();
         break;
      case MANUAL_CHANGE_TO_ALL_GAUGES_NO_AMP:
         parseForManualChangeToAllGaugesNoAmp();
         break;
      case MANUAL_CHANGE_TO_ALL_GAUGES_WITH_AMP:
         parseForManualChangeToAllGaugesWithAmp();
         break;
   }
}

void ParserWithAction::parseForManualChangeToOneGaugeNoAmp(){
   uint8_t gaugeIdx = Serial.parseInt();
   uint16_t targetValNoAmp = Serial.parseInt();
   
   sgManager->manualAssignTargetValNoAmpForOneGauge(gaugeIdx, targetValNoAmp);
}

void ParserWithAction::parseForManualChangeToOneGaugeWithAmp(){
   uint8_t gaugeIdx = Serial.parseInt();
   uint16_t targetValWithAmp = Serial.parseInt();

   sgManager->manualAssignTargetValWithAmpForOneGauge(gaugeIdx, targetValWithAmp);
}

void ParserWithAction::parseForManualChangeToAllGaugesNoAmp(){
   uint16_t targetValNoAmp = Serial.parseInt();

   sgManager->manualAssignTargetValNoAmpForAllGauges(targetValNoAmp);
}

void ParserWithAction::parseForManualChangeToAllGaugesWithAmp(){
   uint16_t targetValWithAmp = Serial.parseInt();

   sgManager->manualAssignTargetValWithAmpForAllGauges(targetValWithAmp);
}
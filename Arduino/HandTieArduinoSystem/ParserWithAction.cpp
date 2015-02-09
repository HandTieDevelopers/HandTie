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
      case MANUAL_CHANGE_TO_ONE_GAUGE_TARGET_VAL_NO_AMP:
         parseForManualChangeToOneGaugeTargetValNoAmp();
         break;
      case MANUAL_CHANGE_TO_ONE_GAUGE_TARGET_VAL_WITH_AMP:
         parseForManualChangeToOneGaugeTargetValWithAmp();
         break;
      case MANUAL_CHANGE_TO_ALL_GAUGES_TARGET_VALS_NO_AMP:
         parseForManualChangeToAllGaugesTargetValsNoAmp();
         break;
      case MANUAL_CHANGE_TO_ALL_GAUGES_TARGET_VALS_WITH_AMP:
         parseForManualChangeToAllGaugesTargetValsWithAmp();
         break;
      case REQUEST_FOR_TARGET_VALS_NO_AMP:
         sgManager->sendTargetValsNoAmp();
         break;
      case REQUEST_FOR_TARGET_VALS_WITH_AMP:
         sgManager->sendTargetValsWithAmp();
         break;
   }
}

void ParserWithAction::parseForManualChangeToOneGaugeTargetValNoAmp(){
   uint8_t gaugeIdx = Serial.parseInt();
   uint16_t targetValNoAmp = Serial.parseInt();
   
   sgManager->manualAssignTargetValNoAmpForOneGauge(gaugeIdx, targetValNoAmp);
}

void ParserWithAction::parseForManualChangeToOneGaugeTargetValWithAmp(){
   uint8_t gaugeIdx = Serial.parseInt();
   uint16_t targetValWithAmp = Serial.parseInt();

   sgManager->manualAssignTargetValWithAmpForOneGauge(gaugeIdx, targetValWithAmp);
}

void ParserWithAction::parseForManualChangeToAllGaugesTargetValsNoAmp(){
   uint16_t targetValNoAmp = Serial.parseInt();

   sgManager->manualAssignTargetValNoAmpForAllGauges(targetValNoAmp);
}

void ParserWithAction::parseForManualChangeToAllGaugesTargetValsWithAmp(){
   uint16_t targetValWithAmp = Serial.parseInt();

   sgManager->manualAssignTargetValWithAmpForAllGauges(targetValWithAmp);
}
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
      case ALL_CALIBRATION_CONST_AMP:
         sgManager->allCalibrationAtConstAmp();
         break;

      case MANUAL_CHANGE_TO_ONE_GAUGE_TARGET_VAL_MIN_AMP:
         parseForManualChangeToOneGaugeTargetValMinAmp();
         break;
      case MANUAL_CHANGE_TO_ONE_GAUGE_TARGET_VAL_WITH_AMP:
         parseForManualChangeToOneGaugeTargetValWithAmp();
         break;
      case MANUAL_CHANGE_TO_ONE_GAUGE_TARGET_VAL_AT_CONST_AMP:
         parseForManualChangeToOneGaugeTargetValAtConstAmp();
         break;

      case MANUAL_CHANGE_TO_ALL_GAUGES_TARGET_VALS_MIN_AMP:
         parseForManualChangeToAllGaugesTargetValsMinAmp();
         break;
      case MANUAL_CHANGE_TO_ALL_GAUGES_TARGET_VALS_WITH_AMP:
         parseForManualChangeToAllGaugesTargetValsWithAmp();
         break;
      case MANUAL_CHANGE_TO_ALL_GAUGES_TARGET_VALS_AT_CONST_AMP:
         parseForManualChangeToAllGaugesTargetValsAtConstAmp();
         break;

      case MANUAL_CHANGE_TO_ONE_GAUGE_BRIDGE_POT_POS:
         parseForManualChangeToOneGaugeBridgePotPos();
         break;
      case MANUAL_CHANGE_TO_ONE_GAUGE_AMP_POT_POS:
         parseForManualChangeToOneGaugeAmpPotPos();
         break;

      case MANUAL_CHANGE_TO_ALL_GAUGE_BRIDGE_POT_POS:
         parseForManualChangeToAllGaugesBridgePotPos();
         break;
      case MANUAL_CHANGE_TO_ALL_GAUGE_AMP_POT_POS:
         parseForManualChangeToAllGaugesAmpPotPos();
         break;
      
   }
}

void ParserWithAction::parseForManualChangeToOneGaugeTargetValMinAmp(){
   uint8_t gaugeIdx = Serial.parseInt();
   uint16_t targetValMinAmp = Serial.parseInt();
   
   sgManager->manualAssignTargetValMinAmpForOneGauge(gaugeIdx, targetValMinAmp);
}

void ParserWithAction::parseForManualChangeToOneGaugeTargetValWithAmp(){
   uint8_t gaugeIdx = Serial.parseInt();
   uint16_t targetValWithAmp = Serial.parseInt();

   sgManager->manualAssignTargetValWithAmpForOneGauge(gaugeIdx, targetValWithAmp);
}

void ParserWithAction::parseForManualChangeToOneGaugeTargetValAtConstAmp(){
   uint8_t gaugeIdx = Serial.parseInt();
   uint16_t targetValWithAmp = Serial.parseInt();

   sgManager->manualAssignTargetValAtConstAmpForOneGauge(gaugeIdx, targetValWithAmp);
}


void ParserWithAction::parseForManualChangeToOneGaugeBridgePotPos(){
   uint8_t gaugeIdx = Serial.parseInt();
   uint8_t bridgePotPos = Serial.parseInt();

   sgManager->manualAssignBridgePotPosForOneGauge(gaugeIdx, bridgePotPos);
}

void ParserWithAction::parseForManualChangeToOneGaugeAmpPotPos(){
   uint8_t gaugeIdx = Serial.parseInt();
   uint8_t ampPotPos = Serial.parseInt();

   sgManager->manualAssignAmpPotPosForOneGauge(gaugeIdx, ampPotPos);
}


void ParserWithAction::parseForManualChangeToAllGaugesTargetValsMinAmp(){
   uint16_t targetValMinAmp = Serial.parseInt();

   sgManager->manualAssignTargetValMinAmpForAllGauges(targetValMinAmp);
}

void ParserWithAction::parseForManualChangeToAllGaugesTargetValsWithAmp(){
   uint16_t targetValWithAmp = Serial.parseInt();

   sgManager->manualAssignTargetValWithAmpForAllGauges(targetValWithAmp);
}

void ParserWithAction::parseForManualChangeToAllGaugesTargetValsAtConstAmp(){
   uint16_t targetValWithAmp = Serial.parseInt();

   sgManager->manualAssignTargetValAtConstAmpForAllGauges(targetValWithAmp);
}


void ParserWithAction::parseForManualChangeToAllGaugesBridgePotPos(){
   uint8_t bridgePotPos = Serial.parseInt();

   sgManager->manualAssignBridgePotPosForAllGauges(bridgePotPos);
}

void ParserWithAction::parseForManualChangeToAllGaugesAmpPotPos(){
   uint8_t ampPotPos = Serial.parseInt();

   sgManager->manualAssignAmpPotPosForAllGauges(ampPotPos);
}